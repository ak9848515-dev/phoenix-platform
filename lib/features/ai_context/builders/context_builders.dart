import '../models/ai_context_snapshot.dart';

/// Reusable context builders for different AI features.
///
/// Each builder extracts a focused [AIContext] from the full
/// [AIContextSnapshot] for a specific AI capability.
///
/// Builders return structured context objects only.
/// No provider-specific prompt text. No AI generation.
///
/// **Architecture Rules:**
/// - These are consumed by the Prompt Builder layer (future sprint)
/// - No feature may build prompts independently
/// - No builder accesses repositories or services directly
/// - All data comes from the [AIContextSnapshot]
class ContextBuilders {
  ContextBuilders._();

  // ── Mission Context ─────────────────────────────────────────────

  /// Builds context for mission generation.
  ///
  /// Provides the user's identity, growth, knowledge gaps, and
  /// career trajectory for mission generation.
  static AIContext mission(AIContextSnapshot snapshot) {
    return AIContext(
      intent: 'mission_generation',
      summary: 'Mission generation for ${snapshot.identity.name} '
          'level ${snapshot.growth.level}',
      sections: [
        _keyValue('user_name', snapshot.identity.name),
        _keyValue('experience_level', snapshot.identity.experienceLevel),
        _keyValue('current_goal', snapshot.identity.currentGoal),
        _keyValue('career_goal', snapshot.identity.careerGoal),
        _keyValue('growth_index', snapshot.growth.growthIndex.toStringAsFixed(2)),
        _keyValue('knowledge_score', snapshot.growth.knowledgeScore.toStringAsFixed(2)),
        _keyValue('skills_score', snapshot.growth.skillsScore.toStringAsFixed(2)),
        _keyValue('weak_skills', snapshot.knowledge.weakSkills.join(', ')),
        _keyValue('mastered_skills', snapshot.knowledge.masteredSkills.join(', ')),
        _keyValue('target_identity', snapshot.identity.targetIdentity),
        _keyValue('learning_progress', snapshot.knowledge.learningProgress.toStringAsFixed(2)),
      ],
    );
  }

  // ── Project Context ─────────────────────────────────────────────

  /// Builds context for project generation.
  ///
  /// Portfolio, technology stack, skill gaps, and career goals.
  static AIContext project(AIContextSnapshot snapshot) {
    return AIContext(
      intent: 'project_generation',
      summary: 'Project generation — ${snapshot.portfolio.technologyCount} technologies',
      sections: [
        _keyValue('user_name', snapshot.identity.name),
        _keyValue('portfolio_score', snapshot.portfolio.portfolioScore.toStringAsFixed(2)),
        _keyValue('project_count', snapshot.portfolio.projectCount.toString()),
        _keyValue('technologies', snapshot.portfolio.technologies.join(', ')),
        _keyValue('skill_gaps', snapshot.career.skillGaps.join(', ')),
        _keyValue('career_goal', snapshot.identity.careerGoal),
        _keyValue('target_identity', snapshot.identity.targetIdentity),
        _keyValue('strength_areas', snapshot.portfolio.strengthAreas.join(', ')),
        _keyValue('experience_level', snapshot.identity.experienceLevel),
      ],
    );
  }

  // ── Assessment Context ──────────────────────────────────────────

  /// Builds context for assessment generation.
  ///
  /// Knowledge profile, learning progress, and skill gaps.
  static AIContext assessment(AIContextSnapshot snapshot) {
    return AIContext(
      intent: 'assessment_generation',
      summary: 'Assessment for ${snapshot.identity.name} — '
          '${snapshot.knowledge.masteredSkills.length} mastered, '
          '${snapshot.knowledge.weakSkills.length} weak',
      sections: [
        _keyValue('user_name', snapshot.identity.name),
        _keyValue('experience_level', snapshot.identity.experienceLevel),
        _keyValue('knowledge_score', snapshot.growth.knowledgeScore.toStringAsFixed(2)),
        _keyValue('mastered_skills', snapshot.knowledge.masteredSkills.join(', ')),
        _keyValue('weak_skills', snapshot.knowledge.weakSkills.join(', ')),
        _keyValue('learning_progress', snapshot.knowledge.learningProgress.toStringAsFixed(2)),
        _keyValue('domain_coverage', '${snapshot.knowledge.domainCoverage}/${snapshot.knowledge.totalDomains}'),
        _keyValue('skills_score', snapshot.growth.skillsScore.toStringAsFixed(2)),
      ],
    );
  }

