import 'portfolio_enums.dart';

/// Represents a gap between the user's current skills and target career requirements.
class SkillGap {
  const SkillGap({
    required this.id,
    required this.skillName,
    required this.category,
    required this.severity,
    required this.impact,
    this.currentProficiency = 0.0,
    this.targetProficiency = 0.7,
    this.description,
    this.suggestion,
    this.recommendedProjects = const [],
    this.recommendedLearning = const [],
    this.bridgesToClose = const [],
  });

  /// Unique identifier.
  final String id;

  /// Name of the missing or weak skill.
  final String skillName;

  /// Category (e.g., 'Language', 'Framework', 'Cloud', 'Soft Skill').
  final String category;

  /// How critical this gap is.
  final GapSeverity severity;

  /// Impact on portfolio score if closed (0.0-1.0).
  final double impact;

  /// Current proficiency level (0.0-1.0).
  final double currentProficiency;

  /// Target proficiency needed (0.0-1.0).
  final double targetProficiency;

  /// Human-readable description of the gap.
  final String? description;

  /// Suggested next step to close this gap.
  final String? suggestion;

  /// Recommended projects that would demonstrate this skill.
  final List<String> recommendedProjects;

  /// Recommended learning resources or paths.
  final List<String> recommendedLearning;

  /// Other skills that need to be developed first (prerequisites).
  final List<String> bridgesToClose;

  /// How far from target (0.0-1.0).
  double get gapSize => (targetProficiency - currentProficiency).clamp(0.0, 1.0);

  /// Whether this gap is closable with short-term effort.
  bool get isQuickWin => gapSize <= 0.3 && severity != GapSeverity.critical;

  /// Priority score for closing this gap.
  double get priorityScore => impact * severity.weight * (1.0 + gapSize);

  @override
  String toString() =>
      'SkillGap($skillName, severity: ${severity.displayName}, '
      'proficiency: $currentProficiency → $targetProficiency)';
}
