import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/opportunity/models/opportunity.dart';
import 'package:phoenix_platform/features/opportunity/models/opportunity_gap.dart';
import 'package:phoenix_platform/features/opportunity/models/opportunity_match.dart';
import 'package:phoenix_platform/features/opportunity/models/opportunity_requirement.dart';

void main() {
  group('OpportunityRequirement', () {
    const req = OpportunityRequirement(
      skill: 'Dart',
      isRequired: true,
      isMatched: true,
    );

    test('creates with default values', () {
      const minimal = OpportunityRequirement(skill: 'Test');
      expect(minimal.isRequired, isTrue);
      expect(minimal.isMatched, isFalse);
    });

    test('copyWith replaces fields', () {
      final copy = req.copyWith(isMatched: false);
      expect(copy.isMatched, isFalse);
      expect(copy.skill, 'Dart');
    });

    test('equality works', () {
      const same = OpportunityRequirement(
        skill: 'Dart',
        isRequired: true,
        isMatched: true,
      );
      expect(req, same);
    });
  });

  group('OpportunityGap', () {
    const gap = OpportunityGap(
      skill: 'System Design',
      severity: 0.8,
      action: 'Study',
    );

    test('creates with default values', () {
      const minimal = OpportunityGap(skill: 'Test');
      expect(minimal.severity, 0.5);
      expect(minimal.action, '');
    });

    test('copyWith replaces fields', () {
      final copy = gap.copyWith(severity: 0.5);
      expect(copy.severity, 0.5);
      expect(copy.skill, 'System Design');
    });

    test('equality works', () {
      const same = OpportunityGap(
        skill: 'System Design',
        severity: 0.8,
        action: 'Study',
      );
      expect(gap, same);
    });
  });

  group('OpportunityMatch', () {
    const match = OpportunityMatch(opportunityId: 'opp-1', matchScore: 0.75);

    test('creates with default values', () {
      expect(match.requirements, isEmpty);
      expect(match.gaps, isEmpty);
      expect(match.matchedCount, 0);
      expect(match.unmatchedCount, 0);
    });

    test('matched and unmatched counts work', () {
      final withReqs = match.copyWith(
        requirements: [
          const OpportunityRequirement(skill: 'A', isMatched: true),
          const OpportunityRequirement(skill: 'B', isMatched: false),
        ],
      );
      expect(withReqs.matchedCount, 1);
      expect(withReqs.unmatchedCount, 1);
    });

    test('equality uses id', () {
      const same = OpportunityMatch(opportunityId: 'opp-1');
      expect(match, same);
    });
  });

  group('Opportunity', () {
    const opp = Opportunity(id: 'opp-1', title: 'Junior Dev', matchScore: 0.8);

    test('creates with default values', () {
      expect(opp.type, OpportunityType.fullTimeJob);
      expect(opp.requiredSkills, isEmpty);
      expect(opp.matchedSkills, isEmpty);
      expect(opp.missingSkills, isEmpty);
      expect(opp.recommendedActions, isEmpty);
    });

    test('equality uses id', () {
      const same = Opportunity(id: 'opp-1', title: 'Other');
      expect(opp, same);

      const different = Opportunity(id: 'opp-2', title: 'Other');
      expect(opp, isNot(different));
    });

    test('toString returns readable representation', () {
      expect(opp.toString(), contains('opp-1'));
      expect(opp.toString(), contains('0.8'));
    });
  });
}
