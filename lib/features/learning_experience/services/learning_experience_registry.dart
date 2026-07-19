import '../models/learning_experience.dart';

/// Registry of [LearningExperience] contracts.
///
/// Stores generated learning experiences for persistence, retrieval,
/// and version tracking. Supports backward-compatible schema evolution.
///
/// **Architecture Rules:**
/// - Contracts are immutable once registered
/// - Future versions must remain backward compatible
/// - No feature modifies registered contracts
class LearningExperienceRegistry {
  final Map<String, LearningExperience> _experiences = {};
  final List<String> _history = [];

  /// Registers a new learning experience.
  void register(LearningExperience experience) {
    _experiences[experience.goal.id] = experience;
    _history.add(experience.goal.id);
  }

  /// Gets a learning experience by goal ID.
  LearningExperience? get(String goalId) => _experiences[goalId];

  /// Gets the most recently registered experience.
  LearningExperience? get latest {
    if (_history.isEmpty) return null;
    return _experiences[_history.last];
  }

  /// Gets all registered experiences.
  List<LearningExperience> get all =>
      _history.map((id) => _experiences[id]!).toList();

  /// Gets experiences by schema version.
  List<LearningExperience> getByVersion(int version) =>
      all.where((e) => e.metadata.schemaVersion == version).toList();

  /// Gets the total count of registered experiences.
  int get count => _experiences.length;

  /// Whether an experience with the given ID exists.
  bool hasExperience(String goalId) => _experiences.containsKey(goalId);

  /// Clears all experiences (for testing).
  void clear() {
    _experiences.clear();
    _history.clear();
  }

  @override
  String toString() =>
      'LearningExperienceRegistry(experiences: $count, latest: ${latest?.goal.title ?? "none"})';
}
