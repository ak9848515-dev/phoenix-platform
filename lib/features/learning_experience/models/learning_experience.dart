/// Phoenix AI Contract v1.0 — Learning Experience Contract.
///
/// Immutable. Versioned. Backward-compatible schema.
///
/// Represents a complete AI-generated learning experience covering
/// 10 sections: Goal, Mission, Micro Lessons, Project, Assessment,
/// Interview Practice, Revision, Reflection, Next Step, and Metadata.
///
/// **Architecture Rules:**
/// - No feature may introduce an alternate AI response structure
/// - All future AI-generated learning must conform to this contract
/// - The contract is consumed by [LearningExperienceOrchestrator]
///
/// **Backward Compatibility:**
/// Future versions must add fields only — never remove or rename.
class LearningExperience {
  const LearningExperience({
    required this.goal,
    this.mission,
    this.lessons = const [],
    this.project,
    this.assessment,
    this.interview,
    this.revision,
    this.reflection,
    this.nextStep,
    required this.metadata,
  });

  /// SECTION 1: The learning goal and objective.
  final GoalSection goal;

  /// SECTION 2: The primary mission for this experience.
  final MissionSection? mission;

  /// SECTION 3: Micro lessons to teach the topic.
  final List<MicroLesson> lessons;

  /// SECTION 4: A portfolio project to apply learning.
  final ProjectSection? project;

  /// SECTION 5: Assessment to measure understanding.
  final AssessmentSection? assessment;

  /// SECTION 6: Interview practice questions.
  final InterviewSection? interview;

  /// SECTION 7: Revision materials.
  final RevisionSection? revision;

  /// SECTION 8: Reflection prompts.
  final ReflectionSection? reflection;

  /// SECTION 9: What to do next.
  final NextStepSection? nextStep;

  /// SECTION 10: Metadata about this contract.
  final ExperienceMetadata metadata;

  /// Whether this experience has a mission component.
  bool get hasMission => mission != null;

  /// Whether this experience has a project component.
  bool get hasProject => project != null;

  /// Whether this experience has an assessment component.
  bool get hasAssessment => assessment != null;

  /// Whether this experience has interview practice.
  bool get hasInterview => interview != null;

  /// Total estimated duration across all sections (minutes).
  int get totalEstimatedMinutes {
    var total = goal.estimatedMinutes;
    if (mission != null) total += mission!.estimatedMinutes;
    for (final lesson in lessons) {
      total += lesson.estimatedMinutes;
    }
    if (project != null) total += project!.estimatedHours * 60;
    if (assessment != null) total += assessment!.estimatedMinutes;
    if (interview != null) total += interview!.estimatedMinutes;
    if (revision != null) total += revision!.estimatedMinutes;
    return total;
  }

  @override
  String toString() =>
      'LearningExperience(goal: ${goal.title}, '
      'mission: ${mission?.title ?? "none"}, '
      'lessons: ${lessons.length}, '
      'project: ${project?.title ?? "none"}, '
      'totalMinutes: $totalEstimatedMinutes)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 1: Goal
// ═════════════════════════════════════════════════════════════════════

/// The learning goal and objective for this experience.
class GoalSection {
  const GoalSection({
    required this.id,
    required this.title,
    required this.description,
    required this.objective,
    required this.estimatedMinutes,
    this.priority = 'medium',
  });

  /// Unique identifier for this goal.
  final String id;

  /// Short, compelling title for the learning goal.
  final String title;

  /// Detailed description of what this experience covers.
  final String description;

  /// Specific, measurable objective statement.
  final String objective;

  /// Estimated time to complete (minutes).
  final int estimatedMinutes;

  /// Priority level (high, medium, low).
  final String priority;

  @override
  String toString() => 'Goal(id: $id, title: $title, priority: $priority)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 2: Mission
// ═════════════════════════════════════════════════════════════════════

/// The primary mission for a learning experience.
class MissionSection {
  const MissionSection({
    required this.id,
    required this.title,
    required this.description,
    this.objectives = const [],
    this.estimatedMinutes = 30,
    this.difficulty = 'intermediate',
    this.successCriteria = const [],
  });

  /// Unique identifier for this mission.
  final String id;

