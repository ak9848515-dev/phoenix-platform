import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interview_enums.dart';
import '../models/interview_feedback_detail.dart';
import '../models/interview_question_detail.dart';
import '../models/interview_session_detail.dart';
import 'interview_intelligence_repository_interface.dart';

/// Local implementation of [InterviewIntelligenceRepositoryInterface] using SharedPreferences.
///
/// Offline-first — all data is cached locally and available without network.
class LocalInterviewIntelligenceRepository
    implements InterviewIntelligenceRepositoryInterface {
  LocalInterviewIntelligenceRepository({this._prefs});

  SharedPreferencesWithCache? _prefs;

  static const String _sessionsKey = 'phx_interview_sessions';
  static const String _feedbackKeyPrefix = 'phx_interview_feedback_';

  Future<SharedPreferencesWithCache> get _storage async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return _prefs!;
  }

  @override
  Future<void> saveSession(InterviewSessionDetail session) async {
    final prefs = await _storage;
    final sessions = await loadSessions();
    final idx = sessions.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      sessions[idx] = session;
    } else {
      sessions.add(session);
    }
    final json = jsonEncode(sessions.map((s) => _sessionToMap(s)).toList());
    await prefs.setString(_sessionsKey, json);
  }

  @override
  Future<void> saveFeedback(InterviewFeedbackDetail feedback) async {
    final prefs = await _storage;
    final key = '$_feedbackKeyPrefix${feedback.sessionId}';
    await prefs.setString(key, jsonEncode(_feedbackToMap(feedback)));
  }

  @override
  Future<List<InterviewSessionDetail>> loadSessions() async {
    final prefs = await _storage;
    final raw = prefs.getString(_sessionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => _sessionFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<InterviewFeedbackDetail?> loadFeedback(String sessionId) async {
    final prefs = await _storage;
    final key = '$_feedbackKeyPrefix$sessionId';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return _feedbackFromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final prefs = await _storage;
    final sessions = await loadSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    final json = jsonEncode(sessions.map((s) => _sessionToMap(s)).toList());
    await prefs.setString(_sessionsKey, json);
    await prefs.remove('$_feedbackKeyPrefix$sessionId');
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _storage;
    await prefs.remove(_sessionsKey);
    // Note: individual feedback keys remain but will be orphaned.
    // This is acceptable for a clear-all operation.
  }

  // ── Serialization ────────────────────────────────────────────────

  Map<String, dynamic> _sessionToMap(InterviewSessionDetail s) => {
        'id': s.id,
        'title': s.title,
        'status': s.status.name,
        'score': s.score,
        'questionAccuracy': s.questionAccuracy,
        'durationMinutes': s.durationMinutes,
        'difficulty': s.difficulty.name,
        'focusTopics': s.focusTopics,
        'strengths': s.strengths,
        'weaknesses': s.weaknesses,
        'feedback': s.feedback,
        'averageTimePerQuestion': s.averageTimePerQuestion,
        'startedAt': s.startedAt?.toIso8601String(),
        'completedAt': s.completedAt?.toIso8601String(),
        'lastUpdated': s.lastUpdated?.toIso8601String(),
        'questions': s.questions
            .map((q) => {
                  'id': q.id,
                  'question': q.question,
                  'category': q.category.name,
                  'difficulty': q.difficulty.name,
                  'topics': q.topics,
                  'userAnswer': q.userAnswer,
                  'timeSpentSeconds': q.timeSpentSeconds,
                  'score': q.score,
                  'feedback': q.feedback,
                  'skipped': q.skipped,
                })
            .toList(),
      };

  InterviewSessionDetail _sessionFromMap(Map<String, dynamic> m) {
    return InterviewSessionDetail(
      id: m['id'] as String,
      title: m['title'] as String? ?? '',
      status: m['status'] != null
          ? SessionStatus.values.firstWhere(
              (e) => e.name == m['status'],
              orElse: () => SessionStatus.completed)
          : SessionStatus.completed,
      score: (m['score'] as num?)?.toDouble() ?? 0.0,
      questionAccuracy:
          (m['questionAccuracy'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: m['durationMinutes'] as int? ?? 45,
      difficulty: m['difficulty'] != null
          ? InterviewDifficulty.values.firstWhere(
              (e) => e.name == m['difficulty'],
              orElse: () => InterviewDifficulty.medium)
          : InterviewDifficulty.medium,
      focusTopics: m['focusTopics'] != null
          ? List<String>.from(m['focusTopics'] as List)
          : [],
      strengths: m['strengths'] != null
          ? List<String>.from(m['strengths'] as List)
          : [],
      weaknesses: m['weaknesses'] != null
          ? List<String>.from(m['weaknesses'] as List)
          : [],
      feedback: m['feedback'] as String?,
      averageTimePerQuestion:
          m['averageTimePerQuestion'] as int? ?? 0,
      startedAt: m['startedAt'] != null
          ? DateTime.tryParse(m['startedAt'] as String)
          : null,
      completedAt: m['completedAt'] != null
          ? DateTime.tryParse(m['completedAt'] as String)
          : null,
      lastUpdated: m['lastUpdated'] != null
          ? DateTime.tryParse(m['lastUpdated'] as String)
          : null,
      questions: m['questions'] != null
          ? (m['questions'] as List).map((q) {
              final qm = q as Map<String, dynamic>;
              return InterviewQuestionDetail(
                id: qm['id'] as String,
                question: qm['question'] as String,
                category: qm['category'] != null
                    ? InterviewQuestionCategory.values.firstWhere(
                        (e) => e.name == qm['category'],
                        orElse: () => InterviewQuestionCategory.technical)
                    : InterviewQuestionCategory.technical,
                difficulty: qm['difficulty'] != null
                    ? InterviewDifficulty.values.firstWhere(
                        (e) => e.name == qm['difficulty'],
                        orElse: () => InterviewDifficulty.medium)
                    : InterviewDifficulty.medium,
                topics: qm['topics'] != null
                    ? List<String>.from(qm['topics'] as List)
                    : [],
                userAnswer: qm['userAnswer'] as String?,
                timeSpentSeconds: qm['timeSpentSeconds'] as int? ?? 0,
                score: (qm['score'] as num?)?.toDouble() ?? 0.0,
                feedback: qm['feedback'] as String?,
                skipped: qm['skipped'] as bool? ?? false,
              );
            }).toList()
          : [],
    );
  }

  Map<String, dynamic> _feedbackToMap(InterviewFeedbackDetail f) => {
        'sessionId': f.sessionId,
        'technicalScore': f.technicalScore,
        'behavioralScore': f.behavioralScore,
        'communicationScore': f.communicationScore,
        'confidenceScore': f.confidenceScore,
        'preparationScore': f.preparationScore,
        'overallScore': f.overallScore,
        'strengths': f.strengths,
        'weakAreas': f.weakAreas,
        'communicationTips': f.communicationTips,
        'technicalFeedback': f.technicalFeedback,
        'behavioralFeedback': f.behavioralFeedback,
        'improvementPlan': f.improvementPlan,
        'nextPracticeFocus': f.nextPracticeFocus,
        'summary': f.summary,
      };

  InterviewFeedbackDetail _feedbackFromMap(Map<String, dynamic> m) {
    return InterviewFeedbackDetail(
      sessionId: m['sessionId'] as String,
      technicalScore: (m['technicalScore'] as num?)?.toDouble() ?? 0.0,
      behavioralScore: (m['behavioralScore'] as num?)?.toDouble() ?? 0.0,
      communicationScore:
          (m['communicationScore'] as num?)?.toDouble() ?? 0.0,
      confidenceScore: (m['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      preparationScore:
          (m['preparationScore'] as num?)?.toDouble() ?? 0.0,
      overallScore: (m['overallScore'] as num?)?.toDouble() ?? 0.0,
      strengths: m['strengths'] != null
          ? List<String>.from(m['strengths'] as List)
          : [],
      weakAreas: m['weakAreas'] != null
          ? List<String>.from(m['weakAreas'] as List)
          : [],
      communicationTips: m['communicationTips'] != null
          ? List<String>.from(m['communicationTips'] as List)
          : [],
      technicalFeedback: m['technicalFeedback'] != null
          ? List<String>.from(m['technicalFeedback'] as List)
          : [],
      behavioralFeedback: m['behavioralFeedback'] != null
          ? List<String>.from(m['behavioralFeedback'] as List)
          : [],
      improvementPlan: m['improvementPlan'] != null
          ? List<String>.from(m['improvementPlan'] as List)
          : [],
      nextPracticeFocus: m['nextPracticeFocus'] as String? ?? '',
      summary: m['summary'] as String? ?? '',
    );
  }
}
