/// Priority level for a learning adaptation.
enum AdaptationPriority {
  critical('Critical', 90),
  high('High', 70),
  medium('Medium', 50),
  low('Low', 30),
  optional('Optional', 10);

  const AdaptationPriority(this.displayName, this.minScore);

  final String displayName;
  final int minScore;
}