  /// Compelling, action-oriented mission title.
  final String title;

  /// Description explaining the mission.
  final String description;

  /// Specific learning objectives for this mission.
  final List<String> objectives;

  /// Estimated time to complete (minutes).
  final int estimatedMinutes;

  /// Difficulty level (beginner, intermediate, advanced).
  final String difficulty;

  /// Measurable criteria to determine success.
  final List<String> successCriteria;

  @override
  String toString() =>
      'Mission(id: $id, title: $title, difficulty: $difficulty)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 3: Micro Lessons
// ═════════════════════════════════════════════════════════════════════

/// A single micro lesson within a learning experience.
class MicroLesson {
  const MicroLesson({
    required this.id,
    required this.title,
    required this.summary,
    this.estimatedMinutes = 15,
    this.prerequisites = const [],
    this.content = const [],
  });

  /// Unique identifier for this lesson.
  final String id;

  /// Lesson title.
  final String title;

  /// Brief summary of what the lesson covers.
  final String summary;

  /// Estimated time to complete (minutes).
  final int estimatedMinutes;

  /// Prerequisite lesson IDs.
  final List<String> prerequisites;

  /// Lesson content items (concepts, examples, code snippets).
  final List<String> content;

  @override
  String toString() =>
      'MicroLesson(id: $id, title: $title, min: ${estimatedMinutes}min)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 4: Project
// ═════════════════════════════════════════════════════════════════════

/// A portfolio project to apply what was learned.
class ProjectSection {
  const ProjectSection({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedHours,
    this.deliverables = const [],
    this.technologies = const [],
    this.difficulty = 'intermediate',
  });

  /// Unique identifier for this project.
  final String id;

  /// Project title.
  final String title;

  /// Detailed description of the project.
  final String description;

  /// Estimated effort in hours.
  final int estimatedHours;

  /// Deliverables expected from this project.
  final List<String> deliverables;

  /// Technologies to be used.
  final List<String> technologies;

  /// Difficulty level.
  final String difficulty;

  @override
  String toString() =>
      'Project(id: $id, title: $title, hours: ${estimatedHours}h)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 5: Assessment
// ═════════════════════════════════════════════════════════════════════

/// Assessment to measure understanding.
class AssessmentSection {
  const AssessmentSection({
    required this.id,
    required this.title,
    required this.type,
    this.passingScore = 80,
    this.estimatedMinutes = 15,
    this.questions = const [],
  });

  /// Unique identifier.
  final String id;

  /// Assessment title.
  final String title;

  /// Assessment type (quiz, coding, written, oral).
  final String type;

  /// Minimum score to pass (percentage).
  final int passingScore;

  /// Estimated time to complete (minutes).
  final int estimatedMinutes;

  /// Assessment questions.
  final List<AssessmentQuestion> questions;

  @override
  String toString() =>
      'Assessment(id: $id, type: $type, questions: ${questions.length})';
}

/// A single assessment question.
class AssessmentQuestion {
  const AssessmentQuestion({
    required this.id,
    required this.question,
    this.options = const [],
    this.correctAnswer = '',
    this.explanation = '',
    this.points = 1,
    this.type = 'multiple_choice',
  });

  /// Unique identifier.
  final String id;

  /// The question text.
  final String question;

  /// Answer options (for multiple choice).
  final List<String> options;

  /// The correct answer.
  final String correctAnswer;

  /// Explanation of the correct answer.
  final String explanation;

  /// Point value.
  final int points;

  /// Question type.
  final String type;

  @override
  String toString() => 'Question(id: $id, type: $type, points: $points)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 6: Interview Practice
// ═════════════════════════════════════════════════════════════════════

/// Interview practice questions for career preparation.
class InterviewSection {
  const InterviewSection({
    this.technicalQuestions = const [],
    this.behavioralQuestions = const [],
    this.estimatedMinutes = 30,
  });

  /// Technical interview questions with expected answers.
  final List<InterviewQuestion> technicalQuestions;

  /// Behavioral interview questions with guidance.
  final List<InterviewQuestion> behavioralQuestions;

  /// Estimated time to complete (minutes).
  final int estimatedMinutes;

