import '../../../features/career/models/career_profile.dart';
import '../../../features/decision/models/decision.dart';
import '../../../features/identity/models/identity.dart';
import '../../../features/journey/models/journey.dart';
import '../../../features/journey/models/journey_stage.dart';
import '../../../features/knowledge_dna/knowledge_dna_engine.dart';
import '../../../features/memory/models/memory_entry.dart';
import '../../../features/mission_engine/mission_progress.dart';
import '../../../features/progress_engine/progress_summary.dart';
import '../../../models/user_settings.dart';

/// Unified snapshot of the user's complete state at a point in time.
///
/// Aggregates data from every Phoenix module — Identity, Journey, Mission,
/// Knowledge DNA, Progress, Memory, Career, Decision, and User Settings —
/// into a single immutable object. This is the "single source of truth" for
/// any consumer that needs the full user picture (e.g. AI context, analytics,
/// OmniRoute).
///
/// Use [PhoenixContextBuilder] to assemble this object from the [Repository]
/// and [ContextService.buildContext] as the convenience API.
class PhoenixContext {
  const PhoenixContext({
    required this.selectedIdentity,
    required this.journey,
    required this.currentStage,
    required this.missionProgress,
    required this.knowledgeDNA,
    required this.progress,
    required this.memories,
    required this.career,
    required this.decision,
    required this.userSettings,
    required this.generatedAt,
  });

  /// The user's selected growth identity.
  final Identity selectedIdentity;

  /// The user's full learning journey.
  final Journey journey;

  /// The current in-progress journey stage.
  final JourneyStage currentStage;

  /// Mission tracking progress (daily/weekly completion).
  final MissionProgress missionProgress;

  /// Knowledge DNA analysis (strengths, weaknesses, scores).
  final KnowledgeDNAEngine knowledgeDNA;

  /// XP, level, streaks, and overall progress summary.
  final ProgressSummary progress;

  /// Memory entries capturing the user's timeline and milestones.
  final List<MemoryEntry> memories;

  /// Career readiness profile.
  final CareerProfile career;

  /// The single highest-impact action for the user's next step.
  final Decision decision;

  /// User preferences (theme, notifications, onboarding state).
  final UserSettings userSettings;

  /// When this context snapshot was generated.
  final DateTime generatedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhoenixContext &&
        other.selectedIdentity == selectedIdentity &&
        other.journey == journey &&
        other.currentStage == currentStage &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(selectedIdentity, journey, currentStage, generatedAt);

  @override
  String toString() {
    return 'PhoenixContext('
        'identity: ${selectedIdentity.title}, '
        'journey: ${journey.title}, '
        'stage: ${currentStage.title}, '
        'generatedAt: $generatedAt'
        ')';
  }
}
