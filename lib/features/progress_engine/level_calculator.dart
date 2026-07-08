/// Calculates user level from total XP.
class LevelCalculator {
  const LevelCalculator();

  int calculate(int totalXp) {
    if (totalXp < 250) {
      return 1;
    }

    return 1 + (totalXp ~/ 250);
  }
}
