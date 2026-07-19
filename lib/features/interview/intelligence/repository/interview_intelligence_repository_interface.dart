import '../models/interview_session_detail.dart';
import '../models/interview_feedback_detail.dart';

/// Interface for persisting interview intelligence data.
///
/// Follows the same pattern as [LocalCareerRepository] / [LocalPortfolioRepository].
abstract class InterviewIntelligenceRepositoryInterface {
  /// Saves a completed session with its feedback.
  Future<void> saveSession(InterviewSessionDetail session);

  /// Saves feedback for a session.
  Future<void> saveFeedback(InterviewFeedbackDetail feedback);

  /// Loads all saved sessions.
  Future<List<InterviewSessionDetail>> loadSessions();

  /// Loads feedback for a specific session.
  Future<InterviewFeedbackDetail?> loadFeedback(String sessionId);

  /// Deletes a session and its feedback.
  Future<void> deleteSession(String sessionId);

  /// Clears all interview data.
  Future<void> clearAll();
}