  /// Total number of questions.
  int get totalQuestions =>
      technicalQuestions.length + behavioralQuestions.length;

  @override
  String toString() =>
      'Interview(technical: ${technicalQuestions.length}, '
      'behavioral: ${behavioralQuestions.length})';
}

/// A single interview question.
class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.question,
    this.expectedAnswer = '',
    this.tips = const [],
    this.difficulty = 'medium',
  });

  /// Unique identifier.
  final String id;

  /// The interview question.
  final String question;

  /// Expected or model answer.
  final String expectedAnswer;

  /// Tips for answering well.
  final List<String> tips;

  /// Difficulty level (easy, medium, hard).
  final String difficulty;

  @override
  String toString() =>
      'InterviewQuestion(id: $id, difficulty: $difficulty)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 7: Revision
// ═════════════════════════════════════════════════════════════════════

/// Revision materials for reinforcing learning.
class RevisionSection {
  const RevisionSection({
    this.keyPoints = const [],
    this.flashCards = const [],
    this.quickReview = '',
    this.estimatedMinutes = 10,
  });

  /// Key points to remember.
  final List<String> keyPoints;

  /// Flash cards for quick review.
  final List<FlashCard> flashCards;

  /// A quick review summary paragraph.
  final String quickReview;

  /// Estimated time to complete (minutes).
  final int estimatedMinutes;

  @override
  String toString() =>
      'Revision(keyPoints: ${keyPoints.length}, cards: ${flashCards.length})';
}

/// A single flash card for revision.
class FlashCard {
  const FlashCard({
    required this.front,
    required this.back,
  });

  /// The question or prompt (front of card).
  final String front;

  /// The answer or explanation (back of card).
  final String back;

  @override
  String toString() => 'FlashCard(front: $front)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 8: Reflection
// ═════════════════════════════════════════════════════════════════════

/// Reflection prompts for the user after completing the experience.
class ReflectionSection {
  const ReflectionSection({
    this.whatWasLearned = const [],
    this.challenges = const [],
    this.confidenceScore = 0.5,
    this.prompts = const [],
  });

  /// What the user should have learned.
  final List<String> whatWasLearned;

  /// Anticipated challenges the user may face.
  final List<String> challenges;

  /// Expected confidence score (0.0–1.0) after completion.
  final double confidenceScore;

  /// Reflection prompts for the user.
  final List<String> prompts;

  @override
  String toString() =>
      'Reflection(confidence: ${(confidenceScore * 100).round()}%)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 9: Next Step
// ═════════════════════════════════════════════════════════════════════

/// Recommended next step after completing this experience.
class NextStepSection {
  const NextStepSection({
    required this.tomorrowObjective,
    this.unlockCondition = '',
    this.suggestedNextExperience = '',
  });

  /// What the user should focus on next session.
  final String tomorrowObjective;

  /// What must be completed before unlocking the next experience.
  final String unlockCondition;

  /// Suggested next learning experience.
  final String suggestedNextExperience;

  @override
  String toString() => 'NextStep(objective: $tomorrowObjective)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 10: Metadata
// ═════════════════════════════════════════════════════════════════════

/// Metadata about the learning experience contract.
class ExperienceMetadata {
  const ExperienceMetadata({
    required this.schemaVersion,
    required this.generatedAt,
    this.provider = '',
    this.promptVersion = '',
    this.templateId = '',
  });

  /// The schema version (currently 1).
  final int schemaVersion;

  /// When this experience was generated.
  final DateTime generatedAt;

  /// Name of the AI provider that generated this content.
  final String provider;

  /// Version of the prompt template used.
  final String promptVersion;

  /// Template ID from the PromptBuilderService.
  final String templateId;

  /// Current schema version constant.
  static const int currentVersion = 1;

  @override
  String toString() =>
      'Metadata(version: $schemaVersion, provider: $provider, '
      'generated: $generatedAt)';
}

// ═════════════════════════════════════════════════════════════════════
// DEFAULT / EMPTY VALUES
// ═════════════════════════════════════════════════════════════════════

/// Default values for testing and empty states.
class LearningExperienceDefaults {
  LearningExperienceDefaults._();

  static const String schemaVersion = '1.0';
  static const int currentContractVersion = 1;
}
