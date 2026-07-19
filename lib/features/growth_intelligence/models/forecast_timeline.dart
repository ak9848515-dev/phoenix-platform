/// Standard forecast timeline durations in days.
enum ForecastTimeline {
  days7(7, '7 Days', 'Next week'),
  days30(30, '30 Days', 'Next month'),
  days90(90, '90 Days', 'Next quarter'),
  days180(180, '180 Days', 'Next 6 months'),
  days365(365, '365 Days', 'Next year');

  const ForecastTimeline(this.days, this.displayName, this.description);

  /// Number of days in this timeline.
  final int days;

  /// Human-readable label.
  final String displayName;

  /// Friendly description.
  final String description;
}
