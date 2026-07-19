/// Time slot for scheduling daily tasks.
/// Used by [DailyBriefEngine] to organize the user's day.
enum DailySchedule {
  morning('Morning', 0),
  afternoon('Afternoon', 1),
  evening('Evening', 2),
  flexible('Flexible', 3);

  const DailySchedule(this.displayName, this.order);

  final String displayName;
  final int order;
}
