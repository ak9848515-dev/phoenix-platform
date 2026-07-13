import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/resume/models/resume.dart';
import 'package:phoenix_platform/features/resume/models/resume_project.dart';
import 'package:phoenix_platform/features/resume/models/resume_section.dart';
import 'package:phoenix_platform/features/resume/models/resume_skill.dart';

void main() {
  group('ResumeType', () {
    test('maps plugin IDs correctly', () {
      expect(
        ResumeType.fromPluginId('software_engineer'),
        ResumeType.softwareEngineer,
      );
      expect(
        ResumeType.fromPluginId('flutter_developer'),
        ResumeType.flutterDeveloper,
      );
      expect(
        ResumeType.fromPluginId('sap_consultant'),
        ResumeType.sapConsultant,
      );
      expect(ResumeType.fromPluginId('unknown'), ResumeType.generic);
      expect(ResumeType.fromPluginId(''), ResumeType.generic);
    });

    test('has correct labels', () {
      expect(ResumeType.generic.label, 'Generic');
      expect(ResumeType.softwareEngineer.label, 'Software Engineer');
      expect(ResumeType.flutterDeveloper.label, 'Flutter Developer');
      expect(ResumeType.sapConsultant.label, 'SAP Consultant');
    });

    test('has correct categories', () {
      expect(ResumeType.generic.category, 'General');
      expect(ResumeType.softwareEngineer.category, 'Technology');
    });
  });

  group('Resume', () {
    const resume = Resume(
      id: 'resume-1',
      identityId: 'identity-1',
      resumeScore: 0.75,
      careerReadiness: 'Building',
    );

    test('creates with default values', () {
      expect(resume.resumeType, ResumeType.generic);
      expect(resume.professionalSummary, '');
      expect(resume.projectCount, 0);
      expect(resume.skillCount, 0);
      expect(resume.achievements, isEmpty);
      expect(resume.careerHighlights, isEmpty);
      expect(resume.technologyStack, isEmpty);
    });

    test('projectCount returns correct count', () {
      const withProjects = Resume(
        id: 'r1',
        identityId: 'id1',
        projects: [
          ResumeProject(title: 'P1', description: 'Desc'),
          ResumeProject(title: 'P2', description: 'Desc'),
        ],
      );
      expect(withProjects.projectCount, 2);
    });

    test('skillCount returns correct count', () {
      const withSkills = Resume(
        id: 'r1',
        identityId: 'id1',
        skills: [
          ResumeSkill(name: 'Dart'),
          ResumeSkill(name: 'Flutter'),
        ],
      );
      expect(withSkills.skillCount, 2);
    });

    test('copyWith replaces fields', () {
      final copy = resume.copyWith(resumeScore: 0.9);
      expect(copy.resumeScore, 0.9);
      expect(copy.id, 'resume-1');
    });

    test('equality works', () {
      const same = Resume(
        id: 'resume-1',
        identityId: 'identity-1',
        resumeScore: 0.75,
        careerReadiness: 'Building',
      );
      expect(resume, same);

      const different = Resume(id: 'other', identityId: 'other');
      expect(resume, isNot(different));
    });

    test('toString returns readable representation', () {
      final str = resume.toString();
      expect(str, contains('Resume'));
      expect(str, contains('0.75'));
    });
  });

  group('ResumeSection', () {
    const section = ResumeSection(
      title: 'Skills',
      items: ['Dart', 'Flutter'],
      icon: 'psychology',
    );

    test('creates with default values', () {
      const minimal = ResumeSection(title: 'Empty');
      expect(minimal.items, isEmpty);
      expect(minimal.icon, isNull);
    });

    test('copyWith replaces fields', () {
      final copy = section.copyWith(title: 'Updated');
      expect(copy.title, 'Updated');
      expect(copy.items, ['Dart', 'Flutter']);
    });

    test('equality works', () {
      const same = ResumeSection(
        title: 'Skills',
        items: ['Dart', 'Flutter'],
        icon: 'psychology',
      );
      expect(section, same);
    });
  });

  group('ResumeSkill', () {
    const skill = ResumeSkill(
      name: 'Dart',
      proficiency: 0.85,
      isStrength: true,
      category: 'Language',
    );

    test('creates with default values', () {
      const minimal = ResumeSkill(name: 'Test');
      expect(minimal.proficiency, 0.0);
      expect(minimal.isStrength, isFalse);
      expect(minimal.category, 'General');
    });

    test('copyWith replaces fields', () {
      final copy = skill.copyWith(proficiency: 0.95);
      expect(copy.proficiency, 0.95);
      expect(copy.name, 'Dart');
    });

    test('equality works', () {
      const same = ResumeSkill(
        name: 'Dart',
        proficiency: 0.85,
        isStrength: true,
        category: 'Language',
      );
      expect(skill, same);
    });
  });

  group('ResumeProject', () {
    const project = ResumeProject(
      title: 'Build API',
      description: 'Built a REST API',
      type: 'project',
      skills: ['Dart'],
      highlights: ['Completed successfully'],
    );

    test('creates with default values', () {
      const minimal = ResumeProject(title: 'Minimal', description: 'Desc');
      expect(minimal.type, 'mission');
      expect(minimal.skills, isEmpty);
      expect(minimal.highlights, isEmpty);
    });

    test('copyWith replaces fields', () {
      final copy = project.copyWith(title: 'Updated');
      expect(copy.title, 'Updated');
      expect(copy.description, 'Built a REST API');
    });

    test('equality works', () {
      const same = ResumeProject(
        title: 'Build API',
        description: 'Built a REST API',
        type: 'project',
        skills: ['Dart'],
        highlights: ['Completed successfully'],
      );
      expect(project, same);
    });
  });
}
