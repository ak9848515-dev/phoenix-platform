/// The 12 deterministic decision types supported by the Decision Intelligence Engine.
///
/// Each type maps to exactly one rule that evaluates the current context
/// and produces a scored recommendation.
enum DecisionType {
  continueMission('Continue Mission',
      'Resume or continue the current active mission'),
  reviewLesson('Review Lesson',
      'Review a recently completed lesson to reinforce retention'),
  startProject('Start Project',
      'Begin a new portfolio project'),
  takeAssessment('Take Assessment',
      'Take an assessment to measure knowledge',
      'assessment'),
  practiceInterview('Practice Interview',
      'Practice interview questions for career preparation'),
  reviseTopic('Revise Topic',
      'Revise a weak topic area identified by the knowledge engine'),
  updateResume('Update Resume',
      'Update your resume with recent skills and projects'),
  improvePortfolio('Improve Portfolio',
      'Add projects, certificates, or achievements to your portfolio'),
  takeBreak('Take Break',
      'Take a short break — your recent activity suggests you need rest',
      'break'),
  restDay('Rest Day',
      'Take a full rest day — extended activity without recovery reduces learning',
      'day_off'),
  exploreTechnology('Explore Technology',
      'Explore a new technology relevant to your career goals'),
  careerAction('Career Action',
      'Take a career-focused action — resume, interview, or networking');

  const DecisionType(this.displayName, this.description, [this.icon = '']);

  /// Human-readable name.
  final String displayName;

  /// Short description of the action.
  final String description;

  /// Optional icon identifier for UI rendering.
  final String icon;
}
