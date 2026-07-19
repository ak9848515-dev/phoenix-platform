import 'package:flutter/foundation.dart';

import '../../../../shared/infrastructure/cache/cache_service.dart';
import '../../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../career/engine/career_engine.dart';
import '../../../career/engine/career_snapshot.dart';
import '../../../growth_index/engine/growth_index_engine.dart';
import '../../../growth_index/models/growth_snapshot.dart';
import '../../../identity/engine/identity_engine.dart';
import '../../../identity/models/identity_snapshot.dart';
import '../../../portfolio/engine/portfolio_engine.dart';
import '../../../resume_intelligence/engine/resume_intelligence_engine.dart';
import '../../services/interview_service.dart';
import '../models/interview_analytics.dart';
import '../models/interview_enums.dart';
import '../models/interview_feedback_detail.dart';
import '../models/interview_intelligence_snapshot.dart';
import '../models/interview_progress.dart';
import '../models/interview_question_detail.dart';
import '../models/interview_readiness.dart';
import '../models/interview_recommendation.dart';
import '../models/interview_session_detail.dart';
import '../models/weak_topic.dart';
import '../repository/interview_intelligence_repository_interface.dart';

/// Interview Intelligence Engine — PHX-075.
///
/// Continuously evaluates interview readiness, generates personalized
/// practice sessions, detects weak topics, produces analytics, and
/// delivers an AI Interview Coach experience.
///
/// **Architecture:**
/// ```text
/// InterviewService + CareerEngine + IdentityEngine + GrowthIndexEngine
///   + PortfolioEngine + ResumeIntelligenceEngine
///   ↓
/// InterviewIntelligenceEngine (ChangeNotifier)
///   ↓
/// InterviewIntelligenceSnapshot
///   ↓
/// InterviewScreen | Dashboard | Profile | PhoenixAssistant
/// ```
///
/// **Rules:**
/// - Fully deterministic — no AI, no randomness
/// - All scores are reproducible given the same inputs
/// - Widgets read [snapshot] only
/// - Extends (does not replace) the existing InterviewService
class InterviewIntelligenceEngine extends ChangeNotifier {  InterviewIntelligenceEngine({
    required this.interviewService,
    required this.careerEngine,
    required this.identityEngine,
    required this.growthEngine,
    required this.portfolioEngine,
    required this.resumeEngine,
    this.repository,
    this._cacheService,
  })  : _logger = PhoenixLogger.shared;

  final InterviewService interviewService;
  final CareerEngine careerEngine;
  final IdentityEngine identityEngine;
  final GrowthIndexEngine growthEngine;
  final PortfolioEngine portfolioEngine;
  final ResumeIntelligenceEngine resumeEngine;
  final InterviewIntelligenceRepositoryInterface? repository;
  final CacheService? _cacheService;
  final PhoenixLogger _logger; // initialized via constructor initializer

  bool _isInitialized = false;
  InterviewIntelligenceSnapshot? _cachedSnapshot;
  bool _isBuilding = false;

  // ── Runtime session tracking ──────────────────────────────────────
  final List<InterviewSessionDetail> _sessionHistory = [];
  final List<InterviewFeedbackDetail> _feedbackHistory = [];
  int _sessionCounter = 0;

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current interview intelligence snapshot.
  InterviewIntelligenceSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  /// All recorded sessions (for history views).
  List<InterviewSessionDetail> get sessionHistory =>
      List.unmodifiable(_sessionHistory);

