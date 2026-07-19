import 'generation_metadata.dart';

// ═════════════════════════════════════════════════════════════════════
// GENERATED COURSE
// ═════════════════════════════════════════════════════════════════════

/// A complete AI-generated course/learning path.
class GeneratedCourse {
  const GeneratedCourse({
    required this.id,
    required this.title,
    required this.description,
    this.modules = const [],
    this.estimatedWeeks = 1,
    this.difficulty = 'intermediate',
    this.prerequisites = const [],
    this.learningOutcomes = const [],
    this.skillTags = const [],
    required this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final List<CourseModule> modules;
  final int estimatedWeeks;
  final String difficulty;
  final List<String> prerequisites;
  final List<String> learningOutcomes;
  final List<String> skillTags;
  final GenerationMetadata metadata;

  int get totalEstimatedHours =>
      modules.fold(0, (sum, m) => sum + m.estimatedHours);
  int get moduleCount => modules.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'modules': modules.map((m) => m.toJson()).toList(),
        'estimatedWeeks': estimatedWeeks,
        'difficulty': difficulty,
        'prerequisites': prerequisites,
        'learningOutcomes': learningOutcomes,
        'skillTags': skillTags,
        'metadata': metadata.toJson(),
      };

  factory GeneratedCourse.fromJson(Map<String, dynamic> json) =>
      GeneratedCourse(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        modules: (json['modules'] as List<dynamic>?)
                ?.map((m) =>
                    CourseModule.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        estimatedWeeks: json['estimatedWeeks'] as int? ?? 1,
        difficulty: json['difficulty'] as String? ?? 'intermediate',
        prerequisites: (json['prerequisites'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        learningOutcomes: (json['learningOutcomes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        skillTags: (json['skillTags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        metadata: GenerationMetadata.fromJson(
            json['metadata'] as Map<String, dynamic>? ?? {}),
      );

  @override
  String toString() =>
      'GeneratedCourse(id: $id, title: $title, modules: ${modules.length})';
}

/// A single module within a generated course.
class CourseModule {
  const CourseModule({
    required this.id,
    required this.title,
    required this.description,
    this.topics = const [],
    this.estimatedHours = 8,
    this.prerequisites = const [],
    this.projects = const [],
  });

  final String id;
  final String title;
  final String description;
  final List<String> topics;
  final int estimatedHours;
  final List<String> prerequisites;
  final List<String> projects;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'topics': topics,
        'estimatedHours': estimatedHours,
        'prerequisites': prerequisites,
        'projects': projects,
      };

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        topics: (json['topics'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        estimatedHours: json['estimatedHours'] as int? ?? 8,
        prerequisites: (json['prerequisites'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        projects: (json['projects'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  @override
  String toString() =>
      'CourseModule(id: $id, title: $title, topics: ${topics.length})';
}

// ═════════════════════════════════════════════════════════════════════
// GENERATED PROJECT
// ═════════════════════════════════════════════════════════════════════

/// An AI-generated portfolio project with milestones.
class GeneratedProject {
  const GeneratedProject({
    required this.id,
    required this.title,
    required this.description,
    this.technologies = const [],
    this.estimatedWeeks = 2,
    this.difficulty = 'intermediate',
    this.milestones = const [],
    this.learningOutcomes = const [],
    this.portfolioImpact = '',
    this.deliverables = const [],
    required this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final List<String> technologies;
  final int estimatedWeeks;
  final String difficulty;
  final List<ProjectMilestone> milestones;
  final List<String> learningOutcomes;
  final String portfolioImpact;
  final List<String> deliverables;
  final GenerationMetadata metadata;

  int get totalEstimatedHours =>
      milestones.fold(0, (sum, m) => sum + m.estimatedHours);
  int get milestoneCount => milestones.length;
  bool get hasTechnologies => technologies.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'technologies': technologies,
        'estimatedWeeks': estimatedWeeks,
        'difficulty': difficulty,
        'milestones': milestones.map((m) => m.toJson()).toList(),
        'learningOutcomes': learningOutcomes,
        'portfolioImpact': portfolioImpact,
        'deliverables': deliverables,
        'metadata': metadata.toJson(),
      };

  factory GeneratedProject.fromJson(Map<String, dynamic> json) =>
      GeneratedProject(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        technologies: (json['technologies'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        estimatedWeeks: json['estimatedWeeks'] as int? ?? 2,
        difficulty: json['difficulty'] as String? ?? 'intermediate',
        milestones: (json['milestones'] as List<dynamic>?)
                ?.map((m) =>
                    ProjectMilestone.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        learningOutcomes: (json['learningOutcomes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        portfolioImpact: json['portfolioImpact'] as String? ?? '',
        deliverables: (json['deliverables'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        metadata: GenerationMetadata.fromJson(
            json['metadata'] as Map<String, dynamic>? ?? {}),
      );

  @override
  String toString() => 'GeneratedProject(id: $id, title: $title, '
      'milestones: ${milestones.length})';
}

/// A milestone within a generated project.
class ProjectMilestone {
  const ProjectMilestone({
    required this.id,
    required this.title,
    required this.description,
    this.estimatedHours = 10,
    this.deliverables = const [],
  });

  final String id;
  final String title;
  final String description;
  final int estimatedHours;
  final List<String> deliverables;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'estimatedHours': estimatedHours,
        'deliverables': deliverables,
      };

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) =>
      ProjectMilestone(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        estimatedHours: json['estimatedHours'] as int? ?? 10,
        deliverables: (json['deliverables'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  @override
  String toString() =>
      'ProjectMilestone(id: $id, title: $title, hours: ${estimatedHours}h)';
}

// ═════════════════════════════════════════════════════════════════════
// GENERATED PORTFOLIO ENHANCEMENT
// ═════════════════════════════════════════════════════════════════════

/// AI-generated suggestions for improving a user's portfolio.
class GeneratedPortfolioEnhancement {
  const GeneratedPortfolioEnhancement({
    required this.id,
    this.suggestedProjects = const [],
    this.skillGaps = const [],
    this.improvementIdeas = const [],
    this.recommendedTechnologies = const [],
    this.portfolioScore = 0,
    this.summary = '',
    required this.metadata,
  });

  final String id;
  final List<String> suggestedProjects;
  final List<String> skillGaps;
  final List<String> improvementIdeas;
  final List<String> recommendedTechnologies;
  final int portfolioScore;
  final String summary;
  final GenerationMetadata metadata;

  Map<String, dynamic> toJson() => {
        'id': id,
        'suggestedProjects': suggestedProjects,
        'skillGaps': skillGaps,
        'improvementIdeas': improvementIdeas,
        'recommendedTechnologies': recommendedTechnologies,
        'portfolioScore': portfolioScore,
        'summary': summary,
        'metadata': metadata.toJson(),
      };

  factory GeneratedPortfolioEnhancement.fromJson(
          Map<String, dynamic> json) =>
      GeneratedPortfolioEnhancement(
        id: json['id'] as String? ?? '',
        suggestedProjects: (json['suggestedProjects'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        skillGaps: (json['skillGaps'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        improvementIdeas: (json['improvementIdeas'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        recommendedTechnologies:
            (json['recommendedTechnologies'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
        portfolioScore: json['portfolioScore'] as int? ?? 0,
        summary: json['summary'] as String? ?? '',
        metadata: GenerationMetadata.fromJson(
            json['metadata'] as Map<String, dynamic>? ?? {}),
      );

  @override
  String toString() =>
      'GeneratedPortfolioEnhancement(id: $id, score: $portfolioScore)';
}

// ═════════════════════════════════════════════════════════════════════
// GENERATED RESUME ENHANCEMENT
// ═════════════════════════════════════════════════════════════════════

/// AI-generated suggestions for improving a user's resume.
class GeneratedResumeEnhancement {
  const GeneratedResumeEnhancement({
    required this.id,
    this.suggestedSections = const [],
    this.bulletPointImprovements = const [],
    this.missingKeywords = const [],
    this.formattingSuggestions = const [],
    this.atsScore = 0,
    this.summary = '',
    required this.metadata,
  });

  final String id;
  final List<String> suggestedSections;
  final List<String> bulletPointImprovements;
  final List<String> missingKeywords;
  final List<String> formattingSuggestions;
  final int atsScore;
  final String summary;
  final GenerationMetadata metadata;

  Map<String, dynamic> toJson() => {
        'id': id,
        'suggestedSections': suggestedSections,
        'bulletPointImprovements': bulletPointImprovements,
        'missingKeywords': missingKeywords,
        'formattingSuggestions': formattingSuggestions,
        'atsScore': atsScore,
        'summary': summary,
        'metadata': metadata.toJson(),
      };

  factory GeneratedResumeEnhancement.fromJson(
          Map<String, dynamic> json) =>
      GeneratedResumeEnhancement(
        id: json['id'] as String? ?? '',
        suggestedSections: (json['suggestedSections'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        bulletPointImprovements:
            (json['bulletPointImprovements'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
        missingKeywords: (json['missingKeywords'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        formattingSuggestions:
            (json['formattingSuggestions'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
        atsScore: json['atsScore'] as int? ?? 0,
        summary: json['summary'] as String? ?? '',
        metadata: GenerationMetadata.fromJson(
            json['metadata'] as Map<String, dynamic>? ?? {}),
      );

  @override
  String toString() =>
      'GeneratedResumeEnhancement(id: $id, atsScore: $atsScore)';
}

// ═════════════════════════════════════════════════════════════════════
// GENERATED INTERVIEW QUESTIONS
// ═════════════════════════════════════════════════════════════════════

/// A set of AI-generated interview questions for practice.
class GeneratedInterviewQuestions {
  const GeneratedInterviewQuestions({
    required this.id,
    this.targetRole = '',
    this.technicalQuestions = const [],
    this.behavioralQuestions = const [],
    this.situationalQuestions = const [],
    this.overallTips = const [],
    this.estimatedMinutes = 30,
    this.difficulty = 'intermediate',
    required this.metadata,
  });

  final String id;
  final String targetRole;
  final List<InterviewQuestionItem> technicalQuestions;
  final List<InterviewQuestionItem> behavioralQuestions;
  final List<InterviewQuestionItem> situationalQuestions;
  final List<String> overallTips;
  final int estimatedMinutes;
  final String difficulty;
  final GenerationMetadata metadata;

  int get totalQuestions =>
      technicalQuestions.length +
      behavioralQuestions.length +
      situationalQuestions.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetRole': targetRole,
        'technicalQuestions':
            technicalQuestions.map((q) => q.toJson()).toList(),
        'behavioralQuestions':
            behavioralQuestions.map((q) => q.toJson()).toList(),
        'situationalQuestions':
            situationalQuestions.map((q) => q.toJson()).toList(),
        'overallTips': overallTips,
        'estimatedMinutes': estimatedMinutes,
        'difficulty': difficulty,
        'metadata': metadata.toJson(),
      };

  factory GeneratedInterviewQuestions.fromJson(
          Map<String, dynamic> json) =>
      GeneratedInterviewQuestions(
        id: json['id'] as String? ?? '',
        targetRole: json['targetRole'] as String? ?? '',
        technicalQuestions: (json['technicalQuestions'] as List<dynamic>?)
                ?.map((q) =>
                    InterviewQuestionItem.fromJson(q as Map<String, dynamic>))
                .toList() ??
            [],
        behavioralQuestions: (json['behavioralQuestions'] as List<dynamic>?)
                ?.map((q) =>
                    InterviewQuestionItem.fromJson(q as Map<String, dynamic>))
                .toList() ??
            [],
        situationalQuestions: (json['situationalQuestions'] as List<dynamic>?)
                ?.map((q) =>
                    InterviewQuestionItem.fromJson(q as Map<String, dynamic>))
                .toList() ??
            [],
        overallTips: (json['overallTips'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        estimatedMinutes: json['estimatedMinutes'] as int? ?? 30,
        difficulty: json['difficulty'] as String? ?? 'intermediate',
        metadata: GenerationMetadata.fromJson(
            json['metadata'] as Map<String, dynamic>? ?? {}),
      );

  @override
  String toString() =>
      'GeneratedInterviewQuestions(id: $id, role: $targetRole, '
      'questions: $totalQuestions)';
}

/// A single interview question within a generated set.
class InterviewQuestionItem {
  const InterviewQuestionItem({
    required this.id,
    required this.question,
    this.expectedAnswer = '',
    this.tips = const [],
    this.difficulty = 'medium',
    this.category,
  });

  final String id;
  final String question;
  final String expectedAnswer;
  final List<String> tips;
  final String difficulty;
  final String? category;

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'expectedAnswer': expectedAnswer,
        'tips': tips,
        'difficulty': difficulty,
        if (category != null) 'category': category,
      };

  factory InterviewQuestionItem.fromJson(Map<String, dynamic> json) =>
      InterviewQuestionItem(
        id: json['id'] as String? ?? '',
        question: json['question'] as String? ?? '',
        expectedAnswer: json['expectedAnswer'] as String? ?? '',
        tips: (json['tips'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        difficulty: json['difficulty'] as String? ?? 'medium',
        category: json['category'] as String?,
      );

  @override
  String toString() =>
      'InterviewQuestionItem(id: $id, difficulty: $difficulty)';
}
