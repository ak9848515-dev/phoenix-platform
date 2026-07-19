/// Types of forecasts the Growth Intelligence Engine can produce.
enum ForecastType {
  xp('XP', 'Experience Points'),
  level('Level', 'User Level'),
  missionCompletion('Missions', 'Mission Completion'),
  knowledgeGrowth('Knowledge', 'Knowledge Growth'),
  careerReadiness('Career', 'Career Readiness'),
  portfolioGrowth('Portfolio', 'Portfolio Growth'),
  interviewReadiness('Interview', 'Interview Readiness'),
  assessmentReadiness('Assessment', 'Assessment Readiness'),
  projectCompletion('Projects', 'Project Completion'),
  learningStreak('Streak', 'Learning Streak');

  const ForecastType(this.displayName, this.description);

  final String displayName;
  final String description;
}
