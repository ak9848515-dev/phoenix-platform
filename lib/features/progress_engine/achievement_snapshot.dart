/// Immutable snapshot of the user's achievement state.
///
/// Single source of truth for achievement data consumed by Progress,
/// Dashboard, and Profile screens.
///
/// Produced by [AchievementEngine]. Widgets read this snapshot only.
class AchievementSnapshot {
  const AchievementSnapshot({
    this.badges = const [],
    this.milestones = const [],
    this.rewards = const [],
    this.certificates = const [],
    this.totalBadges = 0,
    this.totalMilestones = 0,
    this.totalRewards = 0,
    this.totalCertificates = 0,
    this.recentAchievements = const [],
    this.lastUpdated,
  });

  /// List of earned badge names.
  final List<String> badges;

  /// List of completed milestone titles.
  final List<String> milestones;

  /// List of earned reward descriptions.
  final List<String> rewards;

  /// List of earned certificate titles.
  final List<String> certificates;

  /// Total count of badges.
  final int totalBadges;

  /// Total count of milestones.
  final int totalMilestones;

  /// Total count of rewards.
  final int totalRewards;

  /// Total count of certificates.
  final int totalCertificates;

  /// Recent achievement items (for dashboard display).
  final List<AchievementItem> recentAchievements;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  /// Grand total of all achievements.
  int get totalAchievements =>
      totalBadges + totalMilestones + totalRewards + totalCertificates;

  /// Whether there are any achievements.
  bool get hasAchievements => totalAchievements > 0;

  /// Whether recent achievements exist.
  bool get hasRecentActivity => recentAchievements.isNotEmpty;

  /// Creates a copy with the given fields replaced.
  AchievementSnapshot copyWith({
    List<String>? badges,
    List<String>? milestones,
    List<String>? rewards,
    List<String>? certificates,
    int? totalBadges,
    int? totalMilestones,
    int? totalRewards,
    int? totalCertificates,
    List<AchievementItem>? recentAchievements,
    DateTime? lastUpdated,
  }) {
    return AchievementSnapshot(
      badges: badges ?? this.badges,
      milestones: milestones ?? this.milestones,
      rewards: rewards ?? this.rewards,
      certificates: certificates ?? this.certificates,
      totalBadges: totalBadges ?? this.totalBadges,
      totalMilestones: totalMilestones ?? this.totalMilestones,
      totalRewards: totalRewards ?? this.totalRewards,
      totalCertificates: totalCertificates ?? this.totalCertificates,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() =>
      'AchievementSnapshot(badges: $totalBadges, milestones: $totalMilestones, '
      'total: $totalAchievements)';
}

/// An individual achievement item for UI display.
class AchievementItem {
  const AchievementItem({
    required this.id,
    required this.title,
    this.description,
    this.type = 'achievement',
    this.iconName,
    this.date,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  /// Unique identifier.
  final String id;

  /// Human-readable title.
  final String title;

  /// Optional description.
  final String? description;

  /// Category: 'badge', 'milestone', 'reward', 'certificate', 'achievement'.
  final String type;

  /// Optional icon name for resolution.
  final String? iconName;

  /// When earned (null if not yet earned).
  final DateTime? date;

  /// Whether this achievement is completed.
  final bool isCompleted;

  /// Progress towards completion (0.0–1.0).
  final double progress;

  bool get isBadge => type == 'badge';
  bool get isMilestone => type == 'milestone';
  bool get isReward => type == 'reward';
  bool get isCertificate => type == 'certificate';

  @override
  String toString() => 'AchievementItem(id: $id, title: $title, type: $type)';
}
