import '../../ai_prompt/models/prompt_specification.dart';
import '../models/field_schema.dart';

/// Registry of versioned JSON field schemas for AI response validation.
///
/// Each schema defines the expected structure, required fields, types,
/// and constraints for AI responses of a given prompt type.
///
/// Schemas are versioned independently so old prompts with old
/// Templates can still have their responses validated correctly.
///
/// **Architecture Rule:**
/// The [SchemaRegistry] is the single source of truth for what
/// constitutes a valid AI response. No feature validates responses
/// independently.
class SchemaRegistry {
  final Map<String, Map<int, List<FieldSchema>>> _schemas = {};

  /// Registers a schema version for a prompt type.
  void register(String promptType, int version, List<FieldSchema> fields) {
    _schemas.putIfAbsent(promptType, () => {});
    _schemas[promptType]![version] = fields;
  }

  /// Gets a schema by prompt type and version.
  List<FieldSchema>? getSchema(String promptType, int version) {
    return _schemas[promptType]?[version];
  }

  /// Gets the latest schema version for a prompt type.
  List<FieldSchema>? getLatest(String promptType) {
    final versions = _schemas[promptType];
    if (versions == null || versions.isEmpty) return null;
    final latestVersion = versions.keys.reduce(
      (a, b) => a > b ? a : b,
    );
    return versions[latestVersion];
  }

  /// Gets the latest version number for a prompt type.
  int? getLatestVersion(String promptType) {
    final versions = _schemas[promptType];
    if (versions == null || versions.isEmpty) return null;
    return versions.keys.reduce((a, b) => a > b ? a : b);
  }

  /// Whether a schema exists for the given prompt type and version.
  bool hasSchema(String promptType, int version) =>
      _schemas[promptType]?.containsKey(version) ?? false;

