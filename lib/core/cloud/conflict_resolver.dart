/// Strategy for resolving data conflicts during cloud sync.
enum MergeStrategy {
  /// Local changes always win (last writer wins).
  lastWriteWins,

  /// Attempt to merge changes from both versions.
  merge,

  /// Flag for manual user resolution.
  manual;

  /// Human-readable label.
  String get label {
    switch (this) {
      case MergeStrategy.lastWriteWins:
        return 'Last Write Wins';
      case MergeStrategy.merge:
        return 'Merge';
      case MergeStrategy.manual:
        return 'Manual Resolution';
    }
  }
}

/// Tracks version information for conflict detection.
class VersionTracker {
  const VersionTracker({
    this.version = 0,
    this.lastModified,
    this.lastSynced,
    this.checksum = '',
  });

  /// Monotonic version number (incremented on each local change).
  final int version;

  /// When this data was last modified locally.
  final DateTime? lastModified;

  /// When this data was last successfully synced.
  final DateTime? lastSynced;

  /// MD5 or SHA checksum of the serialized data.
  final String checksum;

  /// Whether this version is newer than [other].
  bool isNewerThan(VersionTracker other) => version > other.version;

  /// Creates a copy with updated fields.
  VersionTracker copyWith({
    int? version,
    DateTime? lastModified,
    DateTime? lastSynced,
    String? checksum,
  }) {
    return VersionTracker(
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
      lastSynced: lastSynced ?? this.lastSynced,
      checksum: checksum ?? this.checksum,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VersionTracker && other.checksum == checksum;

  @override
  int get hashCode => checksum.hashCode;

  @override
  String toString() =>
      'VersionTracker(version: $version, checksum: $checksum)';
}

/// Resolves data conflicts detected during cloud sync.
///
/// Supports three strategies:
/// - [MergeStrategy.lastWriteWins]: most recent modification wins
/// - [MergeStrategy.merge]: intelligent field-level merge
/// - [MergeStrategy.manual]: flag for user to resolve
///
/// **Architecture Rules:**
/// - Pure computation — no persistence, no networking
/// - Deterministic — same inputs always produce same result
class ConflictResolver {
  const ConflictResolver({
    this.defaultStrategy = MergeStrategy.lastWriteWins,
  });

  /// Default strategy when none is specified.
  final MergeStrategy defaultStrategy;

  /// Resolves a conflict between local and cloud versions.
  ///
  /// Returns the resolved data and whether the resolution was automatic.
  ConflictResolution resolve({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> cloudData,
    required VersionTracker localVersion,
    required VersionTracker cloudVersion,
    MergeStrategy? strategy,
  }) {
    final s = strategy ?? defaultStrategy;

    switch (s) {
      case MergeStrategy.lastWriteWins:
        return _resolveLastWriteWins(localData, cloudData, localVersion, cloudVersion);
      case MergeStrategy.merge:
        return _resolveMerge(localData, cloudData);
      case MergeStrategy.manual:
        return ConflictResolution(
          resolved: localData,
          source: 'manual',
          isAutomatic: false,
          strategyUsed: MergeStrategy.manual,
        );
    }
  }

  /// Last write wins: most recent modification wins.
  ConflictResolution _resolveLastWriteWins(
    Map<String, dynamic> localData,
    Map<String, dynamic> cloudData,
    VersionTracker localVersion,
    VersionTracker cloudVersion,
  ) {
    final localTime = localVersion.lastModified ?? DateTime(2000);
    final cloudTime = cloudVersion.lastModified ?? DateTime(2000);

    if (localTime.isAfter(cloudTime)) {
      return ConflictResolution(
        resolved: localData,
        source: 'local',
        isAutomatic: true,
        strategyUsed: MergeStrategy.lastWriteWins,
      );
    }

    return ConflictResolution(
      resolved: cloudData,
      source: 'cloud',
      isAutomatic: true,
      strategyUsed: MergeStrategy.lastWriteWins,
    );
  }

  /// Merge: field-level merge, local additions preserved.
  ConflictResolution _resolveMerge(
    Map<String, dynamic> localData,
    Map<String, dynamic> cloudData,
  ) {
    final merged = Map<String, dynamic>.from(cloudData);
    var changed = false;

    // Local additions that don't exist in cloud → keep local
    for (final entry in localData.entries) {
      if (!cloudData.containsKey(entry.key)) {
        merged[entry.key] = entry.value;
        changed = true;
      }
    }

    return ConflictResolution(
      resolved: merged,
      source: changed ? 'merged' : 'cloud',
      isAutomatic: true,
      strategyUsed: MergeStrategy.merge,
    );
  }
}

/// Result of a conflict resolution operation.
class ConflictResolution {
  const ConflictResolution({
    required this.resolved,
    required this.source,
    required this.isAutomatic,
    required this.strategyUsed,
  });

  /// The resolved data after conflict handling.
  final Map<String, dynamic> resolved;

  /// Which source contributed most to the resolution.
  final String source;

  /// Whether the resolution was automatic (no manual input needed).
  final bool isAutomatic;

  /// The strategy that was used.
  final MergeStrategy strategyUsed;
}
