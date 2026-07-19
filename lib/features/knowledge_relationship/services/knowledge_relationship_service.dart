import '../../growth_index/engine/growth_index_engine.dart';
import '../../growth_index/models/growth_snapshot.dart';
import '../../identity/engine/identity_engine.dart';
import '../../identity/models/identity_snapshot.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../../portfolio/engine/portfolio_snapshot.dart';
import '../../ai_context/models/ai_context_snapshot.dart';

/// Structured knowledge relationship data attached to AI responses.
///
/// This is the output of Part J — Knowledge Relationship Intelligence.
/// Every AI answer should include these relationship dimensions so Phoenix
/// explains WHY something matters, not just WHAT it is.
class KnowledgeRelationship {
  const KnowledgeRelationship({
    this.interconnections = const [],
    this.prerequisites = const [],
    this.missingKnowledge = const [],
    this.careerImpact = '',
    this.careerImpactScore = 0.0,
    this.portfolioImpact = '',
    this.portfolioImpactScore = 0.0,
    this.nextLearningPath = const [],
    this.recommendedDuration = 0,
  });

  /// Related topics that interconnect with the current query.
  final List<KnowledgeLink> interconnections;

  /// Topics the user should master first.
  final List<KnowledgeLink> prerequisites;

  /// Knowledge gaps relevant to the current topic.
  final List<String> missingKnowledge;

  /// How this topic affects the user's career readiness.
  final String careerImpact;
  final double careerImpactScore;

  /// How this topic affects the user's portfolio.
  final String portfolioImpact;
  final double portfolioImpactScore;

  /// Suggested next learning steps.
  final List<String> nextLearningPath;

  /// Recommended time for next session (minutes).
  final int recommendedDuration;

  bool get hasInterconnections => interconnections.isNotEmpty;
  bool get hasPrerequisites => prerequisites.isNotEmpty;
  bool get hasMissingKnowledge => missingKnowledge.isNotEmpty;
  bool get hasCareerImpact => careerImpact.isNotEmpty;
  bool get hasPortfolioImpact => portfolioImpact.isNotEmpty;
  bool get hasNextLearningPath => nextLearningPath.isNotEmpty;

  Map<String, dynamic> toMap() => {
    'interconnections': interconnections.map((l) => l.toMap()).toList(),
    'prerequisites': prerequisites.map((l) => l.toMap()).toList(),
    'missingKnowledge': missingKnowledge,
    'careerImpact': careerImpact,
    'careerImpactScore': careerImpactScore,
    'portfolioImpact': portfolioImpact,
    'portfolioImpactScore': portfolioImpactScore,
    'nextLearningPath': nextLearningPath,
    'recommendedDuration': recommendedDuration,
  };

  @override
  String toString() =>
      'KnowledgeRelationship(interconnections: ${interconnections.length}, '
      'prerequisites: ${prerequisites.length}, '
      'careerScore: ${(careerImpactScore * 100).round()}%)';
}

/// A single knowledge link representing an interconnection or prerequisite.
class KnowledgeLink {
  const KnowledgeLink({
    required this.topic,
    required this.description,
    this.relevanceScore = 0.5,
    this.isMastered = false,
  });

  /// The linked topic name.
  final String topic;

  /// How this topic relates to the current context.
  final String description;

  /// Relevance score (0.0–1.0).
  final double relevanceScore;

  /// Whether the user has already mastered this topic.
  final bool isMastered;

  Map<String, dynamic> toMap() => {
    'topic': topic,
    'description': description,
    'relevanceScore': relevanceScore,
    'isMastered': isMastered,
  };
}

/// Knowledge Relationship Intelligence Service.
///
/// **Part J — Knowledge Relationship Intelligence**
///
/// Analyzes the user's knowledge graph, growth metrics, and career/portfolio
/// state to produce structured relationship data for every AI answer.
///
/// Every AI answer should include:
/// - Answer (from AI pipeline)
/// - Interconnections (related topics)
/// - Prerequisites (what to learn first)
/// - Missing Knowledge (gaps to fill)
/// - Career Impact (why it matters for career)
/// - Portfolio Impact (why it matters for portfolio)
/// - Next Learning Path (what to do next)
///
/// Phoenix should explain WHY something matters, not just WHAT it is.
class KnowledgeRelationshipService {
  KnowledgeRelationshipService({
    required this._growthIndexEngine,
    required this._identityEngine,
    required this._portfolioEngine,
  });

