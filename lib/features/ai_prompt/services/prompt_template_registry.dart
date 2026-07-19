import '../models/prompt_template.dart';
import '../models/prompt_specification.dart';

/// Registry of versioned prompt templates.
///
/// Stores all [PromptTemplate] versions and provides lookup by
/// type and version. Supports template iteration without breaking
/// existing features.
///
/// **Architecture:**
/// - Templates are immutable and versioned
/// - Latest active version is returned by default
/// - Specific versions can be requested for backward compatibility
/// - New versions can be registered alongside old ones
class PromptTemplateRegistry {
  final Map<String, List<PromptTemplate>> _templates = {};

  /// Registers a template version.
  ///
  /// Multiple versions of the same template can coexist.
  void register(PromptTemplate template) {
    final key = template.id;
    _templates.putIfAbsent(key, () => []);
    _templates[key]!.add(template);
    // Sort by version descending so latest is first
    _templates[key]!.sort((a, b) => b.version.compareTo(a.version));
  }

  /// Registers multiple templates at once.
  void registerAll(List<PromptTemplate> templates) {
    for (final template in templates) {
      register(template);
    }
  }

  /// Gets the latest active version of a template by ID.
  ///
  /// Returns `null` if no active version exists.
  PromptTemplate? getLatest(String templateId) {
    final versions = _templates[templateId];
    if (versions == null || versions.isEmpty) return null;

    // Return the first (highest version) active template
    for (final version in versions) {
      if (version.isActive) return version;
    }
    return null;
  }

  /// Gets a specific version of a template.
  PromptTemplate? getVersion(String templateId, int version) {
    final versions = _templates[templateId];
    if (versions == null) return null;
    try {
      return versions.firstWhere((t) => t.version == version);
    } catch (_) {
      return null;
    }
  }

  /// Gets all registered template IDs.
  List<String> get allTemplateIds => _templates.keys.toList();

  /// Gets all versions of a template.
  List<PromptTemplate> getAllVersions(String templateId) =>
      List.unmodifiable(_templates[templateId] ?? []);

  /// Whether a template exists.
  bool hasTemplate(String templateId) => _templates.containsKey(templateId);

  /// Whether a specific version exists.
  bool hasVersion(String templateId, int version) =>
      getVersion(templateId, version) != null;

  /// Registers all built-in prompt templates.
  ///
  /// Called during bootstrap to populate the registry with default templates.
  void registerDefaults() {
    registerV2Defaults();
    _registerV1Defaults();
  }