  /// All recorded feedback entries.
  List<InterviewFeedbackDetail> get feedbackHistory =>
      List.unmodifiable(_feedbackHistory);

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine and builds the first snapshot.
  Future<void> init() async {
    // Load persisted sessions from repository
    if (repository != null) {
      try {
        final repo = repository!;
        final sessions = await repo.loadSessions();
        _sessionHistory.addAll(sessions);
        for (final s in sessions) {
          final fb = await repo.loadFeedback(s.id);
          if (fb != null) _feedbackHistory.add(fb);
        }
      } catch (e) {
        _logger.warning('InterviewIntelligenceEngine: load persisted data failed: $e',
            category: LogCategory.engine, source: 'InterviewIntelligenceEngine');
      }
    }

    _cachedSnapshot = _cacheService?.get<InterviewIntelligenceSnapshot>('interview_intel:snapshot');
    _buildSnapshot();
    _isInitialized = true;
    if (_cachedSnapshot != null) {
      _cacheService?.cache('interview_intel:snapshot', _cachedSnapshot, CacheDomain.interview);
    }

    careerEngine.addListener(_onEngineChanged);
    identityEngine.addListener(_onEngineChanged);
    growthEngine.addListener(_onEngineChanged);
    portfolioEngine.addListener(_onEngineChanged);
    resumeEngine.addListener(_onEngineChanged);

    _logger.info('InterviewIntelligenceEngine initialized',
        category: LogCategory.engine, source: 'InterviewIntelligenceEngine');
    notifyListeners();
  }

  /// Refreshes the snapshot from current engine states.
  Future<void> refresh() async {
    _buildSnapshot();
    _cacheService?.cache('interview_intel:snapshot', _cachedSnapshot, CacheDomain.interview);
    _logger.debug('InterviewIntelligenceEngine refreshed',
        category: LogCategory.engine, source: 'InterviewIntelligenceEngine');
    notifyListeners();
  }

  @override
  void dispose() {
    careerEngine.removeListener(_onEngineChanged);
    identityEngine.removeListener(_onEngineChanged);
    growthEngine.removeListener(_onEngineChanged);
    portfolioEngine.removeListener(_onEngineChanged);
    resumeEngine.removeListener(_onEngineChanged);
    super.dispose();
  }

  void _onEngineChanged() {
    if (!_isInitialized || _isBuilding) return;
    _isBuilding = true;
    _buildSnapshot();
    _isBuilding = false;
    notifyListeners();
  }

  // ── Session Management ───────────────────────────────────────────

  /// Creates a new practice session with adaptive questions.
  InterviewSessionDetail createSession({
    String title = 'Mock Interview Practice',
    InterviewDifficulty difficulty = InterviewDifficulty.medium,
    int durationMinutes = 45,
    List<String>? focusTopics,
  }) {
    _sessionCounter++;
    final now = DateTime.now();
    final topics = focusTopics ?? _deriveFocusTopics();

    final session = InterviewSessionDetail(
      id: 'interview_session_$_sessionCounter',
      title: title,
      status: SessionStatus.inProgress,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      focusTopics: topics,
      questions: _generateQuestions(difficulty, topics),
      startedAt: now,
      lastUpdated: now,
    );
    _sessionHistory.add(session);
    _buildSnapshot();
    notifyListeners();
    return session;
  }

  /// Records an answer for a question in the current session.
  InterviewSessionDetail? recordAnswer({
    required String sessionId,
    required String questionId,
    String? answer,
    int timeSpentSeconds = 0,
    double score = 0.0,
    bool skipped = false,
  }) {
    final idx = _sessionHistory.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return null;

    final session = _sessionHistory[idx];
    final qIdx = session.questions.indexWhere((q) => q.id == questionId);
    if (qIdx < 0) return null;

    final updatedQuestions = [...session.questions];
    updatedQuestions[qIdx] = updatedQuestions[qIdx].copyWith(
      userAnswer: answer,
      timeSpentSeconds: timeSpentSeconds,
      score: score,
      skipped: skipped,
    );

    final answered = updatedQuestions.where((q) => q.isAnswered).length;
    final avgTime = answered > 0
        ? updatedQuestions
                .where((q) => q.timeSpentSeconds > 0)
                .fold(0, (int sum, q) => sum + q.timeSpentSeconds) ~/
            answered
        : 0;
    final avgScore = answered > 0
        ? updatedQuestions
                .where((q) => q.score > 0)
                .fold(0.0, (double sum, q) => sum + q.score) /
            answered
        : 0.0;

    final updated = session.copyWith(
      questions: updatedQuestions,
      score: avgScore,
      averageTimePerQuestion: avgTime,
      lastUpdated: DateTime.now(),
    );
    _sessionHistory[idx] = updated;
    _buildSnapshot();
    notifyListeners();
    return updated;
  }

