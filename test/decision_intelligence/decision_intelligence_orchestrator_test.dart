import 'package:flutter_test/flutter_test.dart';

import 'package:phoenix_platform/features/decision_intelligence/models/scored_action.dart';
import 'package:phoenix_platform/features/decision_intelligence/models/decision_intelligence_snapshot.dart';

void main() {
  group('ActionScore', () {
    test('composite is 0.0 for all-zero scores', () {
      final score = const ActionScore();
      expect(score.composite, 0.0);
    });

    test('composite is weighted correctly for perfect scores', () {
      final score = const ActionScore(
        careerImpact: 1.0,
        roi: 1.0,
        momentum: 1.0,
        skillGap: 1.0,
        userGoals: 1.0,
        learningDependency: 1.0,
        deadline: 1.0,
        difficulty: 1.0,
        recentActivity: 1.0,
      );
      expect(score.composite, closeTo(1.0, 0.001));
    });

    test('confidence is high when scores are consistent', () {
      final score = const ActionScore(
        careerImpact: 0.8,
        learningDependency: 0.8,
        deadline: 0.8,
        difficulty: 0.8,
        roi: 0.8,
        skillGap: 0.8,
        momentum: 0.8,
        recentActivity: 0.8,
        userGoals: 0.8,
      );
      expect(score.confidence, greaterThan(0.5));
    });

    test('confidence is low when scores vary widely', () {
      final score = const ActionScore(
        careerImpact: 1.0,
        learningDependency: 1.0,
        deadline: 1.0,
        difficulty: 1.0,
        roi: 1.0,
        skillGap: 0.0,
        momentum: 0.0,
        recentActivity: 0.0,
        userGoals: 0.0,
      );
      expect(score.confidence, lessThan(0.5));
    });

    test('estimatedMinutes scales with difficulty', () {
      expect(const ActionScore(difficulty: 0.1).estimatedMinutes, 5);
      expect(const ActionScore(difficulty: 0.3).estimatedMinutes, 15);
      expect(const ActionScore(difficulty: 0.5).estimatedMinutes, 30);
      expect(const ActionScore(difficulty: 0.7).estimatedMinutes, 60);
      expect(const ActionScore(difficulty: 0.9).estimatedMinutes, 120);
    });
  });

  group('ScoredAction', () {
    final baseScore = const ActionScore(
      careerImpact: 0.7,
      roi: 0.8,
      difficulty: 0.3,
      momentum: 0.6,
    );

    test('isQuickWin returns true for high ROI and low difficulty', () {
      final action = ScoredAction(
        id: 'quick-win',
        title: 'Quick task',
        description: 'A quick win task',
        source: ActionSource.resume,
        score: baseScore,
        reasoning: 'High ROI task',
      );
      expect(action.isQuickWin, isTrue);
    });

    test('isQuickWin returns false for hard tasks', () {
      final action = ScoredAction(
        id: 'hard-task',
        title: 'Hard task',
        description: 'A difficult task',
        source: ActionSource.career,
        score: const ActionScore(roi: 0.8, difficulty: 0.8),
      );
      expect(action.isQuickWin, isFalse);
    });

    test('isLongTermGoal returns true for high career impact and high difficulty', () {
      final action = ScoredAction(
        id: 'long-term',
        title: 'Long goal',
        description: 'A long-term goal',
        source: ActionSource.career,
        score: const ActionScore(careerImpact: 0.8, difficulty: 0.7),
      );
      expect(action.isLongTermGoal, isTrue);
    });

    test('isSuitableForToday returns true when momentum is high', () {
      final action = ScoredAction(
        id: 'today-task',
        title: 'Today task',
        description: 'Suitable for today',
        source: ActionSource.mission,
        score: const ActionScore(momentum: 0.6),
      );
      expect(action.isSuitableForToday, isTrue);
    });
  });

  group('DecisionIntelligenceSnapshot', () {
    final topAction = ScoredAction(
      id: 'top',
      title: 'Top Priority',
      description: 'The best action',
      source: ActionSource.career,
      score: const ActionScore(careerImpact: 0.9),
    );

    final secondAction = ScoredAction(
      id: 'second',
      title: 'Second Priority',
      description: 'Second best action',
      source: ActionSource.interview,
      score: const ActionScore(careerImpact: 0.6),
    );

    test('hasData returns true when initialized with actions', () {
      final snap = DecisionIntelligenceSnapshot(
        topPriority: topAction,
        allScored: [topAction, secondAction],
        isInitialized: true,
      );
      expect(snap.hasData, isTrue);
    });

    test('hasData returns false when not initialized', () {
      final snap = DecisionIntelligenceSnapshot(
        topPriority: ScoredAction(
          id: 'default',
          title: 'Default',
          description: 'Default action',
          source: ActionSource.identity,
          score: const ActionScore(),
        ),
      );
      expect(snap.hasData, isFalse);
    });

    test('hasQuickWins returns true when quickWins is not empty', () {
      final snap = DecisionIntelligenceSnapshot(
        topPriority: topAction,
        quickWins: [topAction],
        isInitialized: true,
      );
      expect(snap.hasQuickWins, isTrue);
    });

    test('hasLongTermGoal returns true when longTermGoal is set', () {
      final snap = DecisionIntelligenceSnapshot(
        topPriority: topAction,
        longTermGoal: secondAction,
        isInitialized: true,
      );
      expect(snap.hasLongTermGoal, isTrue);
    });

    test('top3 returns prioritized actions', () {
      final snap = DecisionIntelligenceSnapshot(
        topPriority: topAction,
        secondPriority: secondAction,
        isInitialized: true,
      );
      expect(snap.top3.length, 2);
      expect(snap.top3[0].id, 'top');
      expect(snap.top3[1].id, 'second');
    });

    test('toString returns readable representation', () {
      final snap = DecisionIntelligenceSnapshot(
        topPriority: topAction,
        allScored: [topAction],
        confidence: 0.8,
        isInitialized: true,
      );
      final str = snap.toString();
      expect(str, contains('Top Priority'));
      expect(str, contains('80%'));
    });
  });

  group('ActionSource', () {
    test('contains all expected engine sources', () {
      expect(ActionSource.values.length, 12);
      expect(ActionSource.values, containsAll([
        ActionSource.career,
        ActionSource.portfolio,
        ActionSource.resume,
        ActionSource.interview,
        ActionSource.opportunity,
        ActionSource.mission,
        ActionSource.growth,
        ActionSource.knowledge,
        ActionSource.recommendation,
        ActionSource.review,
        ActionSource.memory,
        ActionSource.identity,
      ]));
    });

    test('each source has a unique name', () {
      final names = ActionSource.values.map((s) => s.name).toSet();
      expect(names.length, ActionSource.values.length);
    });
  });
}