  // ── Interview Context ───────────────────────────────────────────

  /// Builds context for interview question generation.
  ///
  /// Career readiness, skill gaps, target role, and portfolio.
  static AIContext interview(AIContextSnapshot snapshot) {
    return AIContext(
      intent: 'interview_question_generation',
      summary: 'Interview prep for ${snapshot.career.targetRole}',
      sections: [
        _keyValue('user_name', snapshot.identity.name),
        _keyValue('target_role', snapshot.career.targetRole),
        _keyValue('interview_readiness', snapshot.career.interviewReadiness.toStringAsFixed(2)),
        _keyValue('career_score', snapshot.career.careerScore.toStringAsFixed(2)),
        _keyValue('skill_gaps', snapshot.career.skillGaps.join(', ')),
        _keyValue('strengths', snapshot.career.strengths.join(', ')),
        _keyValue('technologies', snapshot.portfolio.technologies.join(', ')),
        _keyValue('experience_level', snapshot.identity.experienceLevel),
      ],
    );
  }

  // ── Career Context ──────────────────────────────────────────────

  /// Builds context for career recommendations.
  ///
  /// Career readiness, skill gaps, portfolio, and growth trajectory.
  static AIContext career(AIContextSnapshot snapshot) {
    return AIContext(
      intent: 'career_recommendation',
      summary: 'Career: ${(snapshot.career.careerScore * 100).round()}% — ${snapshot.career.targetRole}',
      sections: [
        _keyValue('user_name', snapshot.identity.name),
        _keyValue('career_score', snapshot.career.careerScore.toStringAsFixed(2)),
        _keyValue('career_readiness', snapshot.career.careerReadiness),
        _keyValue('target_role', snapshot.career.targetRole),
        _keyValue('skill_gaps', snapshot.career.skillGaps.join(', ')),
        _keyValue('strengths', snapshot.career.strengths.join(', ')),
        _keyValue('estimated_weeks', snapshot.career.estimatedWeeks.toString()),
        _keyValue('application_count', snapshot.career.applicationCount.toString()),
        _keyValue('interview_readiness', snapshot.career.interviewReadiness.toStringAsFixed(2)),
        _keyValue('portfolio_score', snapshot.portfolio.portfolioScore.toStringAsFixed(2)),
        _keyValue('growth_index', snapshot.growth.growthIndex.toStringAsFixed(2)),
      ],
    );
  }

  // ── Assistant Context ───────────────────────────────────────────

