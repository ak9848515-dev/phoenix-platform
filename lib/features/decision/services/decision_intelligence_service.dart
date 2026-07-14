import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage_service.dart';
import '../../ai/services/ai_mentor_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../engine/decision_engine.dart';
import '../models/decision_analysis.dart';
import '../models/decision_criterion.dart';
import '../models/decision_option.dart';
import '../models/decision_outcome.dart';
import '../models/decision_risk.dart';
import '../models/decision_type.dart';

/// Public API for Decision Intelligence.
///
/// [DecisionIntelligenceService] is the ONLY entry point for
/// decision analysis functionality. Screens and widgets never
/// interact with [DecisionEngine] directly.
///
/// Responsibilities:
/// - Decision analysis creation and management
/// - Weighted scoring and trade-off analysis
/// - Risk assessment
/// - Outcome tracking (decision history)
/// - AI-powered decision explanations (via [AIMentorService])
/// - Persistence through [UserStateService]
///
/// **Architecture Rules:**
/// - NEVER duplicate Knowledge DNA, Mission Engine, Academy, or AI logic
/// - Integration with those modules happens here, never in the engine
/// - The existing [DecisionService] is unchanged — this is a separate capability
class DecisionIntelligenceService extends ChangeNotifier {
  DecisionIntelligenceService({
    required this._userStateService,
    required this._aiMentorService,
    DecisionEngine? engine,
    /// Optional [StorageService] for explicit persistence of decision
    /// history. When provided, analysis saves are mirrored to storage.
    StorageService? storageService,
  })  : _engine = engine ?? const DecisionEngine(),
        _storage = storageService;

  final UserStateService _userStateService;
  final AIMentorService _aiMentorService;
  final DecisionEngine _engine;
  final StorageService? _storage;

  /// Whether persisted data has been loaded into UserState.
  bool _initialized = false;

  /// Loads persisted decision history from storage into UserState.
  ///
  /// Called once during bootstrap. Merges stored analyses into the
  /// current user state so that existing persisted data is available
  /// before any service reads occur. Also handles upgrade from v1
  /// where UserState was the sole persistence layer.
  Future<void> initFromStorage() async {
    if (_initialized) return;
    _initialized = true;

    final storage = _storage;
    if (storage == null) return;

    final raw = storage.readDecisionHistory();
    if (raw != null) {
      try {
        final list = json.decode(raw) as List<dynamic>;
        if (list.isNotEmpty) {
          final loaded = list
              .map((item) => DecisionAnalysis.fromMap(
                  Map<String, dynamic>.from(item as Map)))
              .toList();
          // Only seed if user has no decision history yet
          if (_userStateService.currentState.decisionHistory.isEmpty) {
            await _userStateService.update(
                (s) => s.copyWith(decisionHistory: loaded));
          }
        }
      } catch (e) {
        debugPrint(
            'DecisionService: failed to parse persisted decisions: $e');
      }
    }

    // If UserState has data but storage is empty, persist to storage
    // (handles upgrade from v1 where decisions were only in UserState)
    final currentState = _userStateService.currentState;
    if (raw == null && currentState.decisionHistory.isNotEmpty) {
      await _persistToStorage();
    }
  }

  /// Persists current decision history to storage.
  Future<void> _persistToStorage() async {
    final storage = _storage;
    if (storage == null) return;
    try {
      final state = _userStateService.currentState;
      await storage.saveDecisionHistory(
        json.encode(state.decisionHistory.map((a) => a.toMap()).toList()),
      );
    } catch (e) {
      debugPrint('DecisionService: failed to persist decisions: $e');
    }
  }

  // ── Analysis ──────────────────────────────────────────────────────

  /// Creates a new decision analysis.
  DecisionAnalysis createAnalysis({
    required String title,
    required DecisionType decisionType,
    String? description,
    List<DecisionCriterion> criteria = const [],
    List<DecisionOption> options = const [],
    List<DecisionRisk> risks = const [],
  }) {
    final id = 'decision-${DateTime.now().millisecondsSinceEpoch}';
    return _engine.analyze(
      id: id,
      title: title,
      decisionType: decisionType,
      description: description,
      criteria: criteria,
      options: options,
      risks: risks,
    );
  }