  /// Registers optimized v2 prompt templates.
  ///
  /// v2 templates are:
  /// - **Smaller**: shorter system instructions, fewer redundant placeholders
  /// - **Structured**: cleaner output schemas with explicit JSON constraints
  /// - **Deterministic**: lower temperature (0.3–0.5) for consistent output
  /// - **Role-specific**: distinct system personas per capability
  /// - **Context-aware**: placeholders match the optimized ContextBuilders
  ///
  /// Registered automatically via [registerDefaults].
  void registerV2Defaults() {
    registerAll([
      // ══════════════════════════════════════════════════════════════
      // MISSION GENERATION v2 — Role: Task Planner
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'mission_generation',
        version: 2,
        promptType: PromptType.mission,
        purpose: 'Generate one focused, actionable learning mission.',
        objective:
            'Output a single JSON mission object addressing the weakest skill.',
        systemInstructions:
            'You are Phoenix Mission Planner. Generate ONE focused mission for '
            '{{user_name}} ({{experience_level}}, goal: {{career_goal}}).\n'
            'Target their weakest area: {{weak_skills}}. Build on: {{mastered_skills}}.\n'
            'Mission must be 30-60 min, single-session actionable.',
        userInstructionsTemplate:
            'Mission for {{user_name}}. Growth: {{growth_index}}%. '
            'Goal: {{current_goal}}. Weak: {{weak_skills}}.',
        outputSchema: '''{
  "mission": {
    "title": "string",
    "description": "string",
    "category": "knowledge|skill|project|habit|career",
    "difficulty": "beginner|intermediate|advanced",
    "estimatedMinutes": "integer (15-90)",
    "rewardXP": "integer (10-100)",
    "steps": [{ "title": "string", "description": "string", "estimatedMinutes": "integer" }],
    "successCriteria": ["string"],
    "learningObjectives": ["string"]
  }
}''',
        constraints:
            'ONLY valid JSON. No markdown. No explanations. '
            'One mission only. Must address {{weak_skills}}.',
        tone: 'encouraging',
        difficulty: 'intermediate',
        temperature: 0.4,
        maxTokens: 1024,
      ),

      // ══════════════════════════════════════════════════════════════
      // PROJECT GENERATION v2 — Role: Portfolio Advisor
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'project_generation',
        version: 2,
        promptType: PromptType.project,
        purpose: 'Generate a portfolio-worthy project.',
        objective:
            'Create one project with milestones that fills skill gaps.',
        systemInstructions:
            'You are Phoenix Portfolio Advisor. Generate a project for '
            '{{user_name}} ({{experience_level}}).\n'
            'Tech stack: {{technologies}}. Gaps: {{skill_gaps}}. '
            'Portfolio: {{portfolio_score}}.',
        userInstructionsTemplate:
            'Project for {{user_name}}. Goal: {{career_goal}}. '
            'Existing projects: {{project_count}}. Strengths: {{strength_areas}}.',
        outputSchema: '''{
  "project": {
    "title": "string",
    "description": "string",
    "technologies": ["string"],
    "estimatedWeeks": "integer",
    "difficulty": "beginner|intermediate|advanced",
    "milestones": [{ "title": "string", "description": "string", "estimatedHours": "integer", "deliverables": ["string"] }],
    "learningOutcomes": ["string"],
    "portfolioImpact": "string"
  }
}''',
        constraints:
            'ONLY valid JSON. Must use {{technologies}}. '
            'Weeks must be realistic.',
        tone: 'professional',
        difficulty: 'intermediate',
        temperature: 0.4,
        maxTokens: 1536,
      ),

      // ══════════════════════════════════════════════════════════════
      // ASSESSMENT GENERATION v2 — Role: Quiz Master
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'assessment_generation',
        version: 2,
        promptType: PromptType.assessment,
        purpose: 'Generate adaptive assessment questions.',
        objective:
            'Create questions testing mastered content and weak areas.',
        systemInstructions:
            'You are Phoenix Quiz Master. Create an assessment for '
            '{{user_name}} ({{experience_level}}).\n'
            'Test: {{mastered_skills}}. Challenge: {{weak_skills}}. '
            'Domain coverage: {{domain_coverage}}.',
        userInstructionsTemplate:
            'Assessment for {{user_name}}. '
            'Progress: {{learning_progress}}.',
        outputSchema: '''{
  "assessment": {
    "title": "string",
    "estimatedMinutes": "integer",
    "passingScore": "integer",
    "questions": [
      {
        "id": "string",
        "type": "multiple_choice|true_false|short_answer|coding",
        "question": "string",
        "options": ["string"],
        "correctAnswer": "string",
        "explanation": "string",
        "points": "integer",
        "skillTested": "string"
      }
    ]
  }
}''',
        constraints:
            'ONLY valid JSON. Mix of types. '
            'Cover both mastered and weak areas.',
        tone: 'professional',
        difficulty: 'intermediate',
        temperature: 0.3,
        maxTokens: 2048,
      ),

