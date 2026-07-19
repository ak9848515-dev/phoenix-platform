/// Events that trigger an Identity Engine snapshot refresh.
///
/// Each event corresponds to a platform action that may change the user's
/// identity state. The [IdentityEngine] listens for these events and
/// rebuilds its snapshot when they occur.
enum IdentityEvent {
  /// A mission was completed.
  missionCompleted,

  /// A lesson was completed.
  lessonCompleted,

  /// A project was completed.
  projectCompleted,

  /// An assessment was completed.
  assessmentCompleted,

  /// The user's career profile was updated.
  careerUpdated,

  /// The user's primary goal was updated.
  goalUpdated,

  /// The user's profile/identity was updated.
  profileUpdated,

  /// The user's learning preferences changed.
  learningPreferenceChanged,

  /// A habit was completed.
  habitCompleted,

  /// XP was earned through any activity.
  xpGained,

  /// The user's journey stage progressed.
  stageProgressed,
}

/// Describes an identity event with optional metadata.
class IdentityEventData {
  const IdentityEventData({
    required this.event,
    this.sourceId,
    this.metadata = const {},
  });

  /// The type of event.
  final IdentityEvent event;

  /// Optional ID of the source entity (mission ID, lesson ID, etc.).
  final String? sourceId;

  /// Optional metadata key-value pairs for consumers.
  final Map<String, dynamic> metadata;

  /// Creates a [IdentityEventData] for a mission completion.
  factory IdentityEventData.missionCompleted({
    required String missionId,
    int xpAwarded = 0,
  }) =>
      IdentityEventData(
        event: IdentityEvent.missionCompleted,
        sourceId: missionId,
        metadata: {'xpAwarded': xpAwarded},
      );

  /// Creates a [IdentityEventData] for a lesson completion.
  factory IdentityEventData.lessonCompleted({
    required String lessonId,
    int xpAwarded = 0,
  }) =>
      IdentityEventData(
        event: IdentityEvent.lessonCompleted,
        sourceId: lessonId,
        metadata: {'xpAwarded': xpAwarded},
      );

  /// Creates a [IdentityEventData] for XP gain.
  factory IdentityEventData.xpGained({
    required int amount,
    required String source,
  }) =>
      IdentityEventData(
        event: IdentityEvent.xpGained,
        metadata: {'amount': amount, 'source': source},
      );
}