  final GrowthIndexEngine _growthIndexEngine;
  final IdentityEngine _identityEngine;
  final PortfolioEngine _portfolioEngine;

  /// Builds a complete knowledge relationship for the given query context.
  ///
  /// Uses the current engine snapshots to determine:
  /// - What the user already knows (mastered skills)
  /// - What they need to learn (weak skills)
  /// - Career relevance (from growth and identity)
  /// - Portfolio relevance (from portfolio engine)
  /// - Recommended next steps
  KnowledgeRelationship buildForContext(AIContextSnapshot context) {
    final identitySnap = _identityEngine.snapshot;
    final growthSnap = _growthIndexEngine.snapshot;
    final portfolioSnap = _portfolioEngine.snapshot;

    final knowledge = context.knowledge;
    final career = context.career;

    // Find interconnections: topics related to current knowledge
    final interconnections = _findInterconnections(
      knowledge.masteredSkills,
      knowledge.weakSkills,
      growthSnap,
    );

    // Find prerequisites: topics to master before advancing
    final prerequisites = _findPrerequisites(
      knowledge.masteredSkills,
      knowledge.weakSkills,
      growthSnap,
    );

    // Find missing knowledge: gaps in the user's profile
    final missingKnowledge = _findMissingKnowledge(
      knowledge, growthSnap, identitySnap,
    );

    // Calculate career impact
    final (careerImpact, careerImpactScore) = _calculateCareerImpact(
      career, growthSnap, identitySnap,
    );

    // Calculate portfolio impact
    final (portfolioImpact, portfolioImpactScore) = _calculatePortfolioImpact(
      portfolioSnap, growthSnap,
    );

    // Generate next learning path
    final nextLearningPath = _generateNextLearningPath(
      knowledge, growthSnap, identitySnap,
    );

    // Recommended session duration based on momentum
    final recommendedDuration = _recommendDuration(growthSnap);

    return KnowledgeRelationship(
      interconnections: interconnections,
      prerequisites: prerequisites,
      missingKnowledge: missingKnowledge,
      careerImpact: careerImpact,
      careerImpactScore: careerImpactScore,
      portfolioImpact: portfolioImpact,
      portfolioImpactScore: portfolioImpactScore,
      nextLearningPath: nextLearningPath,
      recommendedDuration: recommendedDuration,
    );
  }

  // ── Interconnections ─────────────────────────────────────────────

  List<KnowledgeLink> _findInterconnections(
    List<String> masteredSkills,
    List<String> weakSkills,
    GrowthSnapshot? growth,
  ) {
    final links = <KnowledgeLink>[];

    // Topics adjacent to weak skills
    for (final weak in weakSkills.take(3)) {
      final related = _findRelatedTopics(weak);
      for (final topic in related.take(2)) {
        final isMastered = masteredSkills.any((s) =>
            s.toLowerCase().contains(topic.toLowerCase()));
        links.add(KnowledgeLink(
          topic: topic,
          description: isMastered
              ? 'You\'ve worked with $topic — connect it to $weak'
              : '$topic complements $weak — learning both strengthens your profile',
          relevanceScore: isMastered ? 0.7 : 0.5,
          isMastered: isMastered,
        ));
      }
    }

    // If no weak skills, recommend advanced topics from mastered areas
    if (links.isEmpty && masteredSkills.isNotEmpty) {
      for (final skill in masteredSkills.take(2)) {
        final advanced = _findAdvancedTopics(skill);
        for (final topic in advanced.take(2)) {
          links.add(KnowledgeLink(
            topic: topic,
            description: 'Advanced extension of $skill',
            relevanceScore: 0.6,
            isMastered: false,
          ));
        }
      }
    }

    return links;
  }

  // ── Prerequisites ────────────────────────────────────────────────

