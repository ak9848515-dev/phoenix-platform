import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../academy/services/academy_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../models/growth_history.dart';
import '../models/growth_metrics.dart';
import '../models/growth_snapshot.dart';
import '../calculators/career_calculator.dart';
import '../calculators/habits_calculator.dart';
import '../calculators/interview_calculator.dart';
import '../calculators/knowledge_calculator.dart';
import '../calculators/learning_consistency_calculator.dart';
import '../calculators/mission_calculator.dart';
import '../calculators/portfolio_calculator.dart';
import '../calculators/projects_calculator.dart';
import '../calculators/skills_calculator.dart';
import '../repository/growth_repository_interface.dart';

/// Single source of truth for user growth measurement across all domains.
///
/// [GrowthIndexEngine] measures progress across 9 dimensions (including
/// LearningConsistency), maintains daily/weekly/monthly history, and
/// produces a cached [GrowthSnapshot] for all consumers.
class GrowthIndexEngine extends ChangeNotifier {
  GrowthIndexEngine({
    required this.repository,
    required UserStateService userStateService,
    KnowledgeCalculator? knowledgeCalculator,
    SkillsCalculator? skillsCalculator,
    ProjectsCalculator? projectsCalculator,
    CareerCalculator? careerCalculator,
    HabitsCalculator? habitsCalculator,
    InterviewCalculator? interviewCalculator,
    MissionCalculator? missionCalculator,
    PortfolioCalculator? portfolioCalculator,
    LearningConsistencyCalculator? learningConsistencyCalculator,
    AcademyService? academyService,
    this._cacheService,
  })  : _userStateService = userStateService,
        _knowledgeCalculator =
            knowledgeCalculator ?? KnowledgeCalculator(),
        _skillsCalculator = skillsCalculator ?? SkillsCalculator(),
        _projectsCalculator = projectsCalculator ?? ProjectsCalculator(),
        _careerCalculator = careerCalculator ?? CareerCalculator(),
        _habitsCalculator = habitsCalculator ?? HabitsCalculator(),
        _interviewCalculator = interviewCalculator ?? InterviewCalculator(),
        _missionCalculator = missionCalculator ?? MissionCalculator(),
        _portfolioCalculator = portfolioCalculator ?? PortfolioCalculator(),
        _learningConsistencyCalculator = learningConsistencyCalculator ??
            LearningConsistencyCalculator(
              userStateService: userStateService,
              academyService: academyService,
            );

  final GrowthRepositoryInterface repository;
  final UserStateService _userStateService;

  final KnowledgeCalculator _knowledgeCalculator;
  final SkillsCalculator _skillsCalculator;
  final ProjectsCalculator _projectsCalculator;
  final CareerCalculator _careerCalculator;
  final HabitsCalculator _habitsCalculator;
  final InterviewCalculator _interviewCalculator;
  final MissionCalculator _missionCalculator;
  final PortfolioCalculator _portfolioCalculator;
  final LearningConsistencyCalculator _learningConsistencyCalculator;
  final CacheService? _cacheService;
  static const String _cacheKey = 'growth:snapshot';

  final PhoenixLogger _logger = PhoenixLogger.shared;
  GrowthSnapshot? _cachedSnapshot;
  bool _isInitialized = false;

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current growth snapshot (may be cached).
  GrowthSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine by loading cached data and building a fresh
  /// snapshot. If no cache exists, builds from calculators only.
  Future<void> init() async {
    _cachedSnapshot = _cacheService?.get<GrowthSnapshot>(_cacheKey);
    _cachedSnapshot ??= await repository.loadCachedSnapshot();
    final fresh = _buildSnapshot();
    if (_cachedSnapshot == null ||
        (fresh.overallScore - _cachedSnapshot!.overallScore).abs() > 0.01) {
      _cachedSnapshot = fresh;
      _cacheService?.cache(_cacheKey, fresh, CacheDomain.journey);
      await repository.cacheSnapshot(fresh);
    }
    _isInitialized = true;
    _logger.info('GrowthIndexEngine initialized',
        category: LogCategory.engine, source: 'GrowthIndexEngine');
    notifyListeners();
  }

