import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/sample_repository.dart';
import 'package:phoenix_platform/features/resume/models/resume.dart';
import 'package:phoenix_platform/features/resume/services/resume_service.dart';

void main() {
  group('ResumeService', () {
    final service = ResumeService(repository: const SampleRepository());

    test('buildResume returns a non-null resume', () {
      final resume = service.buildResume();

      expect(resume, isNotNull);
      expect(resume.id, isNotEmpty);
      expect(resume.identityId, isNotEmpty);
    });

    test('resume has a valid type', () {
      final resume = service.buildResume();

      expect(resume.resumeType, isNotNull);
    });

    test('resume has a score between 0 and 1', () {
      final resume = service.buildResume();

      expect(resume.resumeScore, greaterThanOrEqualTo(0.0));
      expect(resume.resumeScore, lessThanOrEqualTo(1.0));
    });

    test('resume has a professional summary', () {
      final resume = service.buildResume();

      expect(resume.professionalSummary, isNotEmpty);
    });

    test('resume has projects', () {
      final resume = service.buildResume();

      expect(resume.projects, isNotEmpty);
    });

    test('resume has skills', () {
      final resume = service.buildResume();

      expect(resume.skills, isNotEmpty);
    });

    test('resume has achievements', () {
      final resume = service.buildResume();

      expect(resume.achievements, isNotEmpty);
    });

    test('resume has career highlights', () {
      final resume = service.buildResume();

      expect(resume.careerHighlights, isNotEmpty);
    });

    test('resume has career readiness', () {
      final resume = service.buildResume();

      expect(resume.careerReadiness, isNotEmpty);
    });

    test('resume has a generatedAt timestamp', () {
      final resume = service.buildResume();

      expect(resume.generatedAt, isNotNull);
    });

    test('resume has a consistent id format', () {
      final resume = service.buildResume();

      expect(resume.id, startsWith('resume-'));
    });

    test('skills have valid proficiency values', () {
      final resume = service.buildResume();

      for (final skill in resume.skills) {
        expect(skill.proficiency, greaterThanOrEqualTo(0.0));
        expect(skill.proficiency, lessThanOrEqualTo(1.0));
      }
    });

    test('projects have titles and descriptions', () {
      final resume = service.buildResume();

      for (final project in resume.projects) {
        expect(project.title, isNotEmpty);
        expect(project.description, isNotEmpty);
      }
    });

    test('career highlights contain relevant information', () {
      final resume = service.buildResume();

      for (final highlight in resume.careerHighlights) {
        expect(highlight, isNotEmpty);
      }
    });

    test('resume type is valid', () {
      // Resume type is derived from the identity title.
      // The sample data identity is 'Flutter Developer', which maps
      // to ResumeType.flutterDeveloper.
      final resume = service.buildResume();

      expect(resume.resumeType, isNotNull);
      expect(ResumeType.values, contains(resume.resumeType));
    });
  });
}
