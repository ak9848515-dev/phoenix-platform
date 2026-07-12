import '../models/memory_entry.dart';

/// Provides sample memory entries for the Memory Screen.
///
/// This is a presentation-only service. No persistence, AI, or business
/// logic is included.
class MemoryService {
  const MemoryService();

  /// Returns a list of sample memory entries ordered by timestamp descending.
  List<MemoryEntry> getSampleMemories() => <MemoryEntry>[
    MemoryEntry(
      id: 'memory-001',
      title: 'Started Phoenix Platform',
      description:
          'Began building the Phoenix Personal Growth Operating System '
          'as a Flutter application.',
      category: MemoryCategory.project,
      timestamp: DateTime(2026, 7, 1, 9, 0).millisecondsSinceEpoch,
      relatedIdentity: 'identity-flutter-developer',
      relatedMission: null,
      importance: 1.0,
      tags: <String>['phoenix', 'flutter', 'project-start'],
      source: 'system',
      isPinned: true,
    ),
    MemoryEntry(
      id: 'memory-002',
      title: 'Completed OOP Module',
      description:
          'Finished the Object-Oriented Programming module in the '
          'Software Engineering learning path.',
      category: MemoryCategory.learning,
      timestamp: DateTime(2026, 6, 28, 14, 30).millisecondsSinceEpoch,
      relatedIdentity: 'identity-software-engineer',
      relatedMission: 'mission-daily',
      importance: 0.8,
      tags: <String>['oop', 'learning', 'module-complete'],
      source: 'system',
      isPinned: false,
    ),
    MemoryEntry(
      id: 'memory-003',
      title: 'Built First Flutter App',
      description:
          'Published the first version of a cross-platform Flutter '
          'application to test the development workflow.',
      category: MemoryCategory.achievement,
      timestamp: DateTime(2026, 6, 20, 16, 0).millisecondsSinceEpoch,
      relatedIdentity: 'identity-flutter-developer',
      relatedMission: null,
      importance: 0.9,
      tags: <String>['flutter', 'first-app', 'milestone'],
      source: 'user',
      isPinned: true,
    ),
    MemoryEntry(
      id: 'memory-004',
      title: 'Completed First Mission',
      description:
          'Successfully completed the onboarding sprint mission '
          'and unlocked the next learning path level.',
      category: MemoryCategory.mission,
      timestamp: DateTime(2026, 6, 15, 10, 0).millisecondsSinceEpoch,
      relatedIdentity: null,
      relatedMission: 'mission-daily',
      importance: 0.7,
      tags: <String>['mission', 'onboarding', 'complete'],
      source: 'system',
      isPinned: false,
    ),
    MemoryEntry(
      id: 'memory-005',
      title: 'Started SAP Journey',
      description:
          'Enrolled in the SAP Consultant identity path to learn '
          'enterprise business processes and SAP modules.',
      category: MemoryCategory.career,
      timestamp: DateTime(2026, 6, 10, 8, 0).millisecondsSinceEpoch,
      relatedIdentity: 'identity-sap-consultant',
      relatedMission: null,
      importance: 0.85,
      tags: <String>['sap', 'career', 'new-path'],
      source: 'user',
      isPinned: false,
    ),
    MemoryEntry(
      id: 'memory-006',
      title: 'Decided to Learn Flutter',
      description:
          'Made the decision to invest time in mastering Flutter '
          'for cross-platform mobile development.',
      category: MemoryCategory.decision,
      timestamp: DateTime(2026, 6, 5, 20, 0).millisecondsSinceEpoch,
      relatedIdentity: 'identity-flutter-developer',
      relatedMission: null,
      importance: 0.75,
      tags: <String>['flutter', 'decision', 'learning-path'],
      source: 'user',
      isPinned: false,
    ),
    MemoryEntry(
      id: 'memory-007',
      title: 'Weekly Reflection: June Week 1',
      description:
          'Reflected on the first week of June. Key insight: '
          'consistency matters more than intensity.',
      category: MemoryCategory.reflection,
      timestamp: DateTime(2026, 6, 7, 21, 0).millisecondsSinceEpoch,
      relatedIdentity: null,
      relatedMission: null,
      importance: 0.5,
      tags: <String>['reflection', 'weekly', 'insight'],
      source: 'user',
      isPinned: false,
    ),
    MemoryEntry(
      id: 'memory-008',
      title: 'Business Idea Validation',
      description:
          'Validated a product idea with 10 potential customers. '
          'Received positive feedback on the core concept.',
      category: MemoryCategory.business,
      timestamp: DateTime(2026, 5, 25, 11, 0).millisecondsSinceEpoch,
      relatedIdentity: 'identity-entrepreneur',
      relatedMission: null,
      importance: 0.8,
      tags: <String>['business', 'validation', 'mvp'],
      source: 'user',
      isPinned: false,
    ),
  ];

  /// Returns memories sorted by timestamp (newest first).
  List<MemoryEntry> getTimeline() {
    final memories = getSampleMemories();
    memories.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    );
    return memories;
  }

  /// Returns the most recent memories up to [count].
  List<MemoryEntry> getRecentMemories({int count = 3}) =>
      getTimeline().take(count).toList();

  /// Returns only pinned memories.
  List<MemoryEntry> getPinnedMemories() =>
      getSampleMemories().where((m) => m.isPinned).toList();

  /// Returns memories filtered by a specific category.
  List<MemoryEntry> getMemoriesByCategory(MemoryCategory category) =>
      getSampleMemories().where((m) => m.category == category).toList();

  /// Returns a memory by its unique id, or null if not found.
  MemoryEntry? getMemoryById(String id) {
    try {
      return getSampleMemories().firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}