  /// Completes a session and generates feedback.
  InterviewFeedbackDetail completeSession(String sessionId) {
    final idx = _sessionHistory.indexWhere((s) => s.id == sessionId);
    if (idx < 0) {
      return InterviewFeedbackDetail(sessionId: sessionId, summary: 'Session not found.');
    }

    final session = _sessionHistory[idx];
    final now = DateTime.now();

    // Calculate final scores
    final answered = session.questions.where((q) => q.isAnswered).toList();
    final totalQuestions = session.questions.length;
    final answeredCount = answered.length;
    final avgScore =
        answeredCount > 0 ? answered.fold(0.0, (double s, q) => s + q.score) / answeredCount : 0.0;
    final accuracy =
        answeredCount > 0 ? answered.where((q) => q.answeredWell).length / answeredCount : 0.0;

    final strengths = <String>[];
    final weaknesses = <String>[];
    if (avgScore >= 0.7) strengths.add('Strong overall performance');
    if (accuracy >= 0.7) strengths.add('High question accuracy');
    if (answeredCount == totalQuestions) strengths.add('Completed all questions');
    if (answeredCount < totalQuestions) weaknesses.add('${totalQuestions - answeredCount} questions unanswered');
    if (accuracy < 0.5) weaknesses.add('Accuracy needs improvement');
    if (avgScore < 0.5) weaknesses.add('Overall score needs improvement');

    final completed = session.copyWith(
      status: SessionStatus.completed,
      score: avgScore,
      questionAccuracy: accuracy,
      strengths: strengths,
      weaknesses: weaknesses,
      completedAt: now,
      lastUpdated: now,
    );
    _sessionHistory[idx] = completed;

    // Generate feedback
    final feedback = InterviewFeedbackDetail(
      sessionId: sessionId,
      technicalScore: avgScore,
      behavioralScore: (avgScore + 0.1).clamp(0.0, 1.0),
      communicationScore: (avgScore + 0.05).clamp(0.0, 1.0),
      confidenceScore: (accuracy * 0.6 + avgScore * 0.4).clamp(0.0, 1.0),
      preparationScore: (answeredCount / totalQuestions).clamp(0.0, 1.0),
      overallScore: avgScore,
      strengths: strengths,
      weakAreas: weaknesses,
      communicationTips: _generateCommunicationTips(avgScore),
      technicalFeedback: _generateTechnicalFeedback(session.questions),
      improvementPlan: _generateImprovementPlan(weaknesses),
      nextPracticeFocus: weaknesses.isNotEmpty ? weaknesses.first : 'Continue practicing',
      summary: _generateSessionSummary(avgScore, answeredCount, totalQuestions),
    );
    _feedbackHistory.add(feedback);

    // Persist
    _persistSession(completed, feedback);

    _buildSnapshot();
    notifyListeners();
    return feedback;
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  void _buildSnapshot() {
    final career = careerEngine.snapshot ?? const CareerSnapshot();
    final growth = growthEngine.snapshot;
    final identity = identityEngine.snapshot;
    // Subscribed for change notifications — snapshot consumed via buildProfile
    final interviewProfile = interviewService.buildProfile();

    // 1. Readiness
    final readiness = _computeReadiness(career, growth, interviewProfile, identity);

    // 2. Analytics
    final analytics = _computeAnalytics(readiness);

    // 3. Progress
    final progress = _computeProgress();

    // 4. Weak topics
    final weakTopics = _detectWeakTopics();

    // 5. Recommendations
    final recommendations = _generateRecommendations(readiness, weakTopics, career);

    // 6. AI Coach Summary
    final aiSummary = _generateAiCoachSummary(readiness, weakTopics, recommendations);

    // 7. Next best action
    final nextAction = recommendations.isNotEmpty
        ? recommendations.first.title
        : 'Take a mock interview to assess your readiness';

    // 8. Recent sessions (newest first, max 10)
    final recent = _sessionHistory.reversed.take(10).toList();

    _cachedSnapshot = InterviewIntelligenceSnapshot(
      readiness: readiness,
      recentSessions: recent,
      latestFeedback: _feedbackHistory.isNotEmpty ? _feedbackHistory.last : null,
      weakTopics: weakTopics,
      recommendations: recommendations,
      analytics: analytics,
      progress: progress,
      actionItems: recommendations,
      aiCoachSummary: aiSummary,
      nextBestAction: nextAction,
      hasData: _sessionHistory.isNotEmpty || career.hasData,
      lastUpdated: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. READINESS SCORING
  // ═══════════════════════════════════════════════════════════════════

  InterviewReadiness _computeReadiness(
    CareerSnapshot career,
    GrowthSnapshot? growth,
    dynamic interviewProfile,
    IdentitySnapshot? identity,
  ) {
    final knowledgeScore = (growth?.knowledge.score ?? 0.0);
    final projectScore = (growth?.portfolio.score ?? 0.0);
    final resumeScore = career.resumeProgress;
    final portfolioScore = (growth?.portfolio.score ?? 0.0);
    final careerReadinessScore = career.careerScore;
    final previousScore = _feedbackHistory.isNotEmpty
        ? _feedbackHistory.last.overallScore
        : interviewProfile.interviewReadiness;
    final learningProgress = (growth?.knowledge.score ?? 0.0);
    final mockScore = _computeAverageMockScore();
    final confidenceScore = _computeConfidence(career);

    final overall = (
      knowledgeScore * 0.15 +
      projectScore * 0.10 +
      resumeScore * 0.10 +
      portfolioScore * 0.10 +
      careerReadinessScore * 0.15 +
      previousScore * 0.15 +
      learningProgress * 0.05 +
      mockScore * 0.15 +
      confidenceScore * 0.05
    ).clamp(0.0, 1.0);

    return InterviewReadiness(
      overall: overall,
      knowledgeScore: knowledgeScore,
      projectScore: projectScore,
      resumeScore: resumeScore,
      portfolioScore: portfolioScore,
      careerReadinessScore: careerReadinessScore,
      previousInterviewScore: previousScore,
      learningProgressScore: learningProgress,
      mockInterviewScore: mockScore,
      confidenceScore: confidenceScore,
    );
  }

  double _computeAverageMockScore() {
    if (_feedbackHistory.isEmpty) return 0.0;
    final recent = _feedbackHistory.length < 5
        ? _feedbackHistory.toList()
        : _feedbackHistory.sublist(_feedbackHistory.length - 5);
    return recent.fold(0.0, (double s, f) => s + f.overallScore) / recent.length;
  }

  double _computeConfidence(CareerSnapshot career) {
    return (career.interviewReadiness * 0.5 + career.careerScore * 0.5)
        .clamp(0.0, 1.0);
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2. ANALYTICS
  // ═══════════════════════════════════════════════════════════════════

  InterviewAnalytics _computeAnalytics(InterviewReadiness readiness) {
    final recent = _feedbackHistory.reversed.take(10).toList();

    return InterviewAnalytics(
      readinessTrend: [...recent.reversed.map((f) => f.overallScore), readiness.overall],
      readinessLabels: [...recent.reversed.map((_) => ''), 'Current'],
      practiceSessionsCount: _sessionHistory.length,
      questionAccuracyTrend: _sessionHistory
          .where((s) => s.questionAccuracy > 0)
          .map((s) => s.questionAccuracy)
          .toList()
        ..add(readiness.overall),
      confidenceGrowthTrend: [readiness.confidenceScore],
      topicPerformance: _computeTopicPerformance(),
      improvementTimeline: [readiness.overall],
      currentReadiness: readiness,
      readinessChange: _feedbackHistory.length >= 2
          ? _feedbackHistory.last.overallScore -
              _feedbackHistory[_feedbackHistory.length - 2].overallScore
          : 0.0,
      averageScore: _feedbackHistory.isNotEmpty
          ? _feedbackHistory
                  .fold(0.0, (double s, f) => s + f.overallScore) /
              _feedbackHistory.length
          : 0.0,
      weakTopicCount: _detectWeakTopics().length,
    );
  }

  Map<String, double> _computeTopicPerformance() {
    final perf = <String, double>{};
    for (final session in _sessionHistory) {
      for (final q in session.questions) {
        if (q.score > 0) {
          for (final topic in q.topics) {
            perf.update(topic, (v) => (v + q.score) / 2,
                ifAbsent: () => q.score);
          }
        }
      }
    }
    return perf;
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. PROGRESS
  // ═══════════════════════════════════════════════════════════════════

  InterviewProgress _computeProgress() {
    final completed = _sessionHistory.where((s) => s.isCompleted).toList();
    final scores = completed.map((s) => s.score).toList();

    return InterviewProgress(
      totalSessions: _sessionHistory.length,
      completedSessions: completed.length,
      averageScore: scores.isNotEmpty
          ? scores.fold(0.0, (double s, v) => s + v) / scores.length
          : 0.0,
      bestScore: scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 0.0,
      recentScores: scores.reversed.take(10).toList(),
      accuracyTrend: completed.map((s) => s.questionAccuracy).toList(),
      confidenceGrowth: completed.map((s) => s.score * 0.5 + 0.5).toList(),
      topicsCovered: _buildAllTopics(),
      topicsWeak: _detectWeakTopics().map((t) => t.subject).toList(),
      topicsStrong: _buildStrongTopics(),
      improvementRate: _computeImprovementRate(),
      lastPracticedAt: completed.isNotEmpty ? completed.last.completedAt : null,
    );
  }

  List<String> _buildAllTopics() {
    final topics = <String>{};
    for (final session in _sessionHistory) {
      topics.addAll(session.focusTopics);
      for (final q in session.questions) {
        topics.addAll(q.topics);
      }
    }
    return topics.toList();
  }

  List<String> _buildStrongTopics() {
    final perf = _computeTopicPerformance();
    return perf.entries
        .where((e) => e.value >= 0.7)
        .map((e) => e.key)
        .toList();
  }

  double _computeImprovementRate() {
    if (_feedbackHistory.length < 2) return 0.0;
    final recent = _feedbackHistory.take(5).toList();
    if (recent.length < 2) return 0.0;
    final first = recent.last.overallScore;
    final last = recent.first.overallScore;
    return (last - first).clamp(0.0, 1.0);
  }

  // ═══════════════════════════════════════════════════════════════════
  // 4. WEAK TOPIC DETECTION
  // ═══════════════════════════════════════════════════════════════════

  List<WeakTopic> _detectWeakTopics() {
    if (_sessionHistory.isEmpty) return _initialWeakTopics();

    final topicScores = <String, List<double>>{};
    final topicMistakes = <String, List<String>>{};
    final topicMissed = <String, int>{};

    for (final session in _sessionHistory) {
      for (final q in session.questions) {
        for (final topic in q.topics) {
          topicScores.putIfAbsent(topic, () => []).add(q.score);
          if (q.score < 0.5) {
            topicMissed.update(topic, (v) => v + 1, ifAbsent: () => 1);
            if (q.feedback != null) {
              final fb = q.feedback!;
              topicMistakes
                  .putIfAbsent(topic, () => [])
                  .add(fb);
            }
          }
        }
      }
    }

    final weakTopics = <WeakTopic>[];
    for (final entry in topicScores.entries) {
      final avg = entry.value.fold(0.0, (double s, v) => s + v) / entry.value.length;
      if (avg < 0.6) {
        final missed = topicMissed[entry.key] ?? 0;
        final severity = avg < 0.3
            ? WeakTopicSeverity.critical
            : avg < 0.45
                ? WeakTopicSeverity.high
                : WeakTopicSeverity.medium;

        weakTopics.add(WeakTopic(
          subject: entry.key,
          severity: severity,
          repeatedMistakes: topicMistakes[entry.key] ?? [],
          missedCount: missed,
          accuracyRate: avg,
          recommendedLearning: _learningForTopic(entry.key),
          recommendedPractice: _practiceForTopic(entry.key),
        ));
      }
    }

    weakTopics.sort((a, b) => b.severity.weight.compareTo(a.severity.weight));
    return weakTopics.take(5).toList();
  }

  List<WeakTopic> _initialWeakTopics() {
    final profile = interviewService.buildProfile();
    if (profile.improvementAreas.isEmpty) return [];
    return profile.improvementAreas.take(5).map((area) {
      return WeakTopic(
        subject: area,
        severity: WeakTopicSeverity.medium,
        accuracyRate: 0.0,
        recommendedLearning: _learningForTopic(area),
        recommendedPractice: _practiceForTopic(area),
      );
    }).toList();
  }

  List<String> _learningForTopic(String topic) {
    return ['Study $topic fundamentals', 'Complete $topic course'];
  }

  List<String> _practiceForTopic(String topic) {
    return ['Answer $topic practice questions', 'Build a $topic project'];
  }

  // ═══════════════════════════════════════════════════════════════════
  // 5. FOCUS TOPICS DERIVATION
  // ═══════════════════════════════════════════════════════════════════

  List<String> _deriveFocusTopics() {
    final profile = interviewService.buildProfile();
    final weak = _detectWeakTopics();
    final topics = <String>[
      ...weak.map((t) => t.subject),
      ...profile.improvementAreas,
      ...profile.recommendedTopics,
    ];
    return topics.toSet().take(5).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 6. QUESTION GENERATION
  // ═══════════════════════════════════════════════════════════════════

  List<InterviewQuestionDetail> _generateQuestions(
    InterviewDifficulty difficulty,
    List<String> focusTopics,
  ) {
    final questions = <InterviewQuestionDetail>[];
    var counter = 0;

    // Technical questions from focus topics
    for (final topic in focusTopics.take(3)) {
      counter++;
      questions.add(InterviewQuestionDetail(
        id: 'iq_${_sessionCounter}_$counter',
        question: 'Describe your experience with $topic and how you approach challenges in this area.',
        category: InterviewQuestionCategory.technical,
        difficulty: difficulty,
        topics: [topic],
        tips: ['Be specific about your hands-on experience.'],
      ));
    }

    // Behavioral questions
    final behavioralQuestions = [
      ('Tell me about a time you faced a difficult challenge and how you overcame it.',
          'problem solving'),
      ('Describe a situation where you had to work collaboratively on a team project.',
          'teamwork'),
      ('What is your greatest professional weakness and how are you working to improve it?',
          'self-awareness'),
    ];
    for (final (q, topic) in behavioralQuestions.take(2)) {
      counter++;
      questions.add(InterviewQuestionDetail(
        id: 'iq_${_sessionCounter}_$counter',
        question: q,
        category: InterviewQuestionCategory.behavioral,
        difficulty: InterviewDifficulty.medium,
        topics: [topic],
        tips: ['Use the STAR method: Situation, Task, Action, Result.'],
      ));
    }

    // Scenario questions from weak topics
    if (focusTopics.isNotEmpty) {
      counter++;
      questions.add(InterviewQuestionDetail(
        id: 'iq_${_sessionCounter}_$counter',
        question: 'Walk me through how you would approach a project involving ${focusTopics.first}.',
        category: InterviewQuestionCategory.scenario,
        difficulty: difficulty,
        topics: [focusTopics.first],
        tips: ['Think aloud and structure your response.'],
      ));
    }

    // Coding / design question
    counter++;
    questions.add(InterviewQuestionDetail(
      id: 'iq_${_sessionCounter}_$counter',
      question: 'Design a simple system for managing user data. What components would you include and why?',
      category: InterviewQuestionCategory.coding,
      difficulty: difficulty,
      topics: ['system design'],
      tips: ['Start with requirements, discuss trade-offs.'],
    ));

    // Resume-based question
    if (focusTopics.isNotEmpty) {
      counter++;
      final firstTopic = focusTopics.first;
      questions.add(InterviewQuestionDetail(
        id: 'iq_${_sessionCounter}_$counter',
        question: 'How does your experience with $firstTopic align with the requirements of this role?',
        category: InterviewQuestionCategory.resumeBased,
        difficulty: difficulty,
        topics: [firstTopic, 'career alignment'],
        tips: ['Connect your experience to the job description.', 'Highlight measurable outcomes.'],
      ));
    }

    // Project discussion question
    counter++;
    questions.add(InterviewQuestionDetail(
      id: 'iq_${_sessionCounter}_$counter',
      question: 'Walk me through your most recent project from conception to delivery. What was your specific role?',
      category: InterviewQuestionCategory.projectDiscussion,
      difficulty: difficulty,
      topics: ['project experience', 'role'],
      tips: ['Focus on your specific contributions.', 'Discuss challenges and how you overcame them.'],
    ));

    return questions;
  }

  // ═══════════════════════════════════════════════════════════════════
  // 7. RECOMMENDATIONS
  // ═══════════════════════════════════════════════════════════════════

  List<InterviewRecommendation> _generateRecommendations(
    InterviewReadiness readiness,
    List<WeakTopic> weakTopics,
    CareerSnapshot career,
  ) {
    final recs = <InterviewRecommendation>[];

    // Practice from weak topics
    for (final topic in weakTopics.take(3)) {
      recs.add(InterviewRecommendation(
        id: 'rec_practice_${topic.subject.toLowerCase().replaceAll(' ', '_')}',
        title: 'Practice $topic',
        description: 'Focus on ${topic.subject} to improve your interview readiness.',
        actionType: InterviewActionType.practice,
        priority: topic.severity.weight,
        impact: topic.severity.weight * 0.8,
        estimatedMinutes: 30,
        route: '/interview',
        relatedTopics: [topic.subject, ...topic.recommendedLearning],
      ));
    }

    // Study recommendations
    if (readiness.knowledgeScore < 0.5) {
      recs.add(const InterviewRecommendation(
        id: 'rec_study_knowledge',
        title: 'Study Technical Fundamentals',
        description: 'Strengthen your knowledge base with targeted courses.',
        actionType: InterviewActionType.study,
        priority: 0.7,
        impact: 0.6,
        estimatedMinutes: 60,
        route: '/academy',
      ));
    }

    // Resume improvement
    if (readiness.resumeScore < 0.5) {
      recs.add(const InterviewRecommendation(
        id: 'rec_review_resume',
        title: 'Review and Update Resume',
        description: 'A polished resume increases interview call-back rates.',
        actionType: InterviewActionType.reviewResume,
        priority: 0.6,
        impact: 0.5,
        estimatedMinutes: 45,
        route: '/resume',
      ));
    }

    // Portfolio improvement
    if (readiness.portfolioScore < 0.5) {
      recs.add(const InterviewRecommendation(
        id: 'rec_improve_portfolio',
        title: 'Strengthen Your Portfolio',
        description: 'Add more projects to showcase your skills.',
        actionType: InterviewActionType.improvePortfolio,
        priority: 0.5,
        impact: 0.4,
        estimatedMinutes: 120,
        route: '/portfolio',
      ));
    }

    // Career readiness
    if (readiness.careerReadinessScore < 0.4) {
      recs.add(const InterviewRecommendation(
        id: 'rec_define_career',
        title: 'Define Your Career Goal',
        description: 'Clear career direction helps focus interview preparation.',
        actionType: InterviewActionType.learnSkill,
        priority: 0.8,
        impact: 0.7,
        estimatedMinutes: 30,
        route: '/career',
      ));
    }

    // Retry practice if previous sessions were weak
    if (readiness.mockInterviewScore < 0.4 && _sessionHistory.isNotEmpty) {
      recs.add(const InterviewRecommendation(
        id: 'rec_retry_practice',
        title: 'Retry Mock Interview Practice',
        description: 'Consistent practice is key to improvement.',
        actionType: InterviewActionType.retryPractice,
        priority: 0.9,
        impact: 0.9,
        estimatedMinutes: 45,
        route: '/interview',
      ));
    }

    // Always include a general practice recommendation
    recs.add(const InterviewRecommendation(
      id: 'rec_general_practice',
      title: 'Complete a Mock Interview',
      description: 'Regular mock interviews build confidence and reveal gaps.',
      actionType: InterviewActionType.practice,
      priority: 0.5,
      impact: 0.6,
      estimatedMinutes: 45,
      route: '/interview',
    ));

    recs.sort((a, b) => b.priority.compareTo(a.priority));
    return recs.take(8).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 8. AI COACH SUMMARY
  // ═══════════════════════════════════════════════════════════════════

  String _generateAiCoachSummary(
    InterviewReadiness readiness,
    List<WeakTopic> weakTopics,
    List<InterviewRecommendation> recommendations,
  ) {
    final sb = StringBuffer();

    if (readiness.isReady) {
      sb.write('You are interview-ready! ');
    } else if (readiness.needsSignificantPrep) {
      sb.write('You need significant interview preparation. ');
    } else {
      sb.write('You are making progress on interview readiness. ');
    }

    if (readiness.overall > 0) {
      sb.write('Overall readiness: ${(readiness.overall * 100).round()}%. ');
    }

    if (weakTopics.isNotEmpty) {
      sb.write('Focus on: ${weakTopics.take(3).map((t) => t.subject).join(', ')}. ');
    }

    if (readiness.confidenceScore < 0.4) {
      sb.write('Building confidence through more practice will help. ');
    }

    if (recommendations.isNotEmpty) {
      sb.write('Next step: ${recommendations.first.title}.');
    }

    return sb.toString().trim();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 9. FEEDBACK HELPERS
  // ═══════════════════════════════════════════════════════════════════

  List<String> _generateCommunicationTips(double score) {
    if (score >= 0.7) {
      return ['Excellent communication demonstrated.', 'Clear and structured responses.'];
    }
    if (score >= 0.4) {
      return ['Practice structuring responses using STAR method.',
              'Focus on concise answers with specific examples.'];
    }
    return ['Work on articulating thoughts clearly.',
            'Practice with a timer to improve response structure.',
            'Record yourself to identify areas for improvement.'];
  }

  List<String> _generateTechnicalFeedback(List<InterviewQuestionDetail> questions) {
    final feedback = <String>[];
    final technical = questions.where((q) => q.category == InterviewQuestionCategory.technical).toList();
    final lowScoring = technical.where((q) => !q.skipped && q.score < 0.5).toList();

    if (lowScoring.isNotEmpty) {
      feedback.add('Review ${lowScoring.first.topics.join(", ")} concepts.');
    }
    if (technical.any((q) => q.skipped)) {
      feedback.add('Try answering all technical questions, even if unsure.');
    }
    if (technical.every((q) => q.answeredWell)) {
      feedback.add('Strong technical knowledge demonstrated.');
    }
    return feedback;
  }

  List<String> _generateImprovementPlan(List<String> weaknesses) {
    if (weaknesses.isEmpty) {
      return ['Continue practicing to maintain readiness.',
              'Try more difficult questions.',
              'Set a regular practice schedule.'];
    }
    final plan = <String>[];
    for (final w in weaknesses) {
      plan.add('Address: $w');
    }
    plan.add('Schedule another mock interview session.');
    return plan;
  }

  String _generateSessionSummary(double score, int answered, int total) {
    final pct = (score * 100).round();
    if (score >= 0.8) return 'Excellent session! ($pct%) You answered $answered of $total questions well.';
    if (score >= 0.6) return 'Good session. ($pct%) Keep practicing to improve further.';
    if (score >= 0.4) return 'Fair session. ($pct%) Review weak areas before the next session.';
    return 'Needs improvement. ($pct%) Focus on fundamentals and try again.';
  }

  // ═══════════════════════════════════════════════════════════════════
  // 10. PERSISTENCE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _persistSession(
    InterviewSessionDetail session,
    InterviewFeedbackDetail feedback,
  ) async {
    if (repository == null) return;
    try {
      final repo = repository!;
      await repo.saveSession(session);
      await repo.saveFeedback(feedback);
    } catch (e) {
      _logger.warning('InterviewIntelligenceEngine: persist failed: $e',
          category: LogCategory.engine, source: 'InterviewIntelligenceEngine');
    }
  }
}
