import 'package:flutter/foundation.dart';

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
  }) : _engine = engine ?? const DecisionEngine();

  final UserStateService _userStateService;
  final AIMentorService _aiMentorService;
  final DecisionEngine _engine;

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
