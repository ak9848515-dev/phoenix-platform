import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import 'ai_provider_interface.dart';

/// Production Gemini adapter — real API calls to Google Gemini.
///
/// **Features:**
/// - Real HTTP calls to Gemini API
/// - Configurable API key (from ProviderConfigurationService)
/// - Retry handling (3 retries with exponential backoff + jitter)
/// - Timeout handling (30s default)
/// - Structured JSON response support
/// - Graceful failure (never throws)
/// - Health monitoring via healthCheck()
/// - Conversation history support (session-aware turns)
/// - Streaming-ready architecture (stream() method)
/// - Request deduplication (identical prompts within same window)
///
/// **Architecture Rules:**
/// - Implements AIProviderInterface — no direct provider calls in engines
/// - Returns AIResponse on success or error — never throws
/// - No business logic — pure translation between AIRequest / AIResponse
///
/// **Flow:**
/// ```
/// AICapabilityRouter.execute(request)
///   ↓
/// GeminiAdapter.execute(request)
///   ↓
/// http.post(Gemini API)  ← API key from config
///   ↓
/// Parse + validate response
///   ↓
/// AIResponse.success or AIResponse.error
/// ```
class GeminiAdapter implements AIProviderInterface {
  GeminiAdapter({
    this._apiKey,
    http.Client? httpClient,
    this.timeoutSeconds = 30,
    this.maxRetries = 3,
    this.enableConversationHistory = false,
    this.maxHistoryTurns = 10,
  })  : _httpClient = httpClient ?? http.Client();

  final PhoenixLogger _logger = PhoenixLogger.shared;
  String? _apiKey;
  final http.Client _httpClient;
  final int timeoutSeconds;
  final int maxRetries;

  // ── Conversation History ─────────────────────────────────────────

  /// Whether conversation history tracking is enabled.
  final bool enableConversationHistory;

  /// Maximum number of conversation turns to retain.
  final int maxHistoryTurns;

  /// In-memory conversation history: list of {role, text} pairs.
  final List<Map<String, String>> _conversationHistory = [];

  /// Deduplication cache: maps prompt text to response, cleared on timer.
  final Map<String, String> _responseCache = {};
  DateTime _lastCacheClear = DateTime.now();
  static const Duration _cacheDuration = Duration(minutes: 1);

  // ── Diagnostics ──────────────────────────────────────────────────

  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  int _totalRetries = 0;
  int _totalLatencyMs = 0;
  String _lastError = '';
  bool _lastHealthStatus = false;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _defaultModel = 'gemini-2.0-flash';

  /// Updates the API key at runtime.
  void updateApiKey(String? apiKey) {
    _apiKey = apiKey;
    _logger.info('GeminiAdapter: API key updated',
        category: LogCategory.config, source: 'GeminiAdapter');
  }

  @override
  AIProvider get provider => AIProvider.gemini;

  @override
  bool get isAvailable => _apiKey != null && _apiKey!.isNotEmpty;

  @override
  bool get supportsOffline => false;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    _totalRequests++;

    if (!isAvailable) {
      _failedRequests++;
      _lastError = 'API key not configured';
      return AIResponse.error(
        provider: AIProvider.gemini,
        capability: request.capability,
        error: _lastError,
        fallbackUsed: false,
      );
    }

    // Check deduplication cache for identical requests
    final cacheKey = '${request.prompt}:${request.capability.name}';
    final cachedResponse = _getCached(cacheKey);
    if (cachedResponse != null) {
      _logger.info('GeminiAdapter: cache hit, returning cached response',
          category: LogCategory.performance, source: 'GeminiAdapter');
      return AIResponse.success(
        provider: AIProvider.gemini,
        capability: request.capability,
        output: cachedResponse,
        latencyMs: 0,
      );
    }

    // Add user prompt to conversation history
    _addToHistory('user', request.prompt);

    final startTime = DateTime.now();
    final formattedPrompt = formatPrompt(request);
    final url = Uri.parse(
      '$_baseUrl/$_defaultModel:generateContent?key=$_apiKey',
    );

