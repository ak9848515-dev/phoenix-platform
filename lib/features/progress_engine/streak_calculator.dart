/// Calculates daily, weekly, and monthly streaks from completed missions.
class StreakCalculator {
  const StreakCalculator();

  int calculateDaily(List<bool> completedStates) => _calculateStreak(completedStates);

  int calculateWeekly(List<bool> completedStates) => _calculateStreak(completedStates);

  int calculateMonthly(List<bool> completedStates) => _calculateStreak(completedStates);

  int _calculateStreak(List<bool> completedStates) {
    return completedStates.where((completed) => completed).length;
  }
}
