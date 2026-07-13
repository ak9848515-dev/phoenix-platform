import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../../career/services/career_service.dart';
import '../../decision/services/decision_service.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../../portfolio/services/portfolio_service.dart';
import '../../resume/models/resume.dart';
import '../../resume/services/resume_service.dart';
import '../models/interview_profile.dart';
import '../models/interview_question.dart';

/// Builds the user's Interview Intelligence profile.
///
/// Derives interview readiness, technical/behavioral/communication scores,
/// strengths, improvement areas, recommended topics, and mock questions
/// from existing Phoenix modules.
///
/// No AI, no networking, no persistence, no duplicate business logic.
///
/// Future capabilities (architecture placeholders only):
///   - AI Mock Interview
///   - Voice Interview
///   - Video Interview
///   - Interview Recording
///   - Interview History
class InterviewService {
  InterviewService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  // ── Internal service accessors ──────────────────────────────────────

  ResumeService get _resumeService => ResumeService(repository: repository);

  PortfolioService get _portfolioService =>
      PortfolioService(repository: repository);

  CareerService get _careerService => CareerService(repository: repository);

  KnowledgeDNAService get _knowledgeDnaService =>
      KnowledgeDNAService(repository: repository);

  DecisionService get _decisionService =>
      DecisionService(repository: repository);

  // ── Public API ──────────────────────────────────────────────────────

  /// Builds the full interview profile from all module data.
  InterviewProfile buildProfile() {
    final identity = repository.selectedIdentity;
    final portfolio = _portfolioService.buildPortfolio();
    final careerProfile = _careerService.buildProfile();
    final knowledgeAnalysis = _knowledgeDnaService.buildAnalysis();
    final topDecision = _decisionService.getDecision();
    final resume = _resumeService.buildResume();

    final readiness = _deriveInterviewReadiness(careerProfile);
    final technicalScore = _deriveTechnicalScore(
      knowledgeAnalysis.knowledgeScore,
      careerProfile.careerScore,
    );
    final behavioralScore = _deriveBehavioralScore(
      knowledgeAnalysis.confidenceScore,
      knowledgeAnalysis.retentionScore,
    );
    final communicationScore = _deriveCommunicationScore(
      knowledgeAnalysis.confidenceScore,
      knowledgeAnalysis.retentionScore,
    );
    final strengths = _deriveStrengths(portfolio, careerProfile);
    final improvementAreas = _deriveImprovementAreas(portfolio, careerProfile);
    final recommendedTopics = _deriveRecommendedTopics(
      knowledgeAnalysis,
      careerProfile,
      topDecision.title,
    );
    final mockQuestions = _generateMockQuestions(
      resume.resumeType,
      technicalScore,
      improvementAreas,
    );
    final estimatedDays = (careerProfile.estimatedWeeks * 7 * (1.0 - readiness))
        .round()
        .clamp(1, 365);

    return InterviewProfile(
      id: 'interview-${identity.id}',
      identityId: identity.id,
      interviewReadiness: readiness,
      technicalScore: technicalScore,
      behavioralScore: behavioralScore,
      communicationScore: communicationScore,
      strengths: strengths,
      improvementAreas: improvementAreas,
      recommendedTopics: recommendedTopics,
      mockQuestions: mockQuestions,
      estimatedPreparationDays: estimatedDays,
    );
  }

  // ── Score derivation ────────────────────────────────────────────────

  /// Derives interview readiness from career profile.
  double _deriveInterviewReadiness(dynamic careerProfile) {
    // Weighted: career score (60%) + interviewReadiness (40%)
    return (careerProfile.careerScore * 0.60 +
            careerProfile.interviewReadiness * 0.40)
        .clamp(0.0, 1.0);
  }

  /// Derives technical interview score.
  double _deriveTechnicalScore(double knowledgeScore, double careerScore) {
    // Weighted: Knowledge DNA knowledge (60%) + career (40%)
    return (knowledgeScore * 0.60 + careerScore * 0.40).clamp(0.0, 1.0);
  }

  /// Derives behavioral interview score.
  double _deriveBehavioralScore(double confidenceScore, double retentionScore) {
    // Weighted: confidence (60%) + retention (40%)
    return (confidenceScore * 0.60 + retentionScore * 0.40).clamp(0.0, 1.0);
  }

  /// Derives communication score.
  double _deriveCommunicationScore(
    double confidenceScore,
    double retentionScore,
  ) {
    // Weighted: retention (50%) + confidence (50%)
    return (retentionScore * 0.50 + confidenceScore * 0.50).clamp(0.0, 1.0);
  }

  // ── Strength & improvement derivation ───────────────────────────────

  /// Derives interview-related strengths.
  List<String> _deriveStrengths(dynamic portfolio, dynamic careerProfile) {
    final strengths = <String>[
      ...portfolio.strengthAreas,
      ...careerProfile.strengths,
    ];
    return strengths.toSet().toList();
  }

