import '../../../services/sample_data_service.dart';
import '../models/recommendation.dart';

/// Provides a curated set of sample recommendations for the Recommendation Screen.
///
/// Recommendations now reference the current Journey stage and Progress level,
/// connecting Recommendation to Journey and Progress.
///
/// Returns only the highest priority recommendations aligned with the user's
/// identity and progress.
///
/// This is a presentation-only service. No AI, APIs, or persistence.
class RecommendationService {
  RecommendationService({SampleDataService? seedSource})
    : seedSource = seedSource ?? const SampleDataService();

  final SampleDataService seedSource;

  /// Returns the full list of sample recommendations.
  ///
  /// Recommendations reference the current Journey stage and user Progress
  /// level, ensuring every recommendation has context from the two key
  /// upstream modules.
  List<Recommendation> getSampleRecommendations() {
    final currentStage = seedSource.currentJourneyStage;
    final journey = seedSource.journey;

    return <Recommendation>[
      Recommendation(
        id: 'rec-001',
        title: 'Complete Async & Futures',
        description:
            'Master Dart async programming with Future, async/await, '
            'and error handling to advance your Dart stage.',
        type: RecommendationType.learning,
        priority: RecommendationPriority.critical,
        estimatedDuration: 35,
        reason:
            'You are in the ${currentStage.title} stage (Stage ${journey.currentStage + 1} of ${journey.stages.length}). '
            'You have completed Dart Syntax and Null Safety. '
            'Async & Futures is your next mission to stay on track.',
        relatedIdentity: seedSource.selectedIdentity.id,
        relatedMission: 'Async & Futures',
        relatedSkill: 'Dart Language',
        actionLabel: 'Continue Learning',
      ),
      Recommendation(
        id: 'rec-002',
        title: 'Daily Reflection',
        description:
            'Spend 10 minutes reflecting on today\'s learning and '
            'capture one key insight.',
        type: RecommendationType.reflection,
        priority: RecommendationPriority.high,
        estimatedDuration: 10,
        reason:
            'Consistent reflection improves retention by over 40%. '
            'You have not reflected today.',
        relatedIdentity: null,
        relatedMission: null,
        relatedSkill: 'Critical Thinking',
        actionLabel: 'Start Reflection',
      ),
      Recommendation(
        id: 'rec-003',
        title: 'Review System Design Patterns',
        description:
            'Revisit the Strategy and Observer patterns you learned '
            'last week to reinforce retention.',
        type: RecommendationType.review,
        priority: RecommendationPriority.high,
        estimatedDuration: 20,
        reason:
            'Reviewing material within 7 days triples long-term retention. '
            'You learned these patterns 5 days ago.',
        relatedIdentity: 'identity-software-engineer',
        relatedMission: 'Design Patterns Sprint',
        relatedSkill: 'System Design',
        actionLabel: 'Review Now',
      ),
      Recommendation(
        id: 'rec-004',
        title: 'Build a Flutter Prototype',
        description:
            'Create a small prototype app to practise state management '
            'with Riverpod in a real project.',
        type: RecommendationType.practice,
        priority: RecommendationPriority.medium,
        estimatedDuration: 60,
        reason:
            'Hands-on practice accelerates skill acquisition by 3x compared '
            'to theory alone. Apply what you\'ve learned.',
        relatedIdentity: seedSource.selectedIdentity.id,
        relatedMission: null,
        relatedSkill: 'State Management',
        actionLabel: 'Start Building',
      ),
      Recommendation(
        id: 'rec-005',
        title: 'Plan Weekly Learning Sprint',
        description:
            'Outline your top 3 learning priorities for the week ahead '
            'and allocate time blocks.',
        type: RecommendationType.mission,
        priority: RecommendationPriority.medium,
        estimatedDuration: 15,
        reason:
            'Users who plan their week are 60% more likely to achieve their '
            'learning goals. Take 15 minutes to set direction.',
        relatedIdentity: null,
        relatedMission: 'Weekly Sprint Plan',
        relatedSkill: null,
        actionLabel: 'Plan Now',
      ),
      Recommendation(
        id: 'rec-006',
        title: 'Explore SAP Basics',
        description:
            'Start the SAP Fundamentals course to build enterprise '
            'consulting skills for your SAP Consultant identity.',
        type: RecommendationType.career,
        priority: RecommendationPriority.low,
        estimatedDuration: 30,
        reason:
            'This aligns with your SAP Consultant identity path. '
            'Early exposure builds momentum for long-term goals.',
        relatedIdentity: 'identity-sap-consultant',
        relatedMission: null,
        relatedSkill: 'SAP FICO / MM / SD',
        actionLabel: 'Explore',
      ),
    ];
  }

  List<Recommendation> getHighPriorityRecommendations() =>
      getSampleRecommendations()
          .where(
            (r) =>
                r.priority == RecommendationPriority.critical ||
                r.priority == RecommendationPriority.high,
          )
          .toList();

  /// Returns the single highest-priority recommendation (today's focus).
  Recommendation? getTodaysFocus() {
    final all = getSampleRecommendations();
    if (all.isEmpty) return null;
    return all.first;
  }

  /// Returns recommendations filtered by type.
  List<Recommendation> getByType(RecommendationType type) =>
      getSampleRecommendations().where((r) => r.type == type).toList();

  /// Returns recommendations related to a specific identity.
  List<Recommendation> getByIdentity(String identityId) =>
      getSampleRecommendations()
          .where((r) => r.relatedIdentity == identityId)
          .toList();
}
