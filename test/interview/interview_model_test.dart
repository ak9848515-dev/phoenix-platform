import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/interview/models/interview_feedback.dart';
import 'package:phoenix_platform/features/interview/models/interview_profile.dart';
import 'package:phoenix_platform/features/interview/models/interview_question.dart';
import 'package:phoenix_platform/features/interview/models/interview_session.dart';

void main() {
  group('InterviewQuestion', () {
    const question = InterviewQuestion(
      id: 'q-1',
      question: 'What is Dart?',
      questionType: QuestionType.technical,
      difficulty: 0.5,
      topics: ['Dart'],
      tips: ['Be concise'],
    );

    test('creates with default values', () {
      const minimal = InterviewQuestion(id: 'q0', question: 'Test');
      expect(minimal.questionType, QuestionType.technical);
      expect(minimal.difficulty, 0.5);
      expect(minimal.topics, isEmpty);
      expect(minimal.tips, isEmpty);
      expect(minimal.suggestedAnswer, isNull);
    });

    test('equality uses id only', () {
      const same = InterviewQuestion(id: 'q-1', question: 'What is Dart?');
      expect(question, same);

      const different = InterviewQuestion(id: 'q-2', question: 'Other');
      expect(question, isNot(different));
    });

    test('toString returns readable representation', () {
      expect(question.toString(), contains('q-1'));
    });
  });

  group('InterviewSession', () {
    const session = InterviewSession(
      id: 's-1',
      identityId: 'id-1',
      interviewType: InterviewType.technical,
    );

    test('creates with default values', () {
      expect(session.durationMinutes, 45);
      expect(session.difficulty, 0.5);
      expect(session.score, 0.0);
      expect(session.completed, isFalse);
      expect(session.questions, isEmpty);
    });

    test('equality uses id only', () {
      const same = InterviewSession(id: 's-1', identityId: 'id-1');
      expect(session, same);
    });
  });

  group('InterviewFeedback', () {
    const feedback = InterviewFeedback(
      id: 'f-1',
      sessionId: 's-1',
      overallScore: 0.85,
      summary: 'Good performance',
    );

    test('creates with default values', () {
      expect(feedback.technicalScore, 0.0);
      expect(feedback.behavioralScore, 0.0);
      expect(feedback.communicationScore, 0.0);
      expect(feedback.strengths, isEmpty);
      expect(feedback.improvements, isEmpty);
    });

    test('equality uses id only', () {
      const same = InterviewFeedback(id: 'f-1', sessionId: 's-1');
      expect(feedback, same);
    });
  });

  group('InterviewProfile', () {
    const profile = InterviewProfile(
      id: 'p-1',
      identityId: 'id-1',
      interviewReadiness: 0.75,
    );

    test('creates with default values', () {
      expect(profile.technicalScore, 0.0);
      expect(profile.behavioralScore, 0.0);
      expect(profile.communicationScore, 0.0);
      expect(profile.strengths, isEmpty);
      expect(profile.improvementAreas, isEmpty);
      expect(profile.questionCount, 0);
      expect(profile.estimatedPreparationDays, 0);
    });

    test('questionCount equals mock questions length', () {
      const withQuestions = InterviewProfile(
        id: 'p2',
        identityId: 'id1',
        mockQuestions: [
          InterviewQuestion(id: 'q1', question: 'Q1'),
          InterviewQuestion(id: 'q2', question: 'Q2'),
        ],
      );
      expect(withQuestions.questionCount, 2);
    });

    test('copyWith replaces fields', () {
      final copy = profile.copyWith(interviewReadiness: 0.9);
      expect(copy.interviewReadiness, 0.9);
      expect(copy.id, 'p-1');
    });

    test('equality uses id only', () {
      const same = InterviewProfile(id: 'p-1', identityId: 'id-1');
      expect(profile, same);
    });
  });
}
