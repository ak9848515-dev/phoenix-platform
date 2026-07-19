/// Market insight about the user's career alignment with industry demand.
///
/// Provides awareness of market trends, salary ranges, in-demand skills,
/// and competitive positioning.
class CareerMarketInsight {
  const CareerMarketInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.impact = 0.0,
    this.confidence = 0.5,
    this.relatedSkills = const [],
    this.source,
  });

  /// Unique identifier.
  final String id;

  /// Insight type: 'demand', 'trend', 'salary', 'competition',
  /// 'growth', 'requirement', 'certification'.
  final String type;

  /// Short title.
  final String title;

  /// Detailed description.
  final String description;

  /// Impact on career readiness (0.0-1.0).
  final double impact;

  /// Confidence in this insight (0.0-1.0).
  final double confidence;

  /// Skills related to this insight.
  final List<String> relatedSkills;

  /// Data source for this insight.
  final String? source;

  /// Human-readable type label.
  String get typeLabel {
    switch (type) {
      case 'demand':
        return 'Market Demand';
      case 'trend':
        return 'Industry Trend';
      case 'salary':
        return 'Salary Insight';
      case 'competition':
        return 'Competitive Position';
      case 'growth':
        return 'Growth Opportunity';
      case 'requirement':
        return 'Key Requirement';
      case 'certification':
        return 'Certification';
      default:
        return type;
    }
  }

  /// Icon name for display.
  String get iconName {
    switch (type) {
      case 'demand':
        return 'trending_up';
      case 'trend':
        return 'show_chart';
      case 'salary':
        return 'attach_money';
      case 'competition':
        return 'equalizer';
      case 'growth':
        return 'rocket_launch';
      case 'requirement':
        return 'checklist';
      case 'certification':
        return 'verified';
      default:
        return 'info';
    }
  }

  @override
  String toString() =>
      'CareerMarketInsight($type: $title, impact: $impact)';
}
