/// Calculates XP from completed missions.
class XPCalculator {
  const XPCalculator();

  int calculate(List<int> rewards) {
    return rewards.fold<int>(0, (total, reward) => total + reward);
  }
}
