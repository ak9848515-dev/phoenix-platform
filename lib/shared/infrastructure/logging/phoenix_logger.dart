/// Log severity levels.
enum LogLevel {
  debug('DEBUG', 0),
  info('INFO', 1),
  warning('WARNING', 2),
  error('ERROR', 3),
  critical('CRITICAL', 4);

  const LogLevel(this.label, this.severity);

  final String label;
  final int severity;
}

/// Categories for log entries.
enum LogCategory {
  engine('Engine'),
  storage('Storage'),
  startup('Startup'),
  performance('Performance'),
  security('Security'),
  observer('Observer'),
  diagnostics('Diagnostics'),
  config('Configuration'),
  general('General');

  const LogCategory(this.displayName);
  final String displayName;
}

/// A single structured log entry.
class LogEntry {
  const LogEntry({
    required this.level,
    required this.category,
    required this.message,
    this.source = '',
    this.elapsedMs,
    this.error,
    this.metadata = const {},
    this.timestamp,
  });

  final LogLevel level;
  final LogCategory category;
  final String message;
  final String source;
  final int? elapsedMs;
  final String? error;
  final Map<String, dynamic> metadata;
  final DateTime? timestamp;

  LogEntry copyWith({
    LogLevel? level,
    LogCategory? category,
    String? message,
    String? source,
    int? elapsedMs,
    String? error,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) =>
      LogEntry(
        level: level ?? this.level,
        category: category ?? this.category,
        message: message ?? this.message,
        source: source ?? this.source,
        elapsedMs: elapsedMs ?? this.elapsedMs,
        error: error ?? this.error,
        metadata: metadata ?? this.metadata,
        timestamp: timestamp ?? this.timestamp,
      );

  @override
  String toString() =>
      '${_formatTimestamp(timestamp)} [${level.label}] [${category.displayName}] '
      '${source.isNotEmpty ? "($source) " : ""}$message'
      '${elapsedMs != null ? " [${elapsedMs}ms]" : ""}'
      '${error != null ? " - ERROR: $error" : ""}';

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

/// Phoenix structured logger.
///
/// All engines log through this logger.
/// Supports configurable log levels, categories, and in-memory history.
class PhoenixLogger {
  PhoenixLogger({this.minLevel = LogLevel.info, this.maxEntries = 500});

  /// Minimum level to capture.
  LogLevel minLevel;

  /// Maximum number of entries to keep in memory.
  final int maxEntries;

  final List<LogEntry> _entries = [];
  final List<void Function(LogEntry)> _listeners = [];

  /// Unmodifiable view of log history.
  List<LogEntry> get history => List.unmodifiable(_entries);

  /// Recent entries up to [count].
  List<LogEntry> recent([int count = 50]) =>
      _entries.length <= count
          ? List.unmodifiable(_entries)
          : List.unmodifiable(_entries.sublist(_entries.length - count));

  /// Entries filtered by level.
  List<LogEntry> byLevel(LogLevel level) =>
      _entries.where((e) => e.level == level).toList();

  /// Entries filtered by category.
  List<LogEntry> byCategory(LogCategory category) =>
      _entries.where((e) => e.category == category).toList();

  /// Entries with error.
  List<LogEntry> get errors =>
      _entries.where((e) => e.level == LogLevel.error || e.level == LogLevel.critical).toList();

  /// Subscribe to new log entries.
  void addListener(void Function(LogEntry) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(LogEntry) listener) {
    _listeners.remove(listener);
  }

  // ── Log Methods ───────────────────────────────────────────────────

  void debug(String message, {LogCategory category = LogCategory.general, String source = '', Map<String, dynamic>? metadata}) =>
      _log(LogLevel.debug, message, category: category, source: source, metadata: metadata);

  void info(String message, {LogCategory category = LogCategory.general, String source = '', int? elapsedMs, Map<String, dynamic>? metadata}) =>
      _log(LogLevel.info, message, category: category, source: source, elapsedMs: elapsedMs, metadata: metadata);

  void warning(String message, {LogCategory category = LogCategory.general, String source = '', Map<String, dynamic>? metadata}) =>
      _log(LogLevel.warning, message, category: category, source: source, metadata: metadata);

  void error(String message, {LogCategory category = LogCategory.general, String source = '', String? errorDetail, Map<String, dynamic>? metadata}) =>
      _log(LogLevel.error, message, category: category, source: source, error: errorDetail, metadata: metadata);

  void critical(String message, {LogCategory category = LogCategory.general, String source = '', String? errorDetail, Map<String, dynamic>? metadata}) =>
      _log(LogLevel.critical, message, category: category, source: source, error: errorDetail, metadata: metadata);

  void _log(LogLevel level, String message, {
    LogCategory category = LogCategory.general,
    String source = '',
    int? elapsedMs,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    if (level.severity < minLevel.severity) return;

    final entry = LogEntry(
      level: level,
      category: category,
      message: message,
      source: source,
      elapsedMs: elapsedMs,
      error: error,
      metadata: metadata ?? const {},
      timestamp: DateTime.now(),
    );

    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }

    for (final listener in _listeners) {
      listener(entry);
    }
  }

  /// The shared application-wide logger instance.
  static final PhoenixLogger shared = PhoenixLogger();

  /// Reset log history.
  void clear() => _entries.clear();
}
