/// Priority level for daily tasks.
/// Used by [DailyBriefEngine] for deterministic scheduling.
enum DailyPriority {
  high('High', 3),
  medium('Medium', 2),
  low('Low', 1);

  const DailyPriority(this.displayName, this.weight);

  final String displayName;
  final int weight;
}