  /// Refreshes all growth metrics from calculators and persists.
  Future<void> refresh() async {
    _cachedSnapshot = _buildSnapshot();
    _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.journey);
    await repository.cacheSnapshot(_cachedSnapshot!);
    _logger.info('GrowthIndexEngine refreshed',
        category: LogCategory.engine, source: 'GrowthIndexEngine');
    notifyListeners();
  }

  /// Resets all cached growth data.
  Future<void> reset() async {
    _cachedSnapshot = null;
    _isInitialized = false;
    _cacheService?.invalidate(CacheDomain.journey);
    await repository.clear();
    _logger.info('GrowthIndexEngine reset',
        category: LogCategory.engine, source: 'GrowthIndexEngine');
    notifyListeners();
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  /// Runs all calculators and assembles a [GrowthSnapshot].
  ///
  /// Maintains daily history (appends current metrics, capped at 30) and
  /// aggregates weekly/monthly averages when date boundaries are crossed.
  GrowthSnapshot _buildSnapshot() {
    final now = DateTime.now();

    // Calculate all 9 dimensions
    final knowledge = _knowledgeCalculator.calculate();
    final skills = _skillsCalculator.calculate();
    final projects = _projectsCalculator.calculate();
    final career = _careerCalculator.calculate();
    final habits = _habitsCalculator.calculate();
    final interview = _interviewCalculator.calculate();
    final mission = _missionCalculator.calculate();
    final portfolio = _portfolioCalculator.calculate();
    final learningConsistency = _learningConsistencyCalculator.calculate();

    final allMetrics = [
      knowledge, skills, projects, career,
      habits, interview, mission, portfolio,
      learningConsistency,
    ];

    // Compute overall score: weighted average of all dimensions
    final overallScore = _computeOverallScore(
      allMetrics.map((m) => m.score).toList(),
    );

    // Derive level and XP from UserStateService
    final level = _deriveLevel();
    final totalXp = _deriveTotalXp();

    // ── History maintenance ────────────────────────────────────────────
    final previousHistory = _cachedSnapshot?.history ?? const GrowthHistory();
    final previousTime = _cachedSnapshot?.lastUpdated;

    // Append current metrics to daily list (capped at 30)
    final updatedDaily = List<GrowthMetrics>.from(previousHistory.daily)
      ..addAll(allMetrics);
    if (updatedDaily.length > 30) {
      updatedDaily.removeRange(0, updatedDaily.length - 30);
    }

    // Weekly aggregation: when a week boundary is crossed, compute averages
    var updatedWeekly = List<GrowthMetrics>.from(previousHistory.weekly);
    if (previousTime != null && _crossedWeekBoundary(previousTime, now)) {
      updatedWeekly.addAll(_averageMetrics(allMetrics, 'Weekly'));
      // Keep last 12 weeks
      if (updatedWeekly.length > 12) {
        updatedWeekly.removeRange(0, updatedWeekly.length - 12);
      }
    }

    // Monthly aggregation: when a month boundary is crossed, compute averages
    var updatedMonthly = List<GrowthMetrics>.from(previousHistory.monthly);
    if (previousTime != null && _crossedMonthBoundary(previousTime, now)) {
      updatedMonthly.addAll(_averageMetrics(allMetrics, 'Monthly'));
      // Keep last 12 months
      if (updatedMonthly.length > 12) {
        updatedMonthly.removeRange(0, updatedMonthly.length - 12);
      }
    }

    final history = GrowthHistory(
      daily: updatedDaily,
      weekly: updatedWeekly,
      monthly: updatedMonthly,
    );

    return GrowthSnapshot(
      overallScore: overallScore,
      knowledge: knowledge,
      skills: skills,
      projects: projects,
      career: career,
      habits: habits,
      interview: interview,
      mission: mission,
      portfolio: portfolio,
      learningConsistency: learningConsistency,
      currentLevel: level,
      totalXp: totalXp,
      lastUpdated: now,
      history: history,
    );
  }

  /// Computes a weighted average of all dimension scores.
  double _computeOverallScore(List<double> scores) {
    final nonZero = scores.where((s) => s > 0.0).toList();
    if (nonZero.isEmpty) return 0.0;
    return nonZero.reduce((a, b) => a + b) / nonZero.length;
  }

  /// Derives the current level from [UserStateService].
  int _deriveLevel() => _userStateService.currentState.level;

  /// Derives total XP from [UserStateService].
  int _deriveTotalXp() => _userStateService.currentState.totalXp;

  // ── History helpers ─────────────────────────────────────────────────

  /// Whether [now] is in a different ISO week than [previous].
  bool _crossedWeekBoundary(DateTime previous, DateTime now) {
    // ISO week: Monday-based week number comparison
    final prevWeek = _isoWeekNumber(previous);
    final nowWeek = _isoWeekNumber(now);
    return prevWeek != nowWeek;
  }

  /// Whether [now] is in a different month than [previous].
  bool _crossedMonthBoundary(DateTime previous, DateTime now) {
    return previous.month != now.month || previous.year != now.year;
  }

  /// Computes the ISO 8601 week number for a date.
  int _isoWeekNumber(DateTime date) {
    // Algorithm: find the Monday of the week containing Jan 4
    final jan4 = DateTime(date.year, 1, 4);
    final daysSinceJan4 = date.difference(jan4).inDays;
    final weekNumber = ((daysSinceJan4 + (jan4.weekday - 1)) / 7).floor() + 1;
    return weekNumber;
  }

  /// Computes the average [GrowthMetrics] per dimension from a metrics list.
  ///
  /// Groups metrics by dimension name, averages scores within each group,
  /// and returns one averaged [GrowthMetrics] per unique dimension.
  /// Previous history metadata is preserved from the last matching entry.
  /// The [period] label (e.g. 'Weekly', 'Monthly') is used in the detail string.
  List<GrowthMetrics> _averageMetrics(
    List<GrowthMetrics> metrics,
    String period,
  ) {
    final grouped = <String, List<double>>{};
    for (final m in metrics) {
      final key = m.dimension.name;
      grouped.putIfAbsent(key, () => []).add(m.score);
    }

    final result = <GrowthMetrics>[];
    for (final entry in grouped.entries) {
      final dimName = entry.key;
      final scores = entry.value;
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      // Find the last metric with this dimension for metadata preservation
      final last = metrics.lastWhere(
        (m) => m.dimension.name == dimName,
        orElse: () => metrics.last,
      );
      result.add(GrowthMetrics(
        dimension: last.dimension,
        score: avgScore,
        trend: last.trend,
        previousScore: last.previousScore,
        label: last.label,
        detail: '$period avg of ${scores.length} entries',
      ));
    }
    return result;
  }
}