  List<KnowledgeLink> _findPrerequisites(
    List<String> masteredSkills,
    List<String> weakSkills,
    GrowthSnapshot? growth,
  ) {
    final prereqs = <KnowledgeLink>[];

    // For each weak skill, find its foundational prerequisites
    for (final weak in weakSkills.take(3)) {
      final foundations = _findFoundationalTopics(weak);
      for (final topic in foundations.take(2)) {
        final isMastered = masteredSkills.any((s) =>
            s.toLowerCase().contains(topic.toLowerCase()));
        if (!isMastered) {
          prereqs.add(KnowledgeLink(
            topic: topic,
            description: 'Foundation for mastering $weak',
            relevanceScore: 0.8,
            isMastered: false,
          ));
        }
      }
    }

    // If overall knowledge is low, suggest general foundations
    if (prereqs.isEmpty && (growth?.knowledge.score ?? 1.0) < 0.4) {
      prereqs.addAll([
        const KnowledgeLink(
          topic: 'Learning Fundamentals',
          description: 'Build a strong foundation before advancing',
          relevanceScore: 0.9,
          isMastered: false,
        ),
        const KnowledgeLink(
          topic: 'Core Concepts',
          description: 'Master core concepts in your target area first',
          relevanceScore: 0.85,
          isMastered: false,
        ),
      ]);
    }

    return prereqs;
  }

  // ── Missing Knowledge ────────────────────────────────────────────

  List<String> _findMissingKnowledge(
    KnowledgeContext knowledge,
    GrowthSnapshot? growth,
    IdentitySnapshot? identity,
  ) {
    final gaps = <String>[];

    // Knowledge gaps from weak skills
    for (final weak in knowledge.weakSkills.take(3)) {
      gaps.add('Strengthen "$weak" — this is an identified weak area');
    }

    // Career-aligned gaps
    if (identity != null && identity.currentGoal.isNotEmpty) {
      final goalKeywords = identity.currentGoal.toLowerCase();
      if (goalKeywords.contains('flutter') &&
          !knowledge.masteredSkills.any((s) =>
              s.toLowerCase().contains('flutter'))) {
        gaps.add('Learn Flutter — aligned with your career goal');
      }
      if (goalKeywords.contains('machine learning') &&
          !knowledge.masteredSkills.any((s) =>
              s.toLowerCase().contains('machine learning'))) {
        gaps.add('Explore Machine Learning — matches your stated goal');
      }
    }

    return gaps;
  }

  // ── Career Impact ────────────────────────────────────────────────

  (String, double) _calculateCareerImpact(
    CareerContext career,
    GrowthSnapshot? growth,
    IdentitySnapshot? identity,
  ) {
    final careerScore = career.careerScore;

    if (careerScore >= 0.8) {
      return (
        'Your career readiness is strong. Focus on interview preparation '
        'and portfolio presentation to convert readiness into opportunities.',
        careerScore,
      );
    } else if (careerScore >= 0.5) {
      return (
        'You\'re building good career momentum. Closing skill gaps and '
        'completing projects will push you into the top tier.',
        careerScore,
      );
    } else if (careerScore >= 0.3) {
      return (
        'Your career foundation needs strengthening. Define your target '
        'role and focus on core skills in that area.',
        careerScore,
      );
    } else {
      final target = identity?.currentGoal.isNotEmpty == true
          ? identity!.currentGoal
          : 'your target role';
      return (
        'Start building career readiness by defining "$target" and '
        'beginning foundational learning missions.',
        careerScore,
      );
    }
  }

  // ── Portfolio Impact ─────────────────────────────────────────────

  (String, double) _calculatePortfolioImpact(
    PortfolioSnapshot? portfolio,
    GrowthSnapshot? growth,
  ) {
    final portfolioScore = portfolio?.portfolioScore ?? 0.0;

    if (portfolioScore >= 0.7) {
      return (
        'Your portfolio is strong. Consider adding case studies with '
        'measurable outcomes to maximize impact.',
        portfolioScore,
      );
    } else if (portfolioScore >= 0.4) {
      return (
        'Your portfolio is developing. Each new project with clear '
        'outcomes significantly strengthens your profile.',
        portfolioScore,
      );
    } else {
      return (
        'Your portfolio needs projects. Even small projects demonstrate '
        'capability and attract opportunities.',
        portfolioScore,
      );
    }
  }

  // ── Next Learning Path ───────────────────────────────────────────

