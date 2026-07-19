/// Shared enums for the Interview Intelligence module.
///
/// All enums are pure Dart — no Flutter dependencies.
library;

/// Difficulty levels for interview questions and sessions.
enum InterviewDifficulty {
  easy('Easy', 0.25),
  medium('Medium', 0.50),
  hard('Hard', 0.75),
  expert('Expert', 1.0);

  const InterviewDifficulty(this.label, this.weight);
  final String label;
  final double weight;
}

/// Types of actionable recommendations.
enum InterviewActionType {
  practice('Practice Mock Interview'),
  study('Study Weak Topic'),
  reviewResume('Review Resume'),
  improvePortfolio('Improve Portfolio'),
  completeMission('Complete Mission'),
  learnSkill('Learn Skill'),
  retryPractice('Retry Practice'),
  takeAssessment('Take Assessment'),
  watchTutorial('Watch Tutorial'),
  readArticle('Read Article');

  const InterviewActionType(this.label);
  final String label;
}

/// Categories of interview feedback.
enum InterviewFeedbackType {
  technical('Technical'),
  behavioral('Behavioral'),
  communication('Communication'),
  confidence('Confidence'),
  preparation('Preparation'),
  overall('Overall');

  const InterviewFeedbackType(this.label);
  final String label;
}

/// Categories of interview questions.
enum InterviewQuestionCategory {
  technical('Technical'),
  behavioral('Behavioral'),
  scenario('Scenario'),
  coding('Coding'),
  projectDiscussion('Project Discussion'),
  resumeBased('Resume-Based');

  const InterviewQuestionCategory(this.label);
  final String label;
}

/// Severity of a weak topic.
enum WeakTopicSeverity {
  critical('Critical', 1.0),
  high('High', 0.75),
  medium('Medium', 0.50),
  low('Low', 0.25);

  const WeakTopicSeverity(this.label, this.weight);
  final String label;
  final double weight;
}

/// Status of a mock interview session.
enum SessionStatus {
  notStarted('Not Started'),
  inProgress('In Progress'),
  completed('Completed'),
  evaluated('Evaluated'),
  cancelled('Cancelled');

  const SessionStatus(this.label);
  final String label;
}
