import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/daily_journey/models/daily_journey_snapshot.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_brief_snapshot.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_snapshot.dart';

/// Tests for DailyJourneySnapshot model.
void main() {
  group('DailyJourneySnapshot', () {
    const brief = DailyBriefSnapshot(
      date: '2025-01-15',
      todaysFocus: 'Complete Flutter Fundamentals',
      todaysMission: 'Build a weather app',
      todaysGoal: 'Become a Flutter Developer',
    );

    const journey = JourneySnapshot(
      currentJourney: 'Flutter Developer Path',
      currentStage: 'Fundamentals',
      completionPercent: 0.35,
    );

    test('creates with default values', () {
      const snap = DailyJourneySnapshot(
        dailyBrief: brief,
        journey: journey,
      );
      expect(snap.todaysFocus, 'Complete Flutter Fundamentals');
      expect(snap.todaysMission, 'Build a weather app');
      expect(snap.todaysGoal, 'Become a Flutter Developer');
      expect(snap.journey.currentJourney, 'Flutter Developer Path');
      expect(snap.journeyCompletion, 0.35);
      expect(snap.todaysFocus, isNotEmpty);
    });

    test('hasData reflects provided data', () {
      const snapWith = DailyJourneySnapshot(
        dailyBrief: brief,
        journey: journey,
        hasData: true,
      );
      expect(snapWith.hasData, isTrue);

      const snapWithout = DailyJourneySnapshot(
        dailyBrief: brief,
        journey: journey,
        hasData: false,
      );
      expect(snapWithout.hasData, isFalse);
    });

    test('computes dailyCompletionPercent from brief', () {
      const snap = DailyJourneySnapshot(
        dailyBrief: brief,
        journey: journey,
      );
      expect(snap.dailyCompletionPercent, brief.completionPercent);
    });

    test('plan delegates to brief', () {
      const snap = DailyJourneySnapshot(
        dailyBrief: brief,
        journey: journey,
      );
      expect(snap.plan.total, brief.plan.total);
    });

    test('resumePoint delegates to journey', () {
      const snap = DailyJourneySnapshot(
        dailyBrief: brief,
        journey: journey,
      );
      expect(snap.resumePoint, journey.resumePoint);
    });

    test('default scores are zero when snapshots are null', () {
      const snap = DailyJourneySnapshot(
        dailyBrief: brief,
        journey: journey,
      );
      expect(snap.interviewReadiness, 0.0);
      expect(snap.opportunityMatchScore, 0.0);
      expect(snap.resumeHealthScore, 0.0);
      expect(snap.portfolioScore, 0.0);
    });

    test('toString returns readable representation', () {
      const snap = DailyJourneySnapshot(
        dailyBrief: brief,
        journey: journey,
      );
      expect(snap.toString(), contains('Flutter'));
    });
  });
}