    // Build the Gemini-specific request body
    final body = json.encode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text': formattedPrompt,
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': request.temperature,
        'maxOutputTokens': request.maxTokens,
        'topP': 0.95,
        'topK': 40,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
      ],
    });

    // Execute with retry logic
    int attempt = 0;
    String lastError = '';
    int totalLatency = 0;

    while (attempt < maxRetries) {
      attempt++;
      try {
        final response = await _httpClient
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: body,
            )
            .timeout(Duration(seconds: timeoutSeconds));

        totalLatency =
            DateTime.now().difference(startTime).inMilliseconds;

        if (response.statusCode == 200) {
          final parsed = json.decode(response.body) as Map<String, dynamic>;
          final extraction = _extractText(parsed);

          // Check for blocked or empty responses
          if (extraction == null) {
            _failedRequests++;
            _lastError = 'Response blocked or empty';
            _logger.warning(
              'GeminiAdapter: response blocked or empty',
              category: LogCategory.engine,
              source: 'GeminiAdapter',
            );
            return AIResponse.error(
              provider: AIProvider.gemini,
              capability: request.capability,
              error: _lastError,
              latencyMs: totalLatency,
            );
          }

          final estimatedTokens =
              (formattedPrompt.length ~/ 4) + (extraction.length ~/ 4);

          // Track diagnostics
          _successfulRequests++;
          _totalLatencyMs += totalLatency;
          if (attempt > 1) _totalRetries += (attempt - 1);

          // Cache response for deduplication
          _responseCache[cacheKey] = extraction;

          // Add response to conversation history
          _addToHistory('assistant', extraction);

          _logger.info(
            'GeminiAdapter: success (${totalLatency}ms, ${attempt == 1 ? "first try" : "retry #${attempt - 1}"})',
            category: LogCategory.performance,
            source: 'GeminiAdapter',
            metadata: {
              'latencyMs': totalLatency,
              'attempt': attempt,
              'capability': request.capability.name,
            },
          );

          return AIResponse.success(
            provider: AIProvider.gemini,
            capability: request.capability,
            output: extraction,
            latencyMs: totalLatency,
            estimatedTokens: estimatedTokens,
          );
        } else if (response.statusCode == 429) {
          // Rate limited — retry after delay
          lastError = 'Rate limited (429)';
          final retryAfter = _parseRetryAfter(response) ?? (attempt * 2000);
          _logger.warning(
            'GeminiAdapter: rate limited, retrying after ${retryAfter}ms',
            category: LogCategory.engine,
            source: 'GeminiAdapter',
          );
          await Future.delayed(Duration(milliseconds: retryAfter));
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          // Authentication error — not retryable
          _failedRequests++;
          _totalLatencyMs += totalLatency;
          _lastError = 'Authentication failed (${response.statusCode})';
          _logger.error(
            'GeminiAdapter: authentication failed',
            category: LogCategory.security,
            source: 'GeminiAdapter',
            errorDetail: response.body,
          );
          return AIResponse.error(
            provider: AIProvider.gemini,
            capability: request.capability,
            error:
                'Gemini API key rejected (${response.statusCode}). Check your key.',
            latencyMs: totalLatency,
          );
        } else if (response.statusCode >= 500) {
          // Server error — retryable
          lastError =
              'Server error (${response.statusCode})';
          _totalRetries++;
          _logger.warning(
            'GeminiAdapter: server error, retrying ($attempt/$maxRetries)',
            category: LogCategory.engine,
            source: 'GeminiAdapter',
          );
          await Future.delayed(
            Duration(milliseconds: _exponentialBackoff(attempt)),
          );
        } else {
          _failedRequests++;
          _totalLatencyMs += totalLatency;
          _lastError =
              'Unexpected status: ${response.statusCode}';
          _logger.warning(
            'GeminiAdapter: unexpected status ${response.statusCode}',
            category: LogCategory.engine,
            source: 'GeminiAdapter',
          );
          // Don't retry on unexpected client errors
          return AIResponse.error(
            provider: AIProvider.gemini,
            capability: request.capability,
            error: _lastError,
            latencyMs: totalLatency,
          );
        }
      } on SocketException catch (e) {
        totalLatency =
            DateTime.now().difference(startTime).inMilliseconds;
        lastError = 'Network error: ${e.message}';
        _logger.warning(
          'GeminiAdapter: network error, retrying ($attempt/$maxRetries)',
          category: LogCategory.diagnostics,
          source: 'GeminiAdapter',
        );
        await Future.delayed(
          Duration(milliseconds: _exponentialBackoff(attempt)),
        );
      } on HttpException catch (e) {
        totalLatency =
            DateTime.now().difference(startTime).inMilliseconds;
        lastError = 'HTTP error: ${e.message}';
        await Future.delayed(
          Duration(milliseconds: _exponentialBackoff(attempt)),
        );
      } on TimeoutException {
        totalLatency =
            DateTime.now().difference(startTime).inMilliseconds;
        lastError = 'Request timed out after ${timeoutSeconds}s';
        _logger.warning(
          'GeminiAdapter: timeout ($timeoutSeconds s), retrying ($attempt/$maxRetries)',
          category: LogCategory.diagnostics,
          source: 'GeminiAdapter',
        );
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        totalLatency =
            DateTime.now().difference(startTime).inMilliseconds;
        lastError = 'Unexpected error: $e';
        _logger.error(
          'GeminiAdapter: unexpected error',
          category: LogCategory.engine,
          source: 'GeminiAdapter',
          errorDetail: e.toString(),
        );
        // Don't retry on unexpected errors
        break;
      }
    }

    // All retries exhausted
    _logger.error(
      'GeminiAdapter: all retries exhausted ($maxRetries attempts)',
      category: LogCategory.engine,
      source: 'GeminiAdapter',
      errorDetail: lastError,
    );

    return AIResponse.error(
      provider: AIProvider.gemini,
      capability: request.capability,
      error:
          'Gemini unavailable after $maxRetries attempts: $lastError',
      latencyMs: totalLatency,
      fallbackUsed: true,
    );
  }

  @override
  String formatPrompt(AIRequest request) {
    final buf = StringBuffer();

    // System-level instructions from context
    if (request.context.containsKey('systemInstructions')) {
      buf.writeln('${request.context['systemInstructions']}\n');
    }

    // Conversation history (injected before current context)
    if (enableConversationHistory && _conversationHistory.isNotEmpty) {
      final history = _getHistory();
      if (history.isNotEmpty) {
        buf.writeln('--- Previous Conversation ---\n$history\n---\n');
      }
    }

    // Capability-specific context
    if (request.context.isNotEmpty) {
      buf.writeln('--- Context ---');
      for (final entry in request.context.entries) {
        if (entry.key == 'systemInstructions') continue;
        final value = entry.value;
        if (value is String) {
          buf.writeln('${entry.key}: $value');
        } else {
          try {
            buf.writeln('${entry.key}: ${json.encode(value)}');
          } catch (_) {
            buf.writeln('${entry.key}: [complex data]');
          }
        }
      }
      buf.writeln('--- End Context ---\n');
    }

    // Output schema instruction
    if (request.context.containsKey('outputSchema')) {
      buf.writeln(
        'Respond with valid JSON matching this schema: '
        '${request.context['outputSchema']}\n',
      );
    }

    // The actual prompt
    buf.write(request.prompt);

    // JSON output reminder for structured capabilities
    if (request.context.containsKey('expectJson') ||
        request.capability.name.contains('generate')) {
      buf.write('\n\nRespond with valid JSON only — no markdown, no explanation.');
    }

    return buf.toString();
  }

  // ── Response Parsing ─────────────────────────────────────────────

  /// Extracts text content from a Gemini API response.
  ///
  /// Returns `null` if the response was blocked, empty, or malformed.
  String? _extractText(Map<String, dynamic> response) {
    try {
      final candidates = response['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        // Check for blocked response
        final promptFeedback =
            response['promptFeedback'] as Map<String, dynamic>?;
        if (promptFeedback != null) {
          final blockReason = promptFeedback['blockReason'] as String?;
          if (blockReason != null) {
            _logger.warning(
              'GeminiAdapter: response blocked: $blockReason',
              category: LogCategory.engine,
              source: 'GeminiAdapter',
            );
          }
        }
        return null;
      }

      final first = candidates.first as Map<String, dynamic>;
      final content = first['content'] as Map<String, dynamic>?;
      if (content == null) return null;

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;

      final texts = parts.map((part) {
        final p = part as Map<String, dynamic>;
        return p['text'] as String? ?? '';
      }).where((t) => t.isNotEmpty).toList();

      if (texts.isEmpty) return null;
      return texts.join('\n');
    } catch (e) {
      _logger.error(
        'GeminiAdapter: failed to parse response',
        category: LogCategory.engine,
        source: 'GeminiAdapter',
        errorDetail: e.toString(),
      );
      return null;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Exponential backoff with jitter: 1s, 2s, 4s, 8s, ...
  int _exponentialBackoff(int attempt) {
    final baseMs = 1000;
    final delay = baseMs * (1 << (attempt - 1)); // 2^(attempt-1) * 1000
    // Add jitter: ±25%
    final jitter = (delay * 0.25).toInt();
    return delay + (jitter > 0 ? DateTime.now().millisecondsSinceEpoch % jitter : 0);
  }

  /// Parses the Retry-After header value (seconds or HTTP-date).
  int? _parseRetryAfter(http.Response response) {
    final value = response.headers['retry-after'];
    if (value == null) return null;
    final seconds = int.tryParse(value);
    if (seconds != null) return seconds * 1000;
    return null;
  }

  /// Performs a lightweight health-check request.
  ///
  /// Returns `true` if the provider is reachable and authenticated.
  /// Does not count toward normal API usage (uses a minimal request).
  Future<bool> healthCheck() async {
    if (!isAvailable) return false;

    try {
      final url = Uri.parse(
        '$_baseUrl/$_defaultModel:generateContent?key=$_apiKey',
      );
      final body = json.encode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': 'Reply with just the word "ok".'},
            ],
          },
        ],
        'generationConfig': {
          'maxOutputTokens': 10,
          'temperature': 0.0,
        },
      });

      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Disposes the HTTP client.
  void dispose() {
    _httpClient.close();
  }

  // ── Conversation History ────────────────────────────────────────────

  /// Adds a turn to the conversation history.
  void _addToHistory(String role, String text) {
    if (!enableConversationHistory) return;
    _conversationHistory.add({'role': role, 'text': text});
    // Trim to max turns, keeping the oldest first
    while (_conversationHistory.length > maxHistoryTurns * 2) {
      _conversationHistory.removeAt(0);
    }
  }

  /// Returns conversation history formatted as a string.
  String _getHistory() {
    if (_conversationHistory.isEmpty) return '';
    return _conversationHistory
        .map((turn) => '${turn['role']}: ${turn['text']}')
        .join('\n');
  }

  /// Clears all conversation history.
  void clearHistory() {
    _conversationHistory.clear();
    _logger.info('GeminiAdapter: conversation history cleared',
        category: LogCategory.config, source: 'GeminiAdapter');
  }

  // ── Streaming (Architecture Ready) ──────────────────────────────────

  /// Streams response chunks from Gemini (streaming-ready architecture).
  ///
  /// Currently returns a single-element stream for architecture compatibility.
  /// When streaming is enabled server-side, this will yield real chunks.
  ///
  /// **Note:** Streaming UI is NOT required for this sprint.
  /// This method provides the architecture hook for future streaming support.
  Stream<String> stream(AIRequest request) async* {
    final result = await execute(request);
    if (result.success) {
      yield result.output;
    } else {
      yield 'Error: ${result.error ?? "Unknown error"}';
    }
  }

  // ── Deduplication ───────────────────────────────────────────────────

  /// Checks if a response is cached for deduplication.
  /// Cache is cleared every [_cacheDuration].
  String? _getCached(String prompt) {
    final now = DateTime.now();
    if (now.difference(_lastCacheClear) > _cacheDuration) {
      _responseCache.clear();
      _lastCacheClear = now;
    }
    return _responseCache[prompt];
  }

  // ── Diagnostics ─────────────────────────────────────────────────────

  /// Returns current diagnostics for this adapter.
  Map<String, dynamic> diagnosticsSummary() {
    return {
      'totalRequests': _totalRequests,
      'successfulRequests': _successfulRequests,
      'failedRequests': _failedRequests,
      'totalRetries': _totalRetries,
      'averageLatencyMs':
          _totalRequests > 0 ? (_totalLatencyMs ~/ _totalRequests) : 0,
      'successRate':
          _totalRequests > 0 ? (_successfulRequests / _totalRequests) : 0.0,
      'lastError': _lastError,
      'lastHealthStatus': _lastHealthStatus,
      'isAvailable': isAvailable,
      'isConnected': _apiKey != null,
      'conversationTurns': _conversationHistory.length,
      'cacheEntries': _responseCache.length,
    };
  }

  /// Resets all diagnostics counters.
  void resetDiagnostics() {
    _totalRequests = 0;
    _successfulRequests = 0;
    _failedRequests = 0;
    _totalRetries = 0;
    _totalLatencyMs = 0;
    _lastError = '';
    _lastHealthStatus = false;
    _responseCache.clear();
  }
}