  /// Returns all stored decision analyses.
  List<DecisionAnalysis> get allAnalyses => _getStoredAnalyses();

  /// Returns a single analysis by ID.
  DecisionAnalysis? getAnalysis(String id) {
    try {
      return _getStoredAnalyses().firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Saves or updates a decision analysis.
  Future<void> saveAnalysis(DecisionAnalysis analysis) async {
    final current = _getStoredAnalyses();
    final index = current.indexWhere((a) => a.id == analysis.id);

    final updated = List<DecisionAnalysis>.from(current);
    if (index >= 0) {
      updated[index] = analysis;
    } else {
      updated.add(analysis);
    }

    await _userStateService.update(
      (s) => s.copyWith(decisionHistory: updated),
    );
    await _persistToStorage();
    notifyListeners();
  }

  // ── Scoring & Ranking ────────────────────────────────────────────

  /// Ranks options by weighted score.
  List<ScoredOption> rankOptions(
    DecisionAnalysis analysis,
  ) {
    return _engine.rankOptions(analysis.options, analysis.criteria);
  }

  /// Returns the top recommended option.
  DecisionOption? getTopRecommendation(DecisionAnalysis analysis) {
    return analysis.topRecommendation;
  }

  // ── Trade-offs ───────────────────────────────────────────────────

  /// Analyzes trade-offs between options.
  List<TradeOffInsight> analyzeTradeOffs(DecisionAnalysis analysis) {
    return _engine.analyzeTradeOffs(analysis.options, analysis.criteria);
  }

  // ── Risk Assessment ──────────────────────────────────────────────

  /// Assesses overall risk.
  RiskAssessment assessRisk(DecisionAnalysis analysis) {
    return _engine.assessRisk(analysis.risks);
  }

  // ── Outcome Tracking ─────────────────────────────────────────────

  /// Records a decision outcome.
  Future<void> recordOutcome(
    String decisionId,
    String selectedOptionId, {
    int? actualScore,
    int? satisfaction,
    String? lessonsLearned,
  }) async {
    final analysis = getAnalysis(decisionId);
    if (analysis == null) return;

    final outcome = DecisionOutcome(
      decisionId: decisionId,
      selectedOptionId: selectedOptionId,
      actualScore: actualScore,
      satisfaction: satisfaction,
      lessonsLearned: lessonsLearned,
      outcomeDate: DateTime.now(),
    );

    final updated = analysis.copyWith(outcome: outcome);
    await saveAnalysis(updated);
  }

  /// Returns the outcome analysis for a decision.
  OutcomeAnalysis? analyzeOutcome(DecisionAnalysis analysis) {
    if (analysis.outcome == null) return null;
    return _engine.analyzeOutcome(analysis, analysis.outcome!);
  }

  // ── AI Integration ───────────────────────────────────────────────

  /// Gets an AI explanation of the decision analysis.
  Future<String> explainAnalysis(DecisionAnalysis analysis) async {
    final top = analysis.topRecommendation;
    final response = await _aiMentorService.chat(
      'Explain this decision analysis: "${analysis.title}" '
      '(type: ${analysis.decisionType.label}). '
      'We evaluated ${analysis.options.length} options against '
      '${analysis.criteria.length} criteria. '
      '${top != null ? "The top recommendation is: ${top.title}." : ""} '
      'Confidence: ${(analysis.confidence * 100).round()}%. '
      'Give a clear, balanced explanation of the trade-offs.',
    );
    return response.content;
  }

  // ── Persistence ──────────────────────────────────────────────────

  List<DecisionAnalysis> _getStoredAnalyses() {
    return _userStateService.currentState.decisionHistory;
  }

  // ── Diagnostics ──────────────────────────────────────────────────

  Map<String, dynamic> diagnostics() {
    return {
      'analysesCount': _getStoredAnalyses().length,
    };
  }
}