  /// Builds full context for the Phoenix AI Assistant.
  ///
  /// Complete user picture — identity, growth, missions, journey, recommendations.
  static AIContext assistant(AIContextSnapshot snapshot) {
    return AIContext(
      intent: 'ai_assistant',
      summary: 'Assistant context for ${snapshot.identity.name} '
          '(level ${snapshot.growth.level}, '
          '${snapshot.mission.activeCount} missions)',
      sections: [
        // Identity
        _keyValue('user_name', snapshot.identity.name),
        _keyValue('current_goal', snapshot.identity.currentGoal),
        _keyValue('career_goal', snapshot.identity.careerGoal),
        _keyValue('learning_style', snapshot.identity.learningStyle),
        _keyValue('experience_level', snapshot.identity.experienceLevel),
        _keyValue('identity_title', snapshot.identity.identityTitle),
        _keyValue('target_identity', snapshot.identity.targetIdentity),

        // Growth
        _keyValue('level', snapshot.growth.level.toString()),
        _keyValue('total_xp', snapshot.growth.totalXp.toString()),
        _keyValue('growth_index', snapshot.growth.growthIndex.toStringAsFixed(2)),
        _keyValue('strengths', snapshot.growth.strengths.join(', ')),
        _keyValue('weaknesses', snapshot.growth.weaknesses.join(', ')),
        _keyValue('streak', snapshot.growth.streak.toString()),

        // Mission
        _keyValue('current_mission', snapshot.mission.currentMission),
        _keyValue('active_missions', snapshot.mission.activeCount.toString()),
        _keyValue('completed_missions', snapshot.mission.completedCount.toString()),
        _keyValue('mission_reason', snapshot.mission.reason),

        // Journey
        _keyValue('current_journey', snapshot.journey.currentJourney),
        _keyValue('current_stage', snapshot.journey.currentStage),
        _keyValue('journey_progress', (snapshot.journey.completionPercent * 100).round().toString()),
        _keyValue('resume_point', snapshot.journey.resumeTitle),

        // Recommendation
        _keyValue('top_recommendation', snapshot.recommendation.topRecommendation),
        _keyValue('recommendation_priority', snapshot.recommendation.topPriority.toString()),

        // Settings
        _keyValue('daily_available_minutes', snapshot.settings.dailyAvailableMinutes.toString()),
      ],
    );
  }

  // ── Decision Context ────────────────────────────────────────────

  /// Builds context for decision intelligence.
  ///
  /// Identity, growth, recommendations, and memory for AI-assisted
  /// decision analysis.
  static AIContext decision(AIContextSnapshot snapshot) {
    return AIContext(
      intent: 'decision_intelligence',
      summary: 'Decision context — ${snapshot.recommendation.topRecommendation}',
      sections: [
        _keyValue('user_name', snapshot.identity.name),
        _keyValue('current_goal', snapshot.identity.currentGoal),
        _keyValue('career_goal', snapshot.identity.careerGoal),
        _keyValue('growth_index', snapshot.growth.growthIndex.toStringAsFixed(2)),
        _keyValue('top_recommendation', snapshot.recommendation.topRecommendation),
        _keyValue('recommendation_priority', snapshot.recommendation.topPriority.toString()),
        _keyValue('urgent_score', snapshot.recommendation.urgencyScore.toStringAsFixed(2)),
        _keyValue('current_mission', snapshot.mission.currentMission),
        _keyValue('current_stage', snapshot.journey.currentStage),
        _keyValue('top_memory', snapshot.memory.topMemory),
        _keyValue('weaknesses', snapshot.growth.weaknesses.join(', ')),
        _keyValue('skill_gaps', snapshot.career.skillGaps.join(', ')),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  static ContextSection _keyValue(String key, String value) {
    return ContextSection(key: key, value: value);
  }
}

/// A focused, structured context for a specific AI capability.
///
/// Contains the AI intent, a human-readable summary, and
/// structured key-value sections for prompt building.
///
/// This is the output of context builders and the input
/// to the Prompt Builder layer (future sprint).
class AIContext {
  const AIContext({
    required this.intent,
    required this.summary,
    this.sections = const [],
  });

  /// The AI capability intent (e.g. 'mission_generation').
  final String intent;

  /// Human-readable summary of the context.
  final String summary;

  /// Structured key-value sections for prompt building.
  final List<ContextSection> sections;

  /// Whether this context has enough data to be useful.
  bool get isValid => sections.isNotEmpty;

  /// Converts to a map suitable for prompt building.
  Map<String, String> toMap() {
    final map = <String, String>{
      'intent': intent,
      'summary': summary,
    };
    for (final section in sections) {
      map[section.key] = section.value;
    }
    return map;
  }

  @override
  String toString() =>
      'AIContext(intent: $intent, sections: ${sections.length})';
}

/// A single key-value pair within an [AIContext].
class ContextSection {
  const ContextSection({
    required this.key,
    required this.value,
  });

  /// The section key (e.g. 'user_name', 'growth_index').
  final String key;

  /// The section value.
  final String value;

  @override
  String toString() => '$key: $value';
}
