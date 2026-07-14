import 'dart:convert';

/// Trend analysis for a habit over a specific period.
///
/// Immutable. Produced by [HabitEngine.trendAnalysis].
class HabitTrend {
  const HabitTrend({
    required this.habitId,
    required this.period,
    this.direction = TrendDirection.stable,
    this.percentage = 0.0,
    this.completionRate = 0.0,
    this.averageRate = 0.0,
    this.dataPoints = const [],
    this.comparison,
  });

  /// ID of the habit.
  final String habitId;

  /// The period this trend covers.
  final TrendPeriod period;

  /// Direction of the trend.
  final TrendDirection direction;

  /// Change percentage (e.g. 15.0 = 15% increase).
  final double percentage;

  /// Current completion rate for this period.
  final double completionRate;

  /// Average completion rate across all periods.
  final double averageRate;

  /// Data points for charting (each is a period + rate).
  final List<TrendDataPoint> dataPoints;

  /// Comparison with previous period.
  final TrendComparison? comparison;

  HabitTrend copyWith({
    String? habitId,
    TrendPeriod? period,
    TrendDirection? direction,
    double? percentage,
    double? completionRate,
    double? averageRate,
    List<TrendDataPoint>? dataPoints,
    TrendComparison? comparison,
  }) {
    return HabitTrend(
      habitId: habitId ?? this.habitId,
      period: period ?? this.period,
      direction: direction ?? this.direction,
      percentage: percentage ?? this.percentage,
      completionRate: completionRate ?? this.completionRate,
      averageRate: averageRate ?? this.averageRate,
      dataPoints: dataPoints ?? this.dataPoints,
      comparison: comparison ?? this.comparison,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'period': period.name,
      'direction': direction.name,
      'percentage': percentage,
      'completionRate': completionRate,
      'averageRate': averageRate,
      'dataPoints': dataPoints.map((dp) => dp.toMap()).toList(),
      'comparison': comparison?.toMap(),
    };
  }

  factory HabitTrend.fromMap(Map<String, dynamic> map) {
    return HabitTrend(
      habitId: map['habitId'] as String,
      period: TrendPeriod.fromString(map['period'] as String? ?? 'weekly'),
      direction: TrendDirection.fromString(map['direction'] as String? ?? 'stable'),
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 0.0,
      averageRate: (map['averageRate'] as num?)?.toDouble() ?? 0.0,
      dataPoints: (map['dataPoints'] as List?)
              ?.map((dp) => TrendDataPoint.fromMap(
                  Map<String, dynamic>.from(dp as Map)))
              .toList() ??
          [],
      comparison: map['comparison'] != null
          ? TrendComparison.fromMap(
              Map<String, dynamic>.from(map['comparison'] as Map))
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory HabitTrend.fromJson(String source) =>
      HabitTrend.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTrend &&
          other.habitId == habitId &&
          other.period == period;

  @override
  int get hashCode => Object.hash(habitId, period);

  @override
  String toString() =>
      'HabitTrend(habitId: $habitId, period: $period, '
      'direction: $direction, change: ${percentage.toStringAsFixed(1)}%)';
}

/// The period a trend covers.
enum TrendPeriod {
  weekly,
  monthly,
  quarterly,
  yearly;

  String get label {
    switch (this) {
      case TrendPeriod.weekly:
        return 'This Week';
      case TrendPeriod.monthly:
        return 'This Month';
      case TrendPeriod.quarterly:
        return 'This Quarter';
      case TrendPeriod.yearly:
        return 'This Year';
    }
  }

  static TrendPeriod fromString(String value) {
    return TrendPeriod.values.firstWhere(
      (p) => p.name == value,
      orElse: () => TrendPeriod.weekly,
    );
  }
}

/// Direction of a trend.
enum TrendDirection {
  improving,
  declining,
  stable;

  String get label {
    switch (this) {
      case TrendDirection.improving:
        return 'Improving';
      case TrendDirection.declining:
        return 'Declining';
      case TrendDirection.stable:
        return 'Stable';
    }
  }

  static TrendDirection fromString(String value) {
    return TrendDirection.values.firstWhere(
      (d) => d.name == value,
      orElse: () => TrendDirection.stable,
    );
  }
}

/// A single data point in a trend chart.
class TrendDataPoint {
  const TrendDataPoint({
    required this.label,
    required this.rate,
    this.count = 0,
  });

  /// Label for this point (e.g. "Week 3", "Jan").
  final String label;

  /// Completion rate for this point (0.0 - 1.0).
  final double rate;

  /// Number of completions in this period.
  final int count;

  Map<String, dynamic> toMap() => {
        'label': label,
        'rate': rate,
        'count': count,
      };

  factory TrendDataPoint.fromMap(Map<String, dynamic> map) => TrendDataPoint(
        label: map['label'] as String? ?? '',
        rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
        count: map['count'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendDataPoint &&
          other.label == label &&
          other.rate == rate;

  @override
  int get hashCode => Object.hash(label, rate);
}

/// Comparison between two trend periods.
class TrendComparison {
  const TrendComparison({
    required this.previousRate,
    required this.currentRate,
    this.change = 0.0,
  });

  /// Completion rate for the previous period.
  final double previousRate;

  /// Completion rate for the current period.
  final double currentRate;

  /// Change in percentage points.
  final double change;

  bool get isImproving => change > 0;
  bool get isDeclining => change < 0;

  Map<String, dynamic> toMap() => {
        'previousRate': previousRate,
        'currentRate': currentRate,
        'change': change,
      };

  factory TrendComparison.fromMap(Map<String, dynamic> map) => TrendComparison(
        previousRate: (map['previousRate'] as num?)?.toDouble() ?? 0.0,
        currentRate: (map['currentRate'] as num?)?.toDouble() ?? 0.0,
        change: (map['change'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendComparison && other.change == change;

  @override
  int get hashCode => change.hashCode;
}
