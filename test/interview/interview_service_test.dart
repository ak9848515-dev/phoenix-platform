import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/sample_repository.dart';
import 'package:phoenix_platform/features/interview/models/interview_question.dart';
import 'package:phoenix_platform/features/interview/services/interview_service.dart';

void main() {
  group('InterviewService', () {
    final service = InterviewService(repository: const SampleRepository());

    test('buildProfile returns a non-null profile', () {
      final profile = service.buildProfile();
      expect(profile, isNotNull);
      expect(profile.id, isNotEmpty);
      expect(profile.identityId, isNotEmpty);
    });

    test('readiness score is between 0 and 1', () {
      final profile = service.buildProfile();
      expect(profile.interviewReadiness, greaterThanOrEqualTo(0.0));
      expect(profile.interviewReadiness, lessThanOrEqualTo(1.0));
    });

    test('technical score is between 0 and 1', () {
      final profile = service.buildProfile();
      expect(profile.technicalScore, greaterThanOrEqualTo(0.0));
      expect(profile.technicalScore, lessThanOrEqualTo(1.0));
    });

    test('behavioral score is between 0 and 1', () {
      final profile = service.buildProfile();
      expect(profile.behavioralScore, greaterThanOrEqualTo(0.0));
      expect(profile.behavioralScore, lessThanOrEqualTo(1.0));
    });

    test('communication score is between 0 and 1', () {
      final profile = service.buildProfile();
      expect(profile.communicationScore, greaterThanOrEqualTo(0.0));
      expect(profile.communicationScore, lessThanOrEqualTo(1.0));
    });

    test('has strengths', () {
      final profile = service.buildProfile();
      expect(profile.strengths, isNotEmpty);
    });

    test('has improvement areas', () {
      final profile = service.buildProfile();
      expect(profile.improvementAreas, isNotEmpty);
    });

    test('has recommended topics', () {
      final profile = service.buildProfile();
      expect(profile.recommendedTopics, isNotEmpty);
    });

    test('has mock questions', () {
      final profile = service.buildProfile();
      expect(profile.mockQuestions, isNotEmpty);
      expect(profile.questionCount, greaterThan(0));
    });

    test('has positive estimated preparation days', () {
      final profile = service.buildProfile();
      expect(profile.estimatedPreparationDays, greaterThan(0));
    });

    test('mock questions include technical type', () {
      final profile = service.buildProfile();
      final types = profile.mockQuestions.map((q) => q.questionType).toSet();
      expect(types, contains(QuestionType.technical));
    });

    test('mock questions include behavioral type', () {
      final profile = service.buildProfile();
      final types = profile.mockQuestions.map((q) => q.questionType).toSet();
      expect(types, contains(QuestionType.behavioral));
    });

    test('mock questions have tips', () {
      final profile = service.buildProfile();
      final hasTips = profile.mockQuestions.any((q) => q.tips.isNotEmpty);
      expect(hasTips, isTrue);
    });
  });
}