  /// Registers all built-in schemas.
  void registerDefaults() {
    // ══════════════════════════════════════════════════════════════
    // MISSION v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.mission, 1, [
      FieldSchema.string('mission.title', required: true, maxLength: 200),
      FieldSchema.string('mission.description', required: true, maxLength: 1000),
      FieldSchema.string('mission.category', required: true,
          allowedValues: ['knowledge', 'skill', 'project', 'habit', 'career']),
      FieldSchema.string('mission.difficulty', required: true,
          allowedValues: ['beginner', 'intermediate', 'advanced']),
      FieldSchema.integer('mission.estimatedMinutes', required: true, min: 15, max: 90),
      FieldSchema.integer('mission.rewardXP', required: true, min: 10, max: 100),
      FieldSchema.array('mission.steps', required: true, minItems: 1, maxItems: 10),
      FieldSchema.string('mission.steps[].title', required: true, maxLength: 200),
      FieldSchema.string('mission.steps[].description', maxLength: 500),
      FieldSchema.integer('mission.steps[].estimatedMinutes', min: 5, max: 60),
      FieldSchema.array('mission.prerequisites'),
      FieldSchema.array('mission.successCriteria', required: true, minItems: 1),
      FieldSchema.array('mission.learningObjectives', required: true, minItems: 1),
    ]);

    // ══════════════════════════════════════════════════════════════
    // PROJECT v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.project, 1, [
      FieldSchema.string('project.title', required: true, maxLength: 200),
      FieldSchema.string('project.description', required: true, maxLength: 1000),
      FieldSchema.array('project.technologies', required: true),
      FieldSchema.integer('project.estimatedWeeks', required: true, min: 1, max: 26),
      FieldSchema.string('project.difficulty', required: true,
          allowedValues: ['beginner', 'intermediate', 'advanced']),
      FieldSchema.array('project.milestones', required: true, minItems: 1),
      FieldSchema.string('project.milestones[].title', required: true, maxLength: 200),
      FieldSchema.string('project.milestones[].description', maxLength: 500),
      FieldSchema.integer('project.milestones[].estimatedHours', min: 1, max: 80),
      FieldSchema.array('project.milestones[].deliverables'),
      FieldSchema.array('project.learningOutcomes', required: true),
      FieldSchema.string('project.portfolioImpact', maxLength: 500),
    ]);

    // ══════════════════════════════════════════════════════════════
    // ASSESSMENT v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.assessment, 1, [
      FieldSchema.string('assessment.title', required: true, maxLength: 200),
      FieldSchema.string('assessment.description', required: true, maxLength: 500),
      FieldSchema.string('assessment.difficulty', required: true,
          allowedValues: ['beginner', 'intermediate', 'advanced', 'expert']),
      FieldSchema.integer('assessment.estimatedMinutes', required: true, min: 5, max: 120),
      FieldSchema.integer('assessment.passingScore', required: true, min: 50, max: 100),
      FieldSchema.array('assessment.questions', required: true, minItems: 1, maxItems: 50),
      FieldSchema.string('assessment.questions[].id', required: true),
      FieldSchema.string('assessment.questions[].type', required: true,
          allowedValues: ['multiple_choice', 'true_false', 'short_answer', 'coding']),
      FieldSchema.string('assessment.questions[].question', required: true, maxLength: 1000),
      FieldSchema.array('assessment.questions[].options'),
      FieldSchema.string('assessment.questions[].correctAnswer', required: true, maxLength: 2000),
      FieldSchema.string('assessment.questions[].explanation', maxLength: 1000),
      FieldSchema.integer('assessment.questions[].points', min: 1, max: 100),
      FieldSchema.string('assessment.questions[].skillTested', maxLength: 100),
    ]);

    // ══════════════════════════════════════════════════════════════
    // INTERVIEW v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.interview, 1, [
      FieldSchema.string('interview.targetRole', required: true, maxLength: 100),
      FieldSchema.string('interview.difficulty', required: true,
          allowedValues: ['beginner', 'intermediate', 'advanced']),
      FieldSchema.integer('interview.estimatedMinutes', min: 15, max: 120),
      FieldSchema.array('interview.sections', required: true, minItems: 1, maxItems: 10),
      FieldSchema.string('interview.sections[].name', required: true, maxLength: 100),
      FieldSchema.array('interview.sections[].questions', required: true, minItems: 1),
      FieldSchema.string('interview.sections[].questions[].id', required: true),
      FieldSchema.string('interview.sections[].questions[].type', required: true,
          allowedValues: ['technical', 'behavioral', 'situational']),
      FieldSchema.string('interview.sections[].questions[].question', required: true, maxLength: 1000),
      FieldSchema.string('interview.sections[].questions[].expectedAnswer', maxLength: 2000),
      FieldSchema.array('interview.sections[].questions[].tips'),
      FieldSchema.string('interview.sections[].questions[].difficulty',
          allowedValues: ['easy', 'medium', 'hard']),
      FieldSchema.array('interview.overallTips'),
    ]);

    // ══════════════════════════════════════════════════════════════
    // CAREER COACHING v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.careerCoaching, 1, [
      FieldSchema.string('careerAdvice.summary', required: true, maxLength: 500),
      FieldSchema.string('careerAdvice.topPriority', required: true, maxLength: 200),
      FieldSchema.array('careerAdvice.recommendedActions', required: true, minItems: 1),
      FieldSchema.string('careerAdvice.recommendedActions[].action', required: true, maxLength: 500),
      FieldSchema.string('careerAdvice.recommendedActions[].reason', maxLength: 500),
      FieldSchema.string('careerAdvice.recommendedActions[].estimatedImpact',
          allowedValues: ['high', 'medium', 'low']),
      FieldSchema.string('careerAdvice.recommendedActions[].timeframe',
          allowedValues: ['this week', 'this month', 'this quarter']),
      FieldSchema.array('careerAdvice.skillDevelopment'),
      FieldSchema.array('careerAdvice.marketInsights'),
      FieldSchema.string('careerAdvice.nextMilestone', maxLength: 200),
    ]);

    // ══════════════════════════════════════════════════════════════
    // AI ASSISTANT v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.aiAssistant, 1, [
      FieldSchema.string('response.message', required: true, maxLength: 5000),
      FieldSchema.array('response.suggestedActions'),
      FieldSchema.string('response.suggestedActions[].label', maxLength: 100),
      FieldSchema.string('response.suggestedActions[].action', maxLength: 100),
      FieldSchema.array('response.relatedTopics'),
      FieldSchema.number('response.confidence', min: 0.0, max: 1.0),
    ]);

    // ══════════════════════════════════════════════════════════════
    // DECISION INTELLIGENCE v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.decisionIntelligence, 1, [
      FieldSchema.string('decisionAnalysis.situation', required: true, maxLength: 1000),
      FieldSchema.array('decisionAnalysis.options', required: true, minItems: 2),
      FieldSchema.string('decisionAnalysis.options[].option', required: true, maxLength: 200),
      FieldSchema.array('decisionAnalysis.options[].pros'),
      FieldSchema.array('decisionAnalysis.options[].cons'),
      FieldSchema.string('decisionAnalysis.options[].estimatedOutcome', maxLength: 500),
      FieldSchema.number('decisionAnalysis.options[].confidence', min: 0.0, max: 1.0),
      FieldSchema.string('decisionAnalysis.recommendedOption', required: true, maxLength: 200),
      FieldSchema.string('decisionAnalysis.reasoning', required: true, maxLength: 2000),
      FieldSchema.array('decisionAnalysis.nextSteps'),
    ]);

    // ══════════════════════════════════════════════════════════════
    // LEARNING PATH v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.learningPath, 1, [
      FieldSchema.string('learningPath.title', required: true, maxLength: 200),
      FieldSchema.string('learningPath.description', required: true, maxLength: 1000),
      FieldSchema.integer('learningPath.estimatedWeeks', required: true, min: 1, max: 52),
      FieldSchema.string('learningPath.difficulty', required: true,
          allowedValues: ['beginner', 'intermediate', 'advanced']),
      FieldSchema.array('learningPath.modules', required: true, minItems: 1, maxItems: 20),
      FieldSchema.string('learningPath.modules[].title', required: true, maxLength: 200),
      FieldSchema.string('learningPath.modules[].description', maxLength: 500),
      FieldSchema.integer('learningPath.modules[].estimatedHours', min: 1, max: 100),
      FieldSchema.array('learningPath.modules[].topics'),
      FieldSchema.array('learningPath.modules[].projects'),
      FieldSchema.array('learningPath.modules[].prerequisites'),
      FieldSchema.integer('learningPath.totalEstimatedHours', min: 1, max: 1000),
      FieldSchema.array('learningPath.outcomes', required: true, minItems: 1),
    ]);

    // ══════════════════════════════════════════════════════════════
    // RECOMMENDATION v1
    // ══════════════════════════════════════════════════════════════
    register(PromptType.recommendation, 1, [
      FieldSchema.string('recommendation.title', required: true, maxLength: 200),
      FieldSchema.string('recommendation.description', required: true, maxLength: 500),
      FieldSchema.string('recommendation.priority',
          allowedValues: ['critical', 'high', 'medium', 'low']),
      FieldSchema.string('recommendation.category', maxLength: 100),
      FieldSchema.number('recommendation.confidence', min: 0.0, max: 1.0),
      FieldSchema.string('recommendation.reason', maxLength: 1000),
      FieldSchema.array('recommendation.nextSteps'),
    ]);

    // ══════════════════════════════════════════════════════════════
    // LEARNING EXPERIENCE v1 (full 10-section generation)
    // ══════════════════════════════════════════════════════════════
    register('learning_experience', 1, [
      // Goal section (required)
      FieldSchema.string('experience.goal.id', required: true),
      FieldSchema.string('experience.goal.title', required: true, maxLength: 200),
      FieldSchema.string('experience.goal.description', required: true, maxLength: 1000),
      FieldSchema.string('experience.goal.objective', required: true, maxLength: 500),
      FieldSchema.integer('experience.goal.estimatedMinutes', min: 10, max: 120),
      FieldSchema.string('experience.goal.priority',
          allowedValues: ['high', 'medium', 'low']),
      // Mission section (optional)
      FieldSchema.string('experience.mission.id'),
      FieldSchema.string('experience.mission.title', maxLength: 200),
      FieldSchema.string('experience.mission.description', maxLength: 1000),
      FieldSchema.array('experience.mission.objectives'),
      FieldSchema.integer('experience.mission.estimatedMinutes', min: 10, max: 120),
      FieldSchema.string('experience.mission.difficulty',
          allowedValues: ['beginner', 'intermediate', 'advanced']),
      FieldSchema.array('experience.mission.successCriteria'),
      // Lessons array (optional)
      FieldSchema.array('experience.lessons'),
      FieldSchema.string('experience.lessons[].id'),
      FieldSchema.string('experience.lessons[].title', maxLength: 200),
      FieldSchema.string('experience.lessons[].summary', maxLength: 500),
      FieldSchema.integer('experience.lessons[].estimatedMinutes', min: 5, max: 60),
      // Project section (optional)
      FieldSchema.string('experience.project.id'),
      FieldSchema.string('experience.project.title', maxLength: 200),
      FieldSchema.string('experience.project.description', maxLength: 1000),
      FieldSchema.integer('experience.project.estimatedHours', min: 1, max: 100),
      FieldSchema.array('experience.project.technologies'),
      FieldSchema.array('experience.project.deliverables'),
      // Assessment section (optional)
      FieldSchema.string('experience.assessment.id'),
      FieldSchema.string('experience.assessment.title', maxLength: 200),
      FieldSchema.string('experience.assessment.type',
          allowedValues: ['quiz', 'coding', 'written', 'oral']),
      FieldSchema.integer('experience.assessment.passingScore', min: 50, max: 100),
      FieldSchema.array('experience.assessment.questions'),
      FieldSchema.string('experience.assessment.questions[].id'),
      FieldSchema.string('experience.assessment.questions[].type',
          allowedValues: ['multiple_choice', 'true_false', 'short_answer', 'coding']),
      FieldSchema.string('experience.assessment.questions[].question', maxLength: 1000),
      // Interview section (optional)
      FieldSchema.array('experience.interview.technicalQuestions'),
      FieldSchema.string('experience.interview.technicalQuestions[].id'),
      FieldSchema.string('experience.interview.technicalQuestions[].question', maxLength: 500),
      FieldSchema.array('experience.interview.behavioralQuestions'),
      // Revision section (optional)
      FieldSchema.array('experience.revision.keyPoints'),
      FieldSchema.array('experience.revision.flashCards'),
      FieldSchema.string('experience.revision.flashCards[].front', maxLength: 200),
      FieldSchema.string('experience.revision.flashCards[].back', maxLength: 500),
      // Reflection section (optional)
      FieldSchema.number('experience.reflection.confidenceScore', min: 0.0, max: 1.0),
      FieldSchema.array('experience.reflection.prompts'),
      // Next step section (optional)
      FieldSchema.string('experience.nextStep.tomorrowObjective', maxLength: 500),
      // Metadata section (required)
      FieldSchema.integer('experience.metadata.schemaVersion', required: true, min: 1, max: 99),
      FieldSchema.string('experience.metadata.provider', maxLength: 100),
      FieldSchema.string('experience.metadata.promptVersion', maxLength: 50),
    ]);
  }
}