  /// Derives interview improvement areas.
  List<String> _deriveImprovementAreas(
    dynamic portfolio,
    dynamic careerProfile,
  ) {
    final areas = <String>[
      ...portfolio.improvementAreas,
      ...careerProfile.skillGaps,
    ];
    return areas.toSet().toList();
  }

  /// Derives recommended topics to study for interviews.
  List<String> _deriveRecommendedTopics(
    dynamic knowledgeAnalysis,
    dynamic careerProfile,
    String topDecision,
  ) {
    final topics = <String>[
      ...knowledgeAnalysis.skillWeaknesses,
      ...careerProfile.skillGaps,
      topDecision,
    ];
    return topics.toSet().toList();
  }

  // ── Mock question generation ────────────────────────────────────────

  /// Generates mock interview questions based on resume type and scores.
  List<InterviewQuestion> _generateMockQuestions(
    ResumeType resumeType,
    double technicalScore,
    List<String> improvementAreas,
  ) {
    final questions = <InterviewQuestion>[];

    // Technical questions based on resume type
    questions.addAll(_buildTechnicalQuestions(resumeType, technicalScore));
    questions.addAll(_buildBehavioralQuestions());
    questions.addAll(_buildSystemDesignQuestions(resumeType));

    // Add questions from improvement areas
    for (final area in improvementAreas.take(3)) {
      questions.add(
        InterviewQuestion(
          id: 'q-improve-${area.toLowerCase().replaceAll(' ', '_')}',
          question:
              'Describe your experience with $area and how you '
              'approach challenges in this area.',
          questionType: QuestionType.technical,
          difficulty: 0.6,
          topics: [area],
        ),
      );
    }

    return questions;
  }

  /// Builds technical interview questions.
  List<InterviewQuestion> _buildTechnicalQuestions(
    ResumeType resumeType,
    double technicalScore,
  ) {
    final isStrong = technicalScore >= 0.6;
    final label = resumeType.label;
    return [
      InterviewQuestion(
        id: 'q-tech-1',
        question:
            'Walk me through your most recent project. '
            'What was your role and what technologies did you use?',
        questionType: QuestionType.technical,
        difficulty: isStrong ? 0.7 : 0.4,
        topics: ['project experience', 'technology stack'],
        tips: [
          'Focus on your specific contributions.',
          'Mention challenges and how you solved them.',
        ],
      ),
      InterviewQuestion(
        id: 'q-tech-2',
        question:
            'How do you stay up to date with the latest trends '
            'in $label?',
        questionType: QuestionType.technical,
        difficulty: 0.4,
        topics: ['professional development', 'learning habits'],
        tips: [
          'Mention specific resources you follow.',
          'Show genuine enthusiasm for learning.',
        ],
      ),
    ];
  }

  /// Builds behavioral interview questions.
  List<InterviewQuestion> _buildBehavioralQuestions() {
    return [
      InterviewQuestion(
        id: 'q-behav-1',
        question:
            'Tell me about a time you faced a difficult challenge '
            'and how you overcame it.',
        questionType: QuestionType.behavioral,
        difficulty: 0.5,
        topics: ['problem solving', 'resilience'],
        tips: ['Use the STAR method: Situation, Task, Action, Result.'],
      ),
      InterviewQuestion(
        id: 'q-behav-2',
        question:
            'Describe a situation where you had to work '
            'collaboratively on a team project.',
        questionType: QuestionType.behavioral,
        difficulty: 0.5,
        topics: ['teamwork', 'collaboration'],
        tips: [
          'Highlight your role in the team.',
          'Mention how you handled conflicts.',
        ],
      ),
      InterviewQuestion(
        id: 'q-behav-3',
        question:
            'What is your greatest professional weakness '
            'and how are you working to improve it?',
        questionType: QuestionType.behavioral,
        difficulty: 0.4,
        topics: ['self-awareness', 'growth mindset'],
        tips: [
          'Be honest but show progress.',
          'Focus on actions you are taking to improve.',
        ],
      ),
    ];
  }

  /// Builds system design questions relevant to the resume type.
  List<InterviewQuestion> _buildSystemDesignQuestions(ResumeType resumeType) {
    final lower = resumeType.label.toLowerCase();
    final isTechnical =
        lower.contains('engineer') || lower.contains('developer');
    if (!isTechnical) return [];

    return [
      InterviewQuestion(
        id: 'q-sd-1',
        question:
            'Design a simple system for managing user '
            'authentication and profiles. What components would '
            'you include and why?',
        questionType: QuestionType.systemDesign,
        difficulty: 0.7,
        topics: ['system design', 'architecture', 'authentication'],
        tips: [
          'Start with requirements.',
          'Discuss trade-offs.',
          'Consider scalability and security.',
        ],
      ),
      InterviewQuestion(
        id: 'q-sd-2',
        question:
            'How would you design a REST API for a '
            'task management application? Walk through '
            'your endpoint design and data model.',
        questionType: QuestionType.systemDesign,
        difficulty: 0.6,
        topics: ['API design', 'REST', 'data modeling'],
        tips: [
          'Define resources first.',
          'Consider error handling.',
          'Discuss authentication and authorization.',
        ],
      ),
    ];
  }
}
