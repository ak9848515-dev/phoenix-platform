/// A career goal being tracked by the user.
///
/// Tracks target role, company, salary expectations, location
/// preferences, timeline, and progress.
class CareerGoal {
  const CareerGoal({
    required this.id,
    this.targetRole = '',
    this.targetCompany = '',
    this.salaryGoal = 0,
    this.currency = 'USD',
    this.location = '',
    this.targetDate,
    this.progress = 0.0,
    this.notes = '',
    this.isPrimary = false,
    this.createdAt,
    this.lastUpdated,
  });

  /// Unique identifier.
  final String id;

  /// Target role title.
  final String targetRole;

  /// Target company name.
  final String targetCompany;

  /// Salary expectation.
  final int salaryGoal;

  /// Currency code.
  final String currency;

  /// Preferred location.
  final String location;

  /// Target date for achieving this goal.
  final DateTime? targetDate;

  /// Progress towards this goal (0.0-1.0).
  final double progress;

  /// User notes.
  final String notes;

  /// Whether this is the primary career goal.
  final bool isPrimary;

  /// When this goal was created.
  final DateTime? createdAt;

  /// When this goal was last updated.
  final DateTime? lastUpdated;

  /// Formatted salary string (e.g., "$120,000 USD").
  String get salaryFormatted {
    final formatter = _formatCurrency(salaryGoal);
    return '$formatter $currency';
  }

  /// Whether the goal has a target date set.
  bool get hasTargetDate => targetDate != null;

  /// Whether the goal has a target company.
  bool get hasTargetCompany => targetCompany.isNotEmpty;

  /// Whether this goal is complete.
  bool get isComplete => progress >= 1.0;

  /// Days remaining until target date (null if no target date).
  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays.clamp(0, 9999);
  }

  @override
  String toString() =>
      'CareerGoal(role: $targetRole, company: $targetCompany, progress: $progress)';

  static String _formatCurrency(int amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k';
    }
    return '\$$amount';
  }
}
