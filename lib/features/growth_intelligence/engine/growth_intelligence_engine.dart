import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../shared/infrastructure/performance/debounce_notifier.dart';
import '../../career/engine/career_engine.dart';
import '../../decision_intelligence/engine/decision_engine.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../growth_index/models/growth_snapshot.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../models/forecast_confidence.dart';
import '../models/forecast_milestone.dart';
import '../models/forecast_prediction.dart';
import '../models/forecast_timeline.dart';
import '../models/forecast_type.dart';
import '../models/growth_forecast_snapshot.dart';

/// Growth Intelligence Engine — predicts the user's future trajectory.
///
/// **Responsibilities:**
/// - Generate deterministic forecasts for 10 metrics across 5 timelines
/// - Predict unlock milestones (level, badge, career, skill, project, interview)
/// - Compute what-if scenario simulations
/// - Produce an immutable [GrowthForecastSnapshot] for all consumers
///
/// **Architecture Rules:**
/// - NEVER calls AI providers
/// - NEVER uses random weights (fully deterministic)
/// - NEVER modifies other engines
/// - Always consumes engine snapshots (never queries repositories)
///
/// **Consumers:**
/// - Dashboard (replace static progress estimates)
/// - Progress screen (trajectory + milestones)
/// - Career screen (readiness forecast)
/// - Phoenix Assistant (reuse snapshot)
///
/// **Flow:**
/// ```
/// All Engines → GrowthIntelligenceEngine.forecast() → GrowthForecastSnapshot → UI
/// ```
class GrowthIntelligenceEngine extends ChangeNotifier
    with DebounceChangeNotifier {
  GrowthIntelligenceEngine({
    required this.growthEngine,
    required this.missionEngine,
    required this.careerEngine,
    required this.portfolioEngine,
    required this.decisionEngine,
  });

  final GrowthIndexEngine growthEngine;
  final MissionIntelligenceEngine missionEngine;
  final CareerEngine careerEngine;
  final PortfolioEngine portfolioEngine;
  final DecisionEngine decisionEngine;

  final PhoenixLogger _logger = PhoenixLogger.shared;
  GrowthForecastSnapshot? _cachedSnapshot;
  final List<GrowthForecastSnapshot> _history = [];
  bool _isInitialized = false;
  bool _isForecasting = false;

  static const List<ForecastTimeline> _timelines = ForecastTimeline.values;

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current forecast snapshot (may be null before first forecast).
  GrowthForecastSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes by subscribing to source engines and running first forecast.
  Future<void> init() async {
    _cachedSnapshot = _generateForecast();
    _isInitialized = true;

    growthEngine.addListener(_onEngineChanged);
    missionEngine.addListener(_onEngineChanged);
    careerEngine.addListener(_onEngineChanged);
    portfolioEngine.addListener(_onEngineChanged);
    decisionEngine.addListener(_onEngineChanged);

    setDebounceMs(60); // 60ms debounce for 5-engine cascade

    _logger.info('GrowthIntelligenceEngine initialized',
        category: LogCategory.engine, source: 'GrowthIntelligenceEngine',
        metadata: {
          'forecasts': _cachedSnapshot?.forecasts.length ?? 0,
          'milestones': _cachedSnapshot?.milestones.length ?? 0,
        });
    notifyImmediately();
  }

  /// Forces a fresh forecast generation and preserves history.
  Future<void> forecast() async {
    // Save current snapshot to history before regenerating
    if (_cachedSnapshot != null) {
      _history.insert(0, _cachedSnapshot!);
      if (_history.length > 10) _history.removeLast();
    }
    _cachedSnapshot = _generateForecast();
    _logger.debug('GrowthIntelligenceEngine re-forecast',
        category: LogCategory.engine, source: 'GrowthIntelligenceEngine');
    // Debounced via DebounceChangeNotifier mixin — no manual notify needed
  }

  @override
  void dispose() {
    growthEngine.removeListener(_onEngineChanged);
    missionEngine.removeListener(_onEngineChanged);
    careerEngine.removeListener(_onEngineChanged);
    portfolioEngine.removeListener(_onEngineChanged);
    decisionEngine.removeListener(_onEngineChanged);
    super.dispose(); // DebounceChangeNotifier.dispose() handles timer cleanup
  }

  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isForecasting) return;
    _isForecasting = true;
    try {
      await forecast();
    } finally {
      _isForecasting = false;
    }
  }

  // ── What-If Analysis ──────────────────────────────────────────────

  /// Runs a deterministic simulation with modified parameters.
  ///
  /// [scenarioName]: human-readable label for the scenario
  /// [dailyMinutes]: simulated daily learning/working minutes
  /// [projectCount]: simulated additional projects
  /// [consistencyBoost]: simulated consistency multiplier (0.0-2.0)
  Map<String, List<ForecastPrediction>> simulate({
    required String scenarioName,
    double dailyMinutes = 30,
    int projectCount = 0,
    double consistencyBoost = 1.0,
  }) {
    final snap = growthEngine.snapshot;
    if (snap == null) return {};

    // Apply simulation parameters to forecast generation
    final timeMultiplier = dailyMinutes / 30.0; // 30 min/day = baseline
    final effectiveConsistency = consistencyBoost * timeMultiplier;

    final forecasts = <ForecastPrediction>[];
    for (final tl in _timelines) {
      // XP forecast with consistency adjustment
      final xpPredict = _xpForecast(snap, tl.days, effectiveConsistency);
      forecasts.add(xpPredict);

      // Portfolio forecast with project count adjustment
      final projectBoost = 1.0 + (projectCount * 0.15);
      final portPredict = _portfolioGrowthForecast(snap, tl.days);
      forecasts.add(ForecastPrediction(
        type: portPredict.type,
        timelineDays: portPredict.timelineDays,
        currentValue: portPredict.currentValue,
        predictedValue: (portPredict.predictedValue * projectBoost)
            .clamp(0.0, 100.0),
        improvement: portPredict.improvement * projectBoost,
        confidence: portPredict.confidence,
        label: portPredict.label,
        unit: portPredict.unit,
        assumptions: [
          ...portPredict.assumptions,
          'Simulated: $projectCount additional project(s)',
        ],
        requiredActions: portPredict.requiredActions,
        riskFactors: portPredict.riskFactors,
      ));

      // Knowledge forecast with daily minutes boost
      final knowPredict = _knowledgeGrowthForecast(snap, tl.days);
      final knowBoost = 1.0 + ((dailyMinutes - 30) / 60).clamp(-0.5, 1.0);
      forecasts.add(ForecastPrediction(
        type: knowPredict.type,
        timelineDays: knowPredict.timelineDays,
        currentValue: knowPredict.currentValue,
        predictedValue: (knowPredict.predictedValue * knowBoost)
            .clamp(0.0, 100.0),
        improvement: knowPredict.improvement * knowBoost,
        confidence: knowPredict.confidence,
        label: knowPredict.label,
        unit: knowPredict.unit,
        assumptions: [
          ...knowPredict.assumptions,
          'Simulated: $dailyMinutes min/day study time',
        ],
        requiredActions: knowPredict.requiredActions,
        riskFactors: knowPredict.riskFactors,
      ));
    }

    return {scenarioName: forecasts};
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  /// Generates a complete forecast snapshot from current engine state.
  GrowthForecastSnapshot _generateForecast() {
    final now = DateTime.now();

    // Read source engine snapshots
    final growthSnap = growthEngine.snapshot;

    // Insufficient data — return empty snapshot
    if (growthSnap == null || growthSnap.totalXp == 0) {
      return GrowthForecastSnapshot(
        forecasts: const [],
        milestones: const [],
        topOpportunities: const [],
        topRisks: const [],
        overallConfidence: 0,
        generatedAt: now,
      );
    }

    // Generate all forecasts across all 5 timelines
    final allForecasts = <ForecastPrediction>[];
    for (final type in ForecastType.values) {
      for (final tl in _timelines) {
        final prediction = _computePrediction(
          type: type,
          snap: growthSnap,
          timeline: tl,
        );
        if (prediction != null) {
          allForecasts.add(prediction);
        }
      }
    }

    // Generate milestones
    final milestones = _computeMilestones(growthSnap, now);

    // Rank opportunities (highest improvement, highest confidence)
    final sorted = List<ForecastPrediction>.from(allForecasts)
      ..sort((a, b) {
        final aScore = (a.improvement * (a.confidence.overall / 100));
        final bScore = (b.improvement * (b.confidence.overall / 100));
        return bScore.compareTo(aScore);
      });
    final topOpportunities = sorted.take(3).toList();

    // Rank risks (lowest confidence, declining)
    final risks = List<ForecastPrediction>.from(allForecasts)
      ..sort((a, b) => a.confidence.overall.compareTo(b.confidence.overall));
    final topRisks = risks.take(3).toList();

    // Overall confidence (average of all prediction confidences)
    final avgConfidence = allForecasts.isNotEmpty
        ? (allForecasts.fold(0, (int sum, p) => sum + p.confidence.overall) /
            allForecasts.length)
            .round()
        : 0;

    return GrowthForecastSnapshot(
      forecasts: allForecasts,
      milestones: milestones,
      topOpportunities: topOpportunities,
      topRisks: topRisks,
      overallConfidence: avgConfidence,
      generatedAt: now,
    );
  }

  // ── Prediction Engine ─────────────────────────────────────────────

  /// Computes a single deterministic prediction.
  ForecastPrediction? _computePrediction({
    required ForecastType type,
    required GrowthSnapshot snap,
    required ForecastTimeline timeline,
    double rateMultiplier = 1.0,
  }) {
    final days = timeline.days;
    final rate = rateMultiplier;

    switch (type) {
      case ForecastType.xp:
        return _xpForecast(snap, days, rate);
      case ForecastType.level:
        return _levelForecast(snap, days, rate);
      case ForecastType.missionCompletion:
        return _missionCompletionForecast(snap, days);
      case ForecastType.knowledgeGrowth:
        return _knowledgeGrowthForecast(snap, days);
      case ForecastType.careerReadiness:
        return _careerReadinessForecast(snap, days);
      case ForecastType.portfolioGrowth:
        return _portfolioGrowthForecast(snap, days);
      case ForecastType.interviewReadiness:
        return _interviewReadinessForecast(snap, days);
      case ForecastType.assessmentReadiness:
        return _assessmentReadinessForecast(snap, days);
      case ForecastType.projectCompletion:
        return _projectCompletionForecast(snap, days);
      case ForecastType.learningStreak:
        return _learningStreakForecast(snap, days);
    }
  }

  // ── Individual Forecast Formulas ──────────────────────────────────

  /// XP growth based on existing XP rate.
  ForecastPrediction _xpForecast(GrowthSnapshot snap, int days, double rate) {
    final dailyXp = snap.totalXp / 30.0; // XP per day based on first 30 days
    final predicted = snap.totalXp + (dailyXp * days * rate);
    final improvement = predicted - snap.totalXp;
    final confidence = _computeConfidence(
      snap, 0.7, 0.6,
      history: snap.history.daily.length,
    );

    return ForecastPrediction(
      type: ForecastType.xp,
      timelineDays: days,
      currentValue: snap.totalXp.toDouble(),
      predictedValue: predicted,
      improvement: improvement,
      confidence: confidence,
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Total XP',
      unit: 'XP',
      assumptions: ['Current learning pace is maintained'],
      requiredActions: ['Complete daily missions', 'Stay consistent'],
      riskFactors: ['Inconsistent engagement', 'Missed days'],
    );
  }

  /// Level progression based on XP.
  ForecastPrediction _levelForecast(
      GrowthSnapshot snap, int days, double rate) {
    final dailyXp = snap.totalXp / 30.0;
    final xpGained = dailyXp * days * rate;
    final xpPerLevel = snap.currentLevel * 250;
    final levelsGained = xpPerLevel > 0 ? xpGained / xpPerLevel : 0.0;
    final predictedLevel = snap.currentLevel + levelsGained;

    return ForecastPrediction(
      type: ForecastType.level,
      timelineDays: days,
      currentValue: snap.currentLevel.toDouble(),
      predictedValue: predictedLevel,
      improvement: levelsGained,
      confidence: _computeConfidence(snap, 0.6, 0.5,
          history: snap.history.daily.length),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Level',
      unit: 'levels',
      assumptions: ['XP rate remains consistent'],
      requiredActions: ['Earn ${xpPerLevel.round()} XP per level'],
      riskFactors: ['XP requirements increase per level'],
    );
  }

  /// Mission completion rate.
  ForecastPrediction _missionCompletionForecast(
      GrowthSnapshot snap, int days) {
    final missionScore = snap.mission.score;
    final missionTrend = snap.mission.trend.name;
    final growthRate = _trendToGrowthRate(missionTrend);
    // Mission score improvement: current + (gap * growthRate * timeFactor)
    final gap = 1.0 - missionScore;
    const recoveryDays = 90;
    final timeFactor = (days / recoveryDays).clamp(0.0, 1.0);
    final predicted = missionScore + (gap * growthRate * timeFactor);
    final improvement = predicted - missionScore;

    return ForecastPrediction(
      type: ForecastType.missionCompletion,
      timelineDays: days,
      currentValue: missionScore * 100,
      predictedValue: (predicted * 100).clamp(0.0, 100.0),
      improvement: improvement * 100,
      confidence: _computeConfidence(snap, 0.55, 0.5,
          score: missionScore),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Mission Score',
      unit: '%',
      dependencies: ['Active missions exist'],
      assumptions: ['Current mission completion rate holds'],
      requiredActions: ['Start and complete missions regularly'],
      riskFactors: ['Mission difficulty increases'],
    );
  }

  /// Knowledge growth trajectory.
  ForecastPrediction _knowledgeGrowthForecast(
      GrowthSnapshot snap, int days) {
    final knowScore = snap.knowledge.score;
    final trend = snap.knowledge.trend.name;
    final growthRate = _trendToGrowthRate(trend);
    const recoveryDays = 120;
    final timeFactor = (days / recoveryDays).clamp(0.0, 1.0);
    final predicted = knowScore + ((1.0 - knowScore) * growthRate * timeFactor);
    final improvement = predicted - knowScore;

    return ForecastPrediction(
      type: ForecastType.knowledgeGrowth,
      timelineDays: days,
      currentValue: knowScore * 100,
      predictedValue: (predicted * 100).clamp(0.0, 100.0),
      improvement: improvement * 100,
      confidence: _computeConfidence(snap, 0.7, 0.55,
          score: knowScore, history: snap.history.weekly.length),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Knowledge Score',
      unit: '%',
      assumptions: ['Regular learning sessions continue'],
      requiredActions: ['Complete lessons daily', 'Review weak areas'],
      riskFactors: ['Knowledge decay without review', 'Plateau effect'],
    );
  }

  /// Career readiness projection.
  ForecastPrediction _careerReadinessForecast(
      GrowthSnapshot snap, int days) {
    final careerScore = snap.career.score;
    final trend = snap.career.trend.name;
    final growthRate = _trendToGrowthRate(trend);
    const recoveryDays = 180;
    final timeFactor = (days / recoveryDays).clamp(0.0, 1.0);
    final predicted = careerScore + ((1.0 - careerScore) * growthRate * timeFactor);
    final improvement = predicted - careerScore;

    return ForecastPrediction(
      type: ForecastType.careerReadiness,
      timelineDays: days,
      currentValue: careerScore * 100,
      predictedValue: (predicted * 100).clamp(0.0, 100.0),
      improvement: improvement * 100,
      confidence: _computeConfidence(snap, 0.5, 0.45,
          score: careerScore),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Career Score',
      unit: '%',
      dependencies: ['Portfolio development', 'Interview practice'],
      assumptions: ['Career development activities continue'],
      requiredActions: ['Update resume', 'Practice interviews', 'Build portfolio'],
      riskFactors: ['Market conditions', 'Skill requirement changes'],
    );
  }

  /// Portfolio growth prediction.
  ForecastPrediction _portfolioGrowthForecast(
      GrowthSnapshot snap, int days) {
    final portScore = snap.portfolio.score;
    final trend = snap.portfolio.trend.name;
    final growthRate = _trendToGrowthRate(trend);
    const recoveryDays = 150;
    final timeFactor = (days / recoveryDays).clamp(0.0, 1.0);
    final predicted = portScore + ((1.0 - portScore) * growthRate * timeFactor);
    final improvement = predicted - portScore;

    return ForecastPrediction(
      type: ForecastType.portfolioGrowth,
      timelineDays: days,
      currentValue: portScore * 100,
      predictedValue: (predicted * 100).clamp(0.0, 100.0),
      improvement: improvement * 100,
      confidence: _computeConfidence(snap, 0.6, 0.5,
          score: portScore),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Portfolio Score',
      unit: '%',
      assumptions: ['Projects are added regularly'],
      requiredActions: ['Complete projects', 'Add technologies'],
      riskFactors: ['Project complexity increases'],
    );
  }

  /// Interview readiness trajectory.
  ForecastPrediction _interviewReadinessForecast(
      GrowthSnapshot snap, int days) {
    final intScore = snap.interview.score;
    final trend = snap.interview.trend.name;
    final growthRate = _trendToGrowthRate(trend);
    const recoveryDays = 90;
    final timeFactor = (days / recoveryDays).clamp(0.0, 1.0);
    final predicted = intScore + ((1.0 - intScore) * growthRate * timeFactor);
    final improvement = predicted - intScore;

    return ForecastPrediction(
      type: ForecastType.interviewReadiness,
      timelineDays: days,
      currentValue: intScore * 100,
      predictedValue: (predicted * 100).clamp(0.0, 100.0),
      improvement: improvement * 100,
      confidence: _computeConfidence(snap, 0.5, 0.4,
          score: intScore),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Interview Score',
      unit: '%',
      dependencies: ['Career readiness progress'],
      assumptions: ['Interview practice continues regularly'],
      requiredActions: ['Practice mock interviews', 'Review common questions'],
      riskFactors: ['Interview anxiety', 'Unpredictable questions'],
    );
  }

  /// Assessment readiness (combined knowledge + skills).
  ForecastPrediction _assessmentReadinessForecast(
      GrowthSnapshot snap, int days) {
    final avgScore = (snap.knowledge.score + snap.skills.score) / 2.0;
    final trend = snap.knowledge.trend.name;
    final growthRate = _trendToGrowthRate(trend);
    const recoveryDays = 60;
    final timeFactor = (days / recoveryDays).clamp(0.0, 1.0);
    final predicted = avgScore + ((1.0 - avgScore) * growthRate * timeFactor);
    final improvement = predicted - avgScore;

    return ForecastPrediction(
      type: ForecastType.assessmentReadiness,
      timelineDays: days,
      currentValue: avgScore * 100,
      predictedValue: (predicted * 100).clamp(0.0, 100.0),
      improvement: improvement * 100,
      confidence: _computeConfidence(snap, 0.65, 0.5,
          score: avgScore),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Assessment Readiness',
      unit: '%',
      dependencies: ['Knowledge + Skills progress'],
      assumptions: ['Knowledge and skills continue to improve'],
      requiredActions: ['Complete knowledge assessments', 'Practice skills'],
      riskFactors: ['Knowledge gaps widen'],
    );
  }

  /// Project completion forecast.
  ForecastPrediction _projectCompletionForecast(
      GrowthSnapshot snap, int days) {
    final projScore = snap.projects.score;
    final trend = snap.projects.trend.name;
    final growthRate = _trendToGrowthRate(trend);
    const recoveryDays = 90;
    final timeFactor = (days / recoveryDays).clamp(0.0, 1.0);
    final predicted = projScore + ((1.0 - projScore) * growthRate * timeFactor);
    final improvement = predicted - projScore;

    return ForecastPrediction(
      type: ForecastType.projectCompletion,
      timelineDays: days,
      currentValue: projScore * 100,
      predictedValue: (predicted * 100).clamp(0.0, 100.0),
      improvement: improvement * 100,
      confidence: _computeConfidence(snap, 0.55, 0.45,
          score: projScore),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Project Score',
      unit: '%',
      dependencies: ['Portfolio growth progress'],
      assumptions: ['Projects are started and completed'],
      requiredActions: ['Start new projects', 'Complete existing projects'],
      riskFactors: ['Project scope creep', 'Losing motivation'],
    );
  }

  /// Learning streak forecast based on habit consistency.
  ForecastPrediction _learningStreakForecast(
      GrowthSnapshot snap, int days) {
    final habitScore = snap.habits.score;
    final trend = snap.habits.trend.name;
    final growthRate = _trendToGrowthRate(trend);
    // Streak grows based on habit consistency
    const maxStreak = 365;
    final currentStreak = (habitScore * maxStreak).round();
    final dailyGrowth = habitScore * growthRate;
    final predictedStreak = (currentStreak + (dailyGrowth * days)).clamp(0.0, maxStreak.toDouble());
    final improvement = predictedStreak - currentStreak;

    return ForecastPrediction(
      type: ForecastType.learningStreak,
      timelineDays: days,
      currentValue: currentStreak.toDouble(),
      predictedValue: predictedStreak.toDouble(),
      improvement: improvement,
      confidence: _computeConfidence(snap, 0.6, 0.5,
          score: habitScore, history: snap.history.daily.length),
      estimatedDate: DateTime.now().add(Duration(days: days)),
      label: 'Learning Streak',
      unit: 'days',
      assumptions: ['Current habit consistency is maintained'],
      requiredActions: ['Complete daily habits', 'Never skip two days in a row'],
      riskFactors: ['Missed days break streaks', 'Motivation drops'],
    );
  }

  // ── Milestone Predictions ─────────────────────────────────────────

  /// Predicts unlock milestones based on current trajectory.
  List<ForecastMilestone> _computeMilestones(GrowthSnapshot snap, DateTime now) {
    final milestones = <ForecastMilestone>[];

    // Next level milestone
    final xpPerLevel = snap.currentLevel * 250;
    final xpInCurrentLevel = snap.totalXp - ((snap.currentLevel - 1) * 250);
    final xpNeeded = xpPerLevel - xpInCurrentLevel;
    final dailyXp = snap.totalXp / 30.0;
    if (dailyXp > 0 && xpNeeded > 0) {
      final daysToNextLevel = (xpNeeded / dailyXp).ceil();
      milestones.add(ForecastMilestone(
        title: 'Level ${snap.currentLevel + 1}',
        description: 'Earn $xpNeeded more XP to reach the next level.',
        predictedDate: now.add(Duration(days: daysToNextLevel)),
        confidence: _confidenceFromDays(daysToNextLevel),
        daysRemaining: daysToNextLevel,
        prerequisites: [
          'Earn $xpNeeded XP through missions and activities'
        ],
        iconName: 'level_up',
      ));
    }

    // Knowledge mastery milestone
    if (snap.knowledge.score < 0.8) {
      final gap = 0.8 - snap.knowledge.score;
      final dailyGrowth = 0.01 * _trendToGrowthRate(snap.knowledge.trend.name);
      if (dailyGrowth > 0) {
        final daysToMastery = (gap / dailyGrowth).ceil();
        milestones.add(ForecastMilestone(
          title: 'Knowledge Mastery',
          description: 'Reach 80% knowledge proficiency.',
          predictedDate: now.add(Duration(days: daysToMastery)),
          confidence: _confidenceFromDays(daysToMastery),
          daysRemaining: daysToMastery,
          prerequisites: ['Consistent daily learning'],
          iconName: 'school',
        ));
      }
    }

    // Career readiness milestone
    if (snap.career.score < 0.7) {
      final gap = 0.7 - snap.career.score;
      final dailyGrowth = 0.008 * _trendToGrowthRate(snap.career.trend.name);
      if (dailyGrowth > 0) {
        final daysToCareer = (gap / dailyGrowth).ceil();
        milestones.add(ForecastMilestone(
          title: 'Career Ready',
          description: 'Reach 70% career readiness.',
          predictedDate: now.add(Duration(days: daysToCareer)),
          confidence: _confidenceFromDays(daysToCareer),
          daysRemaining: daysToCareer,
          prerequisites: [
            'Build portfolio',
            'Practice interviews',
            'Update resume',
          ],
          iconName: 'work',
        ));
      }
    }

    // Interview ready milestone
    if (snap.interview.score < 0.7) {
      final gap = 0.7 - snap.interview.score;
      final dailyGrowth = 0.01 * _trendToGrowthRate(snap.interview.trend.name);
      if (dailyGrowth > 0) {
        final daysToInterview = (gap / dailyGrowth).ceil();
        milestones.add(ForecastMilestone(
          title: 'Interview Ready',
          description: 'Reach 70% interview readiness.',
          predictedDate: now.add(Duration(days: daysToInterview)),
          confidence: _confidenceFromDays(daysToInterview),
          daysRemaining: daysToInterview,
          prerequisites: ['Achieve career readiness'],
          iconName: 'record_voice_over',
        ));
      }
    }

    // Portfolio strength milestone
    if (snap.portfolio.score < 0.7) {
      final gap = 0.7 - snap.portfolio.score;
      final dailyGrowth = 0.007 * _trendToGrowthRate(snap.portfolio.trend.name);
      if (dailyGrowth > 0) {
        final daysToPortfolio = (gap / dailyGrowth).ceil();
        milestones.add(ForecastMilestone(
          title: 'Strong Portfolio',
          description: 'Reach 70% portfolio completeness.',
          predictedDate: now.add(Duration(days: daysToPortfolio)),
          confidence: _confidenceFromDays(daysToPortfolio),
          daysRemaining: daysToPortfolio,
          prerequisites: ['Complete more projects'],
          iconName: 'folder',
        ));
      }
    }

    // Sort by predicted date
    milestones.sort((a, b) => a.predictedDate.compareTo(b.predictedDate));
    return milestones;
  }

  // ── Confidence Computation ────────────────────────────────────────

  /// Computes a deterministic confidence score (0-100).
  ForecastConfidence _computeConfidence(
    GrowthSnapshot snap,
    double baseConfidence,
    double stabilityWeight, {
    double score = 0.5,
    int history = 0,
  }) {
    // Data quality: how much data exists
    final dataQuality = (snap.history.daily.length / 30).clamp(0.0, 1.0);

    // Trend stability: higher for improving/stable, lower for declining
    final trendStability = score >= 0.3 ? 0.7 : 0.3;

    // Sample size: more history = better
    final sampleSize = (history / 14).clamp(0.0, 1.0);

    // Combined score
    final combined = (baseConfidence * 0.3) +
        (dataQuality * 0.25) +
        (trendStability * 0.25) +
        (sampleSize * 0.2);

    final overall = (combined * 100).round().clamp(0, 100);

    return ForecastConfidence(
      overall: overall,
      dataQuality: dataQuality,
      trendStability: trendStability,
      sampleSize: sampleSize,
    );
  }

  /// Simplified confidence from days remaining.
  int _confidenceFromDays(int days) {
    if (days < 30) return 75;
    if (days < 90) return 60;
    if (days < 180) return 45;
    return 30;
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /// Converts a trend name to a deterministic growth rate multiplier.
  double _trendToGrowthRate(String trend) {
    switch (trend) {
      case 'improving':
        return 1.2;
      case 'stable':
        return 1.0;
      case 'declining':
        return 0.6;
      default:
        return 0.8;
    }
  }
}