      // ══════════════════════════════════════════════════════════════
      // INTERVIEW GENERATION v2 — Role: Interview Coach
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'interview_generation',
        version: 2,
        promptType: PromptType.interview,
        purpose: 'Generate realistic interview questions.',
        objective:
            'Create technical and behavioral questions for the target role.',
        systemInstructions:
            'You are Phoenix Interview Coach. Prepare {{user_name}} for '
            '{{target_role}} interviews ({{experience_level}}).\n'
            'Readiness: {{interview_readiness}}. Gaps: {{skill_gaps}}. '
            'Tech: {{technologies}}. Strengths: {{strengths}}.',
        userInstructionsTemplate:
            'Interview questions for {{user_name}} targeting {{target_role}}.',
        outputSchema: '''{
  "interview": {
    "targetRole": "string",
    "difficulty": "beginner|intermediate|advanced",
    "estimatedMinutes": "integer",
    "sections": [
      {
        "name": "string",
        "questions": [
          {
            "id": "string",
            "type": "technical|behavioral|situational",
            "question": "string",
            "expectedAnswer": "string",
            "tips": ["string"],
            "difficulty": "easy|medium|hard"
          }
        ]
      }
    ],
    "overallTips": ["string"]
  }
}''',
        constraints:
            'ONLY valid JSON. Realistic {{target_role}} questions. '
            'Mix technical and behavioral.',
        tone: 'professional',
        difficulty: 'intermediate',
        temperature: 0.4,
        maxTokens: 2048,
      ),

      // ══════════════════════════════════════════════════════════════
      // CAREER COACHING v2 — Role: Career Strategist
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'career_coaching',
        version: 2,
        promptType: PromptType.careerCoaching,
        purpose: 'Provide structured career coaching advice.',
        objective:
            'Output actionable career steps based on profile and gaps.',
        systemInstructions:
            'You are Phoenix Career Strategist. Coach {{user_name}} for '
            '{{target_role}} roles.\n'
            'Score: {{career_score}}. Readiness: {{career_readiness}}. '
            'Gaps: {{skill_gaps}}. Strengths: {{strengths}}. '
            'Est. weeks: {{estimated_weeks}}.',
        userInstructionsTemplate:
            'Career coaching for {{user_name}}. '
            'Score: {{career_score}}. Applications: {{application_count}}. '
            'Growth: {{growth_index}}.',
        outputSchema: '''{
  "careerAdvice": {
    "summary": "string",
    "topPriority": "string",
    "recommendedActions": [
      {
        "action": "string",
        "reason": "string",
        "estimatedImpact": "high|medium|low",
        "timeframe": "this week|this month|this quarter"
      }
    ],
    "skillDevelopment": ["string"],
    "marketInsights": ["string"],
    "nextMilestone": "string"
  }
}''',
        constraints:
            'ONLY valid JSON. Actionable advice, not generic. '
            'Base on {{career_score}} and {{skill_gaps}}.',
        tone: 'encouraging',
        difficulty: 'advanced',
        temperature: 0.4,
        maxTokens: 1536,
      ),

      // ══════════════════════════════════════════════════════════════
      // DECISION INTELLIGENCE v2 — Role: Decision Analyst
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'decision_intelligence',
        version: 2,
        promptType: PromptType.decisionIntelligence,
        purpose: 'Analyze a decision with structured framework.',
        objective:
            'Output balanced pros/cons and a recommended option with reasoning.',
        systemInstructions:
            'You are Phoenix Decision Analyst. Analyze for {{user_name}}.\n'
            'Goal: {{current_goal}}. Career: {{career_goal}}. '
            'Growth: {{growth_index}}. Recommendation: {{top_recommendation}}. '
            'Memory: {{top_memory}}. Gaps: {{skill_gaps}}.',
        userInstructionsTemplate:
            'Decision analysis for {{user_name}}. '
            'Mission: {{current_mission}}. Priority: {{recommendation_priority}}. '
            'Urgency: {{urgent_score}}.',
        outputSchema: '''{
  "decisionAnalysis": {
    "situation": "string",
    "options": [
      {
        "option": "string",
        "pros": ["string"],
        "cons": ["string"],
        "confidence": "number (0.0-1.0)"
      }
    ],
    "recommendedOption": "string",
    "reasoning": "string",
    "nextSteps": ["string"]
  }
}''',
        constraints:
            'ONLY valid JSON. Objective analysis with balanced pros/cons.',
        tone: 'professional',
        difficulty: 'advanced',
        temperature: 0.3,
        maxTokens: 1536,
      ),

      // ══════════════════════════════════════════════════════════════
      // AI ASSISTANT v2 — Role: Growth Companion
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'ai_assistant',
        version: 2,
        promptType: PromptType.aiAssistant,
        purpose: 'Respond conversationally with full user context.',
        objective:
            'Helpful, contextual responses referencing user goals and progress.',
        systemInstructions:
            'You are Phoenix Growth Companion, speaking with {{user_name}}.\n'
            'Level {{level}}, {{total_xp}} XP. Identity: {{identity_title}} '
            '(target: {{target_identity}}). Goal: {{current_goal}}. '
            'Career: {{career_goal}}. Learning: {{learning_style}}. '
            'Growth: {{growth_index}}%.\n'
            'Current: {{current_mission}} ({{current_stage}}). '
            'Completed: {{completed_missions}} missions. '
            'Strengths: {{strengths}}. Weaknesses: {{weaknesses}}. '
            'Streak: {{streak}} days. Recommend: {{top_recommendation}}.',
        userInstructionsTemplate:
            '{{user_message}}\n'
            'Respond naturally. Reference their goals and progress when relevant.',
        outputSchema: '''{
  "response": {
    "message": "string",
    "suggestedActions": [{ "label": "string", "action": "string" }],
    "relatedTopics": ["string"],
    "confidence": "number (0.0-1.0)"
  }
}''',
        constraints:
            'Conversational and concise (< 300 tokens). '
            'Reference user context naturally. Suggest concrete next actions.',
        tone: 'encouraging',
        difficulty: 'intermediate',
        temperature: 0.7,
        maxTokens: 768,
      ),

      // ══════════════════════════════════════════════════════════════
      // LEARNING PATH v2 — Role: Curriculum Designer
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'learning_path_generation',
        version: 2,
        promptType: PromptType.learningPath,
        purpose: 'Generate a structured learning path.',
        objective:
            'Create a curriculum from current level to target, with milestones.',
        systemInstructions:
            'You are Phoenix Curriculum Designer. Create a learning path for '
            '{{user_name}} ({{experience_level}}).\n'
            'Target: {{target_identity}}. Goal: {{career_goal}}. '
            '{{daily_available_minutes}} min/day available. '
            'Build on: {{mastered_skills}}. Address: {{weak_skills}}.',
        userInstructionsTemplate:
            'Learning path for {{user_name}}. Level {{level}}. '
            '{{daily_available_minutes}} min/day. Goal: {{career_goal}}.',
        outputSchema: '''{
  "learningPath": {
    "title": "string",
    "description": "string",
    "estimatedWeeks": "integer",
    "modules": [
      {
        "title": "string",
        "description": "string",
        "estimatedHours": "integer",
        "topics": ["string"],
        "projects": ["string"]
      }
    ],
    "totalEstimatedHours": "integer",
    "outcomes": ["string"]
  }
}''',
        constraints:
            'ONLY valid JSON. Path must fit {{daily_available_minutes}} min/day. '
            'Adapt to {{experience_level}}.',
        tone: 'encouraging',
        difficulty: 'intermediate',
        temperature: 0.4,
        maxTokens: 2048,
      ),
    ]);
  }

  void _registerV1Defaults() {
    registerAll([
      // ══════════════════════════════════════════════════════════════
      // MISSION GENERATION v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'mission_generation',
        version: 1,
        promptType: PromptType.mission,
        purpose: 'Generate a personalized learning mission for the user.',
        objective:
            'Create a single, actionable mission that helps the user grow '
            'in their weakest or most impactful area.',
        systemInstructions:
            'You are Phoenix, an AI-Orchestrated Personal Growth Operating System. '
            'You are helping {{user_name}}, a {{experience_level}} level user '
            'working toward becoming {{target_identity}}.\n\n'
            'Your role is to generate ONE focused mission that:\n'
            '1. Addresses their weakest skill area\n'
            '2. Aligns with their career goal: {{career_goal}}\n'
            '3. Is achievable in a single session (30-60 minutes)\n'
            '4. Builds on their existing knowledge of {{mastered_skills}}\n'
            '5. Pushes them slightly beyond their comfort zone\n\n'
            'Phoenix decides WHAT the user should do. You decide HOW.',
        userInstructionsTemplate:
            'Generate a mission for {{user_name}} with:\n'
            '- Current goal: {{current_goal}}\n'
            '- Growth index: {{growth_index}}\n'
            '- Knowledge score: {{knowledge_score}}\n'
            '- Skills score: {{skills_score}}\n'
            '- Weak areas: {{weak_skills}}\n'
            '- Mastered skills: {{mastered_skills}}\n'
            '- Learning progress: {{learning_progress}}',
        outputSchema: '''{
  "mission": {
    "title": "string (compelling, action-oriented title)",
    "description": "string (2-3 sentences explaining the mission)",
    "category": "string (knowledge | skill | project | habit | career)",
    "difficulty": "string (beginner | intermediate | advanced)",
    "estimatedMinutes": "integer (15-90)",
    "rewardXP": "integer (10-100)",
    "steps": [
      {
        "title": "string",
        "description": "string",
        "estimatedMinutes": "integer"
      }
    ],
    "prerequisites": ["string (optional skills needed)"],
    "successCriteria": ["string (measurable completion criteria)"],
    "learningObjectives": ["string (what the user will learn)"]
  }
}''',
        constraints:
            'ONLY output valid JSON matching the schema exactly. '
            'Do NOT include markdown code blocks, explanations, or additional text. '
            'The mission must be directly relevant to {{user_name}}\'s current '
            '{{current_goal}}. Difficulty must match {{experience_level}} level. '
            'Must build on {{mastered_skills}}.',
        tone: 'encouraging',
        difficulty: 'intermediate',
        temperature: 0.7,
        maxTokens: 2048,
      ),

      // ══════════════════════════════════════════════════════════════
      // PROJECT GENERATION v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'project_generation',
        version: 1,
        promptType: PromptType.project,
        purpose: 'Generate a portfolio project for the user.',
        objective:
            'Create a real-world project that strengthens the user\'s portfolio '
            'and addresses their skill gaps.',
        systemInstructions:
            'You are Phoenix, generating a portfolio project for {{user_name}}, '
            'a {{experience_level}} user targeting {{target_identity}}.\n\n'
            'The project should:\n'
            '1. Be realistic and achievable within {{estimated_weeks}} weeks\n'
            '2. Use technologies: {{technologies}}\n'
            '3. Address skill gaps: {{skill_gaps}}\n'
            '4. Be portfolio-worthy (employers should care)\n'
            '5. Have clear milestones and deliverables',
        userInstructionsTemplate:
            'Generate a project for {{user_name}} considering:\n'
            '- Portfolio score: {{portfolio_score}}\n'
            '- Existing projects: {{project_count}}\n'
            '- Career goal: {{career_goal}}\n'
            '- Strength areas: {{strength_areas}}',
        outputSchema: '''{
  "project": {
    "title": "string",
    "description": "string",
    "technologies": ["string"],
    "estimatedWeeks": "integer",
    "difficulty": "string (beginner | intermediate | advanced)",
    "milestones": [
      {
        "title": "string",
        "description": "string",
        "estimatedHours": "integer",
        "deliverables": ["string"]
      }
    ],
    "learningOutcomes": ["string"],
    "portfolioImpact": "string (how this strengthens the portfolio)"
  }
}''',
        constraints:
            'ONLY valid JSON. No extra text. Must use {{technologies}}. '
            'Must be achievable within {{estimated_weeks}} weeks.',
        tone: 'professional',
        difficulty: 'intermediate',
        temperature: 0.7,
        maxTokens: 2048,
      ),

      // ══════════════════════════════════════════════════════════════
      // ASSESSMENT GENERATION v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'assessment_generation',
        version: 1,
        promptType: PromptType.assessment,
        purpose: 'Generate an adaptive assessment for the user.',
        objective:
            'Create questions that accurately measure the user\'s knowledge '
            'of their learned topics.',
        systemInstructions:
            'You are Phoenix, creating an assessment for {{user_name}}, '
            'a {{experience_level}} user.\n\n'
            'The assessment should:\n'
            '1. Cover mastered skills: {{mastered_skills}}\n'
            '2. Test weak skills: {{weak_skills}}\n'
            '3. Adapt difficulty to {{experience_level}}\n'
            '4. Include a mix of question types\n'
            '5. Provide clear correct answers',
        userInstructionsTemplate:
            'Create an assessment for {{user_name}}:\n'
            '- Knowledge score: {{knowledge_score}}\n'
            '- Skills score: {{skills_score}}\n'
            '- Domain coverage: {{domain_coverage}}\n'
            '- Learning progress: {{learning_progress}}',
        outputSchema: '''{
  "assessment": {
    "title": "string",
    "description": "string",
    "difficulty": "string",
    "estimatedMinutes": "integer",
    "passingScore": "integer (percentage)",
    "questions": [
      {
        "id": "string",
        "type": "string (multiple_choice | true_false | short_answer | coding)",
        "question": "string",
        "options": ["string (for multiple_choice)"],
        "correctAnswer": "string",
        "explanation": "string",
        "points": "integer",
        "skillTested": "string"
      }
    ]
  }
}''',
        constraints:
            'ONLY valid JSON. Questions must be genuinely educational. '
            'Adapt difficulty to {{experience_level}} level. '
            'Include questions for both {{mastered_skills}} and {{weak_skills}}.',
        tone: 'professional',
        difficulty: 'intermediate',
        temperature: 0.5,
        maxTokens: 3072,
      ),

      // ══════════════════════════════════════════════════════════════
      // INTERVIEW QUESTION GENERATION v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'interview_generation',
        version: 1,
        promptType: PromptType.interview,
        purpose: 'Generate interview questions for career preparation.',
        objective:
            'Create realistic interview questions that prepare the user '
            'for their target role.',
        systemInstructions:
            'You are Phoenix, preparing {{user_name}} for interviews '
            'for {{target_role}} roles.\n\n'
            'Generate questions that:\n'
            '1. Match real interview patterns for {{target_role}}\n'
            '2. Test both technical and behavioral skills\n'
            '3. Address user\'s weak areas: {{skill_gaps}}\n'
            '4. Build on their strengths: {{strengths}}\n'
            '5. Use their technology stack: {{technologies}}',
        userInstructionsTemplate:
            'Generate interview questions for {{user_name}}:\n'
            '- Target role: {{target_role}}\n'
            '- Interview readiness: {{interview_readiness}}\n'
            '- Career score: {{career_score}}\n'
            '- Experience level: {{experience_level}}',
        outputSchema: '''{
  "interview": {
    "targetRole": "string",
    "difficulty": "string",
    "estimatedMinutes": "integer",
    "sections": [
      {
        "name": "string (e.g. Technical, Behavioral, System Design)",
        "questions": [
          {
            "id": "string",
            "type": "string (technical | behavioral | situational)",
            "question": "string",
            "expectedAnswer": "string",
            "tips": ["string"],
            "difficulty": "string (easy | medium | hard)"
          }
        ]
      }
    ],
    "overallTips": ["string"]
  }
}''',
        constraints:
            'ONLY valid JSON. Questions must be realistic for {{target_role}}. '
            'Include both technical and behavioral questions.',
        tone: 'professional',
        difficulty: 'intermediate',
        temperature: 0.6,
        maxTokens: 3072,
      ),

      // ══════════════════════════════════════════════════════════════
      // CAREER COACHING v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'career_coaching',
        version: 1,
        promptType: PromptType.careerCoaching,
        purpose: 'Provide career coaching advice.',
        objective:
            'Give actionable career advice based on the user\'s profile, '
            'skill gaps, and market trends.',
        systemInstructions:
            'You are Phoenix, acting as a career coach for {{user_name}}, '
            'targeting {{target_role}}.\n\n'
            'Provide advice that:\n'
            '1. Addresses their current readiness: {{career_readiness}}\n'
            '2. Prioritizes their skill gaps: {{skill_gaps}}\n'
            '3. Leverages their strengths: {{strengths}}\n'
            '4. Is realistic within {{estimated_weeks}} weeks',
        userInstructionsTemplate:
            'Coach {{user_name}} on their career:\n'
            '- Career score: {{career_score}}\n'
            '- Resume score: {{resume_score}}\n'
            '- Interview readiness: {{interview_readiness}}\n'
            '- Applications: {{application_count}}',
        outputSchema: '''{
  "careerAdvice": {
    "summary": "string",
    "topPriority": "string",
    "recommendedActions": [
      {
        "action": "string",
        "reason": "string",
        "estimatedImpact": "string (high | medium | low)",
        "timeframe": "string (this week | this month | this quarter)"
      }
    ],
    "skillDevelopment": ["string"],
    "marketInsights": ["string"],
    "nextMilestone": "string"
  }
}''',
        constraints:
            'ONLY valid JSON. Advice must be actionable, not generic. '
            'Base recommendations on {{career_score}} and {{skill_gaps}}.',
        tone: 'encouraging',
        difficulty: 'advanced',
        temperature: 0.6,
        maxTokens: 2048,
      ),

      // ══════════════════════════════════════════════════════════════
      // AI ASSISTANT v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'ai_assistant',
        version: 1,
        promptType: PromptType.aiAssistant,
        purpose: 'Power the conversational AI assistant.',
        objective:
            'Respond helpfully to the user\'s questions using their '
            'full Phoenix context.',
        systemInstructions:
            'You are Phoenix, an AI-Orchestrated Personal Growth Operating System. '
            'You are speaking with {{user_name}}.\n\n'
            'User Profile:\n'
            '- Level {{level}} with {{total_xp}} total XP\n'
            '- Identity: {{identity_title}} (target: {{target_identity}})\n'
            '- Current goal: {{current_goal}}\n'
            '- Career goal: {{career_goal}}\n'
            '- Learning style: {{learning_style}}\n'
            '- Growth index: {{growth_index}}%\n\n'
            'Current State:\n'
            '- Active mission: {{current_mission}}\n'
            '- Mission confidence: {{mission_reason}}\n'
            '- Journey: {{current_journey}} (stage: {{current_stage}})\n'
            '- Journey progress: {{journey_progress}}%\n'
            '- Resume point: {{resume_point}}\n\n'
            'Top Recommendation: {{top_recommendation}}\n\n'
            'You can:\n'
            '- Answer questions about their growth journey\n'
            '- Explain Phoenix recommendations\n'
            '- Suggest next actions\n'
            '- Provide motivation and encouragement\n'
            '- Help with career decisions\n\n'
            'Never:\n'
            '- Claim to be a human\n'
            '- Provide medical, legal, or financial advice\n'
            '- Store or remember information outside the current conversation',
        userInstructionsTemplate:
            '{{user_name}} says: {{user_message}}\n\n'
            'Respond naturally and conversationally. Reference their goals, '
            'missions, and growth data when relevant.',
        outputSchema: '''{
  "response": {
    "message": "string (conversational response)",
    "suggestedActions": [
      {
        "label": "string",
        "action": "string (route or capability)"
      }
    ],
    "relatedTopics": ["string"],
    "confidence": "number (0.0-1.0)"
  }
}''',
        constraints:
            'Be conversational and natural. Reference user context naturally. '
            'Keep responses concise (< 500 tokens). Suggest concrete next steps.',
        tone: 'encouraging',
        difficulty: 'intermediate',
        temperature: 0.8,
        maxTokens: 1024,
      ),

      // ══════════════════════════════════════════════════════════════
      // DECISION INTELLIGENCE v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'decision_intelligence',
        version: 1,
        promptType: PromptType.decisionIntelligence,
        purpose: 'AI-assisted decision analysis.',
        objective:
            'Analyze the user\'s situation and provide a structured '
            'decision framework.',
        systemInstructions:
            'You are Phoenix, analyzing a decision for {{user_name}}.\n\n'
            'User context:\n'
            '- Current goal: {{current_goal}}\n'
            '- Career goal: {{career_goal}}\n'
            '- Growth index: {{growth_index}}\n'
            '- Top recommendation: {{top_recommendation}}\n'
            '- Urgent areas: {{urgent_score}}\n'
            '- Benefit analysis: {{benefit_score}}\n'
            '- Skill gaps: {{skill_gaps}}',
        userInstructionsTemplate:
            'Analyze this decision for {{user_name}}:\n'
            '- Top recommendation: {{top_recommendation}}\n'
            '- Current mission: {{current_mission}}\n'
            '- Priority: {{recommendation_priority}}',
        outputSchema: '''{
  "decisionAnalysis": {
    "situation": "string",
    "options": [
      {
        "option": "string",
        "pros": ["string"],
        "cons": ["string"],
        "estimatedOutcome": "string",
        "confidence": "number (0.0-1.0)"
      }
    ],
    "recommendedOption": "string",
    "reasoning": "string",
    "nextSteps": ["string"]
  }
}''',
        constraints:
            'ONLY valid JSON. Be objective. Present balanced pros and cons. '
            'Base recommendations on user data.',
        tone: 'professional',
        difficulty: 'advanced',
        temperature: 0.4,
        maxTokens: 2048,
      ),

      // ══════════════════════════════════════════════════════════════
      // LEARNING PATH GENERATION v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'learning_path_generation',
        version: 1,
        promptType: PromptType.learningPath,
        purpose: 'Generate a personalized learning path.',
        objective:
            'Create a structured learning path that takes the user from '
            'their current level to their target.',
        systemInstructions:
            'You are Phoenix, creating a learning path for {{user_name}}, '
            'a {{experience_level}} user targeting {{target_identity}}.\n\n'
            'The path should:\n'
            '1. Start from current knowledge: {{mastered_skills}}\n'
            '2. Address knowledge gaps: {{weak_skills}}\n'
            '3. Be achievable with {{daily_available_minutes}} min/day\n'
            '4. Build portfolio projects along the way\n'
            '5. Include milestones every 2-3 modules',
        userInstructionsTemplate:
            'Create a learning path for {{user_name}}:\n'
            '- Current level: {{level}}\n'
            '- Knowledge score: {{knowledge_score}}\n'
            '- Skills score: {{skills_score}}\n'
            '- Available time: {{daily_available_minutes}} min/day\n'
            '- Career goal: {{career_goal}}',
        outputSchema: '''{
  "learningPath": {
    "title": "string",
    "description": "string",
    "estimatedWeeks": "integer",
    "difficulty": "string",
    "modules": [
      {
        "title": "string",
        "description": "string",
        "estimatedHours": "integer",
        "topics": ["string"],
        "projects": ["string"],
        "prerequisites": ["string"]
      }
    ],
    "totalEstimatedHours": "integer",
    "outcomes": ["string"]
  }
}''',
        constraints:
            'ONLY valid JSON. Path must be realistic for {{daily_available_minutes}} min/day. '
            'Adapt to {{experience_level}}.',
        tone: 'encouraging',
        difficulty: 'intermediate',
        temperature: 0.7,
        maxTokens: 3072,
      ),
      // ══════════════════════════════════════════════════════════════
      // LEARNING EXPERIENCE GENERATION v1
      // ══════════════════════════════════════════════════════════════
      PromptTemplate(
        id: 'learning_experience_generation',
        version: 1,
        promptType: 'learning_experience',
        purpose: 'Generate a complete learning experience for the user.',
        objective:
            'Create a complete, cohesive learning experience covering all '
            '10 sections: Goal, Mission, Micro Lessons, Project, Assessment, '
            'Interview Practice, Revision, Reflection, Next Step, and Metadata.',
        systemInstructions:
            'You are Phoenix, an AI-Orchestrated Personal Growth Operating System. '
            'You are generating a complete learning experience for {{user_name}}, '
            'a {{experience_level}} level user working toward becoming '
            '{{target_identity}}.\n\n'
            'The learning experience should:\n'
            '1. BE COMPLETE — include ALL 10 sections (goal, mission, lessons, '
            '   project, assessment, interview, revision, reflection, next step, metadata)\n'
            '2. Be personalized to {{user_name}}\'s current level and goals\n'
            '3. Address their weakest area: {{weak_skills}}\n'
            '4. Build on their strengths: {{strength_areas}}\n'
            '5. Align with their career goal: {{career_goal}}\n'
            '6. Be achievable within {{daily_available_minutes}} min/day\n'
            '7. Provide a complete journey from learning through application\n\n'
            'Phoenix decides WHAT. You decide HOW. Generate the full JSON.',
        userInstructionsTemplate:
            'Generate a learning experience for {{user_name}} with profile:\n'
            '- Level {{level}}, {{total_xp}} XP\n'
            '- Current goal: {{current_goal}}\n'
            '- Career goal: {{career_goal}}\n'
            '- Growth index: {{growth_index}}%\n'
            '- Knowledge score: {{knowledge_score}}%\n'
            '- Skills score: {{skills_score}}%\n'
            '- Weakest: {{weak_skills}}\n'
            '- Strongest: {{strength_areas}}\n'
            '- Career readiness: {{career_readiness}}\n'
            '- Interview readiness: {{interview_readiness}}\n'
            '- Portfolio score: {{portfolio_score}}%\n'
            '- Technologies: {{technologies}}\n'
            '- Active missions: {{current_mission}}\n'
            '- Daily available: {{daily_available_minutes}} min',
        outputSchema: '''{
  "experience": {
    "goal": {
      "id": "string",
      "title": "string",
      "description": "string",
      "objective": "string",
      "estimatedMinutes": "integer",
      "priority": "string (high | medium | low)"
    },
    "mission": {
      "id": "string",
      "title": "string",
      "description": "string",
      "objectives": ["string"],
      "estimatedMinutes": "integer",
      "difficulty": "string (beginner | intermediate | advanced)",
      "successCriteria": ["string"]
    },
    "lessons": [
      {
        "id": "string",
        "title": "string",
        "summary": "string",
        "estimatedMinutes": "integer"
      }
    ],
    "project": {
      "id": "string",
      "title": "string",
      "description": "string",
      "estimatedHours": "integer",
      "technologies": ["string"],
      "deliverables": ["string"],
      "difficulty": "string"
    },
    "assessment": {
      "id": "string",
      "title": "string",
      "type": "string (quiz | coding | written | oral)",
      "passingScore": "integer (50-100)",
      "estimatedMinutes": "integer",
      "questions": [
        {
          "id": "string",
          "type": "string (multiple_choice | true_false | short_answer | coding)",
          "question": "string",
          "options": ["string"],
          "correctAnswer": "string",
          "explanation": "string",
          "points": "integer"
        }
      ]
    },
    "interview": {
      "technicalQuestions": [
        {
          "id": "string",
          "question": "string",
          "expectedAnswer": "string",
          "tips": ["string"],
          "difficulty": "string (easy | medium | hard)"
        }
      ],
      "behavioralQuestions": [
        {
          "id": "string",
          "question": "string",
          "expectedAnswer": "string",
          "tips": ["string"],
          "difficulty": "string (easy | medium | hard)"
        }
      ],
      "estimatedMinutes": "integer"
    },
    "revision": {
      "keyPoints": ["string"],
      "flashCards": [
        {
          "front": "string",
          "back": "string"
        }
      ],
      "quickReview": "string",
      "estimatedMinutes": "integer"
    },
    "reflection": {
      "whatWasLearned": ["string"],
      "challenges": ["string"],
      "confidenceScore": "number (0.0-1.0)",
      "prompts": ["string"]
    },
    "nextStep": {
      "tomorrowObjective": "string",
      "unlockCondition": "string",
      "suggestedNextExperience": "string"
    },
    "metadata": {
      "schemaVersion": "integer",
      "provider": "string",
      "promptVersion": "string",
      "templateId": "string"
    }
  }
}''',
        constraints:
            'ONLY output valid JSON matching the schema exactly. '
            'Do NOT include markdown code blocks, explanations, or extra text. '
            'ALL 10 sections MUST be present. The experience must be '
            'personalized to {{user_name}}\'s current {{current_goal}}. '
            'Difficulty must match {{experience_level}}.',
        tone: 'encouraging',
        difficulty: 'advanced',
        temperature: 0.7,
        maxTokens: 8192,
      ),
    ]);
  }
}