  List<String> _generateNextLearningPath(
    KnowledgeContext knowledge,
    GrowthSnapshot? growth,
    IdentitySnapshot? identity,
  ) {
    final steps = <String>[];

    // Step 1: Address weakest area
    if (knowledge.weakSkills.isNotEmpty) {
      steps.add('Strengthen "${knowledge.weakSkills.first}" with focused practice');
    } else if (knowledge.knowledgeScore < 0.5) {
      steps.add('Build general knowledge through structured learning paths');
    } else {
      steps.add('Deepen expertise in "${knowledge.masteredSkills.first}"');
    }

    // Step 2: Practical application
    if ((growth?.portfolio.score ?? 0.0) < 0.5) {
      steps.add('Apply learning to a portfolio project');
    } else {
      steps.add('Document and showcase completed work');
    }

    // Step 3: Career alignment
    if (identity?.currentGoal != null && identity!.currentGoal.isNotEmpty) {
      steps.add('Align next steps with career goal: "${identity.currentGoal}"');
    }

    // Step 4: Interview readiness
    if ((growth?.interview.score ?? 0.0) < 0.5) {
      steps.add('Practice interview questions on mastered topics');
    }

    return steps;
  }

  // ── Duration Recommendation ──────────────────────────────────────

  int _recommendDuration(GrowthSnapshot? growth) {
    if (growth == null) return 15;
    final consistency = growth.learningConsistency?.score ?? 0.5;
    final knowledge = growth.knowledge.score;

    // New or inconsistent learners: shorter sessions
    if (consistency < 0.3) return 10;
    if (consistency < 0.5) return 15;

    // Consistent learners: standard sessions
    if (knowledge < 0.5) return 20;
    return 25;
  }

  // ── Topic Relationship Helpers ───────────────────────────────────

  /// Finds topics related to a given topic.
  List<String> _findRelatedTopics(String topic) {
    final topicLower = topic.toLowerCase();
    // Map known topics to their related areas
    const related = <String, List<String>>{
      'flutter': ['dart', 'mobile development', 'ui design'],
      'dart': ['flutter', 'backend', 'api development'],
      'javascript': ['typescript', 'react', 'node.js'],
      'typescript': ['javascript', 'angular', 'react'],
      'python': ['data science', 'machine learning', 'backend'],
      'react': ['typescript', 'javascript', 'frontend'],
      'machine learning': ['python', 'data science', 'deep learning'],
      'data science': ['python', 'statistics', 'machine learning'],
      'cloud': ['aws', 'gcp', 'azure', 'devops'],
      'database': ['sql', 'nosql', 'data modeling'],
      'system design': ['architecture', 'microservices', 'scalability'],
    };

    for (final entry in related.entries) {
      if (topicLower.contains(entry.key) ||
          entry.value.any((v) => topicLower.contains(v.toLowerCase()))) {
        return entry.value;
      }
    }

    // Fallback: return generic related topics
    return ['core concepts in $topic', 'practical applications', 'advanced topics'];
  }

  /// Finds foundational/prerequisite topics for a given topic.
  List<String> _findFoundationalTopics(String topic) {
    const foundations = <String, List<String>>{
      'flutter': ['dart basics', 'widget fundamentals', 'state management'],
      'dart': ['programming fundamentals', 'oop concepts'],
      'machine learning': ['python', 'statistics', 'linear algebra'],
      'data science': ['python', 'statistics', 'sql'],
      'react': ['javascript', 'html', 'css'],
      'cloud': ['networking', 'operating systems', 'security basics'],
      'system design': ['algorithms', 'data structures', 'networking'],
    };

    return foundations[topic.toLowerCase()] ??
        ['fundamentals of $topic', 'core concepts'];
  }

  /// Finds advanced topics that extend a mastered skill.
  List<String> _findAdvancedTopics(String skill) {
    const advanced = <String, List<String>>{
      'flutter': ['advanced animations', 'platform channels', 'performance'],
      'dart': ['isolates', 'metaprogramming', 'ffi'],
      'javascript': ['web workers', 'wasm', 'advanced patterns'],
      'python': ['async/await', 'metaclasses', 'c extensions'],
      'react': ['server components', 'suspense', 'state machines'],
      'machine learning': ['transformers', 'reinforcement learning', 'mlops'],
      'cloud': ['multi-cloud', 'service mesh', 'serverless'],
    };

    return advanced[skill.toLowerCase()] ??
        ['advanced $skill techniques'];
  }
}
