/// An AI-generated or deterministic insight about the user's portfolio.
///
/// Insights highlight strengths, weaknesses, gaps, and recommendations
/// with a clear priority and actionable suggestion.
class PortfolioInsight {
  const PortfolioInsight({
    required this.id,
    required this.type,
    required this.message,
    required this.importance,
    this.category,
    this.suggestion,
    this.impact,
  });

  /// Unique identifier.
  final String id;

  /// Insight type: 'strength', 'weakness', 'gap', 'recommendation',
  /// 'warning', 'opportunity', 'achievement', 'trend'.
  final String type;

  /// Human-readable insight message.
  final String message;

  /// Importance score (0.0-1.0).
  final double importance;

  /// Category this insight relates to (e.g., 'Backend', 'Testing', 'Cloud').
  final String? category;

  /// Actionable suggestion to address this insight.
  final String? suggestion;

  /// Estimated score impact if addressed (0.0-1.0).
  final double? impact;

  /// The icon name for this insight type.
  String get iconName {
    switch (type) {
      case 'strength':
        return 'strength';
      case 'weakness':
        return 'weakness';
      case 'gap':
        return 'gap';
      case 'recommendation':
        return 'recommendation';
      case 'warning':
        return 'warning';
      case 'opportunity':
        return 'opportunity';
      case 'achievement':
        return 'achievement';
      case 'trend':
        return 'trend';
      default:
        return 'info';
    }
  }

  @override
  String toString() =>
      'PortfolioInsight($type: $message, importance: $importance)';
}
