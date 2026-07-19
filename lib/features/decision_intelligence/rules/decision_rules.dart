import '../../identity/models/identity_snapshot.dart';
import '../../growth_index/models/growth_snapshot.dart';
import '../../mission_intelligence/models/mission_snapshot.dart';
import '../../career/engine/career_snapshot.dart';
import '../../portfolio/engine/portfolio_snapshot.dart';
import '../../progress_engine/achievement_snapshot.dart';
import '../../memory_engine/models/memory_snapshot.dart';
import '../models/decision_priority.dart';
import '../models/decision_reason.dart';
import '../models/decision_recommendation.dart';
import '../models/decision_type.dart';

/// Context bundle passed to every decision rule.
///
/// Each rule reads only the fields it needs. Fields may be null if
/// the corresponding engine is not yet initialized.
class DecisionContext {
  const DecisionContext({
    this.identitySnapshot,
    this.growthSnapshot,
    this.missionSnapshot,
    this.careerSnapshot,
    this.portfolioSnapshot,
    this.achievementSnapshot,
    this.memorySnapshot,
    this.activeMissionTitle = '',
    this.activeMissionProgress = 0.0,
    this.hasOverdueMissions = false,
    this.portfolioProjectCount = 0,
    this.portfolioScore = 0.0,
    this.interviewReadiness = 0.0,
    this.careerScore = 0.0,
    this.knowledgeScore = 0.0,
    this.weakSkills = const [],
    this.strongSkills = const [],
    this.recentActivityCount = 0,
    this.streak = 0,
    this.totalXp = 0,
    this.level = 1,
  });

  final IdentitySnapshot? identitySnapshot;
  final GrowthSnapshot? growthSnapshot;
  final MissionSnapshot? missionSnapshot;
  final CareerSnapshot? careerSnapshot;
  final PortfolioSnapshot? portfolioSnapshot;
  final AchievementSnapshot? achievementSnapshot;
  final MemorySnapshot? memorySnapshot;

  final String activeMissionTitle;
  final double activeMissionProgress;
  final bool hasOverdueMissions;
  final int portfolioProjectCount;
  final double portfolioScore;
  final double interviewReadiness;
  final double careerScore;
  final double knowledgeScore;
  final List<String> weakSkills;
  final List<String> strongSkills;
  final int recentActivityCount;
  final int streak;
  final int totalXp;
  final int level;
}

/// Abstract interface for a single decision rule.
///
/// Each rule evaluates the [DecisionContext] and optionally produces a
/// [DecisionRecommendation] if its conditions are met.
///
/// Rules are stateless and deterministic — all state comes from the context.
abstract class DecisionRule {
  const DecisionRule();

  /// Unique name for this rule.
  String get name;

  /// Evaluation priority (higher = evaluated first).
  int get priority => 1;

  /// Evaluates the context and returns a recommendation if conditions are met.
  DecisionRecommendation? evaluate(DecisionContext context);
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 1: Continue Mission
// ═══════════════════════════════════════════════════════════════════════════

/// If the user has an active mission in progress, recommend continuing it.
class ContinueMissionRule extends DecisionRule {
  const ContinueMissionRule();

  @override
  String get name => 'ContinueMission';

  @override
  int get priority => 5;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.activeMissionTitle.isEmpty) return null;

    final progress = ctx.activeMissionProgress;
    final urgency = progress > 0.3 ? 80 : 50;
    final impact = 70;
    final confidence = 85;
    final overall = ((urgency * 0.4) + (impact * 0.3) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-continue-mission',
      type: DecisionType.continueMission,
      title: 'Continue: ${ctx.activeMissionTitle}',
      description: progress > 0
          ? 'You\'re ${(progress * 100).round()}% through your current mission. '
              'Keep the momentum going!'
          : 'Resume your active mission and make progress toward your goal.',
      reason: DecisionReason(
        why: 'You have an active mission that needs attention.',
        whyNow: progress > 0.5
            ? 'You\'re more than halfway there! Don\'t lose your progress.'
            : 'Starting fresh builds momentum for the day.',
        ifSkipped: 'Your mission progress may stall, making it harder to complete later.',
        unlocks: 'Mission completion rewards and next-level content.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: (30 * (1 + progress)).round(),
        estimatedMinutes: (30 * (1 - progress * 0.5)).round().clamp(10, 60),
      ),
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 2: Review Lesson
// ═══════════════════════════════════════════════════════════════════════════

/// If the user has recently completed lessons, recommend a review.
class ReviewLessonRule extends DecisionRule {
  const ReviewLessonRule();

  @override
  String get name => 'ReviewLesson';

  @override
  int get priority => 3;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    final recentActivity = ctx.recentActivityCount;
    if (recentActivity < 2) return null;

    final urgency = 40;
    final impact = 50;
    final confidence = 70;
    final overall = ((urgency * 0.3) + (impact * 0.4) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-review-lesson',
      type: DecisionType.reviewLesson,
      title: 'Review Recent Lessons',
      description: 'You\'ve completed $recentActivity activities recently. '
          'A quick review will reinforce your learning and improve retention.',
      reason: DecisionReason(
        why: 'Reviewing within 24 hours triples long-term retention.',
        whyNow: 'You have recent activity that would benefit from review.',
        ifSkipped: 'Retention drops rapidly without review within the first 24 hours.',
        unlocks: 'Stronger long-term memory and better assessment scores.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 15,
        estimatedMinutes: 15,
      ),
      relatedSkills: ctx.strongSkills,
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 3: Start Project
// ═══════════════════════════════════════════════════════════════════════════

/// If portfolio is light, recommend starting a new project.
class StartProjectRule extends DecisionRule {
  const StartProjectRule();

  @override
  String get name => 'StartProject';

  @override
  int get priority => 4;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.portfolioProjectCount >= 3) return null;

    final urgency = ctx.portfolioProjectCount == 0 ? 80 : 60;
    final impact = 75;
    final confidence = 80;
    final overall = ((urgency * 0.35) + (impact * 0.35) + (confidence * 0.3)).round();

    final projectCount = ctx.portfolioProjectCount;
    final reason = projectCount == 0
        ? 'Your portfolio is empty — projects are the best evidence of your skills.'
        : 'You have $projectCount project${projectCount == 1 ? '' : 's'} — adding more strengthens your portfolio.';

    return DecisionRecommendation(
      id: 'dec-start-project',
      type: DecisionType.startProject,
      title: projectCount == 0
          ? 'Start Your First Project'
          : 'Add Another Project',
      description: reason,
      reason: DecisionReason(
        why: 'A strong portfolio is essential for career growth.',
        whyNow: 'Projects demonstrate real-world skills better than any certification.',
        ifSkipped: 'Your portfolio remains sparse, reducing career opportunities.',
        unlocks: 'Portfolio reviews, project showcases, and career referrals.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 50,
        estimatedMinutes: 45,
      ),
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 4: Take Assessment
// ═══════════════════════════════════════════════════════════════════════════

/// If the user has strong skills and recent learning, suggest an assessment.
class TakeAssessmentRule extends DecisionRule {
  const TakeAssessmentRule();

  @override
  String get name => 'TakeAssessment';

  @override
  int get priority => 3;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.strongSkills.isEmpty || ctx.recentActivityCount < 3) return null;

    final urgency = 50;
    final impact = 65;
    final confidence = 70;
    final overall = ((urgency * 0.3) + (impact * 0.4) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-take-assessment',
      type: DecisionType.takeAssessment,
      title: 'Test Your Knowledge',
      description: 'You\'ve built skills in ${ctx.strongSkills.take(2).join(' and ')}. '
          'An assessment will validate your progress and identify gaps.',
      reason: DecisionReason(
        why: 'Assessments validate learning and identify knowledge gaps.',
        whyNow: 'You have enough recent activity to make an assessment meaningful.',
        ifSkipped: 'You may overestimate your knowledge without objective measurement.',
        unlocks: 'Skill certifications, confidence scores, and targeted revision.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 25,
        estimatedMinutes: 20,
      ),
      relatedSkills: ctx.strongSkills,
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 5: Practice Interview
// ═══════════════════════════════════════════════════════════════════════════

/// If interview readiness is below threshold, recommend interview practice.
class PracticeInterviewRule extends DecisionRule {
  const PracticeInterviewRule();

  @override
  String get name => 'PracticeInterview';

  @override
  int get priority => 4;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.interviewReadiness >= 0.6) return null;

    final gap = 1.0 - ctx.interviewReadiness;
    final urgency = (gap * 100).round();
    final impact = 70;
    final confidence = 75;
    final overall = ((urgency * 0.35) + (impact * 0.35) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-practice-interview',
      type: DecisionType.practiceInterview,
      title: 'Practice Interview Questions',
      description: 'Your interview readiness is ${(ctx.interviewReadiness * 100).round()}%. '
          'Regular practice builds confidence and improves performance.',
      reason: DecisionReason(
        why: 'Interview readiness is below the recommended threshold.',
        whyNow: 'Consistent practice dramatically improves real interview performance.',
        ifSkipped: 'Low interview readiness reduces offer rates and negotiation power.',
        unlocks: 'Higher confidence, better offers, and more career options.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 20,
        estimatedMinutes: 30,
      ),
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 6: Revise Topic
// ═══════════════════════════════════════════════════════════════════════════

/// If weak skills are identified, recommend revision.
class ReviseTopicRule extends DecisionRule {
  const ReviseTopicRule();

  @override
  String get name => 'ReviseTopic';

  @override
  int get priority => 3;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.weakSkills.isEmpty) return null;

    final topWeak = ctx.weakSkills.first;
    final urgency = 65;
    final impact = 60;
    final confidence = 75;
    final overall = ((urgency * 0.3) + (impact * 0.4) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-revise-topic',
      type: DecisionType.reviseTopic,
      title: 'Revise: $topWeak',
      description: ctx.weakSkills.length > 1
          ? 'Your weakest areas are ${ctx.weakSkills.join(', ')}. '
              'Start with $topWeak for the biggest improvement.'
          : '$topWeak is your weakest area. Focused revision will boost your knowledge score.',
      reason: DecisionReason(
        why: '$topWeak is your weakest skill area.',
        whyNow: 'Addressing weak areas has the highest impact on overall growth.',
        ifSkipped: 'Knowledge gaps widen over time, making future learning harder.',
        unlocks: 'Improved knowledge score, confidence, and learning velocity.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 20,
        estimatedMinutes: 25,
      ),
      relatedSkills: [topWeak, ...ctx.weakSkills.skip(1).take(2)],
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 7: Update Resume
// ═══════════════════════════════════════════════════════════════════════════

/// If career is active and resume hasn't been updated, recommend resume update.
class UpdateResumeRule extends DecisionRule {
  const UpdateResumeRule();

  @override
  String get name => 'UpdateResume';

  @override
  int get priority => 2;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.careerScore < 0.3) return null;

    final urgency = 45;
    final impact = 60;
    final confidence = 65;
    final overall = ((urgency * 0.3) + (impact * 0.4) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-update-resume',
      type: DecisionType.updateResume,
      title: 'Update Your Resume',
      description: 'Your career score is ${(ctx.careerScore * 100).round()}%. '
          'Keep your resume current with your latest skills and projects.',
      reason: DecisionReason(
        why: 'An up-to-date resume is essential for career opportunities.',
        whyNow: 'Your career is progressing — your resume should reflect that.',
        ifSkipped: 'Your resume becomes outdated, missing recent achievements.',
        unlocks: 'Better job matches, interview invitations, and career growth.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 15,
        estimatedMinutes: 30,
      ),
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 8: Improve Portfolio
// ═══════════════════════════════════════════════════════════════════════════

/// If portfolio score is below threshold, recommend portfolio improvement.
class ImprovePortfolioRule extends DecisionRule {
  const ImprovePortfolioRule();

  @override
  String get name => 'ImprovePortfolio';

  @override
  int get priority => 3;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.portfolioScore >= 0.5) return null;

    final gap = 0.5 - ctx.portfolioScore;
    final urgency = (gap * 150).round().clamp(30, 80);
    final impact = 65;
    final confidence = 70;
    final overall = ((urgency * 0.35) + (impact * 0.35) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-improve-portfolio',
      type: DecisionType.improvePortfolio,
      title: 'Strengthen Your Portfolio',
      description: 'Your portfolio score is ${(ctx.portfolioScore * 100).round()}%. '
          'Adding projects, certificates, or detailed descriptions will boost it.',
      reason: DecisionReason(
        why: 'Your portfolio is below the recommended strength.',
        whyNow: 'A strong portfolio is your best career asset.',
        ifSkipped: 'Career opportunities diminish without a compelling portfolio.',
        unlocks: 'Portfolio reviews, better job matches, and credibility.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 30,
        estimatedMinutes: 40,
      ),
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 9: Take Break
// ═══════════════════════════════════════════════════════════════════════════

/// If the user has high recent activity with no breaks, recommend a short break.
class TakeBreakRule extends DecisionRule {
  const TakeBreakRule();

  @override
  String get name => 'TakeBreak';

  @override
  int get priority => 2;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.recentActivityCount < 5) return null;
    if (ctx.streak < 3) return null;

    final urgency = 40;
    final impact = 50;
    final confidence = 60;
    final overall = ((urgency * 0.3) + (impact * 0.3) + (confidence * 0.4)).round();

    return DecisionRecommendation(
      id: 'dec-take-break',
      type: DecisionType.takeBreak,
      title: 'Take a Short Break',
      description: 'You\'ve been consistently active for ${ctx.streak} days. '
          'A short break will help consolidate your learning and prevent burnout.',
      reason: DecisionReason(
        why: 'Consistent learning is great, but breaks improve long-term retention.',
        whyNow: 'Your ${ctx.streak}-day streak shows strong dedication — rest is part of growth.',
        ifSkipped: 'Risk of burnout and diminishing returns on learning.',
        unlocks: 'Better focus, improved retention, and sustained motivation.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 5,
        estimatedMinutes: 15,
      ),
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 10: Rest Day
// ═══════════════════════════════════════════════════════════════════════════

/// If the user has very high streak and activity, recommend a full rest day.
class RestDayRule extends DecisionRule {
  const RestDayRule();

  @override
  String get name => 'RestDay';

  @override
  int get priority => 1;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.streak < 7) return null;
    if (ctx.recentActivityCount < 10) return null;

    final urgency = 50;
    final impact = 60;
    final confidence = 55;
    final overall = ((urgency * 0.25) + (impact * 0.3) + (confidence * 0.45)).round();

    return DecisionRecommendation(
      id: 'dec-rest-day',
      type: DecisionType.restDay,
      title: 'Take a Rest Day',
      description: 'You\'ve been on a ${ctx.streak}-day streak! '
          'Taking a full day off helps your brain consolidate everything you\'ve learned.',
      reason: DecisionReason(
        why: 'Extended learning without rest reduces effectiveness.',
        whyNow: 'After ${ctx.streak} days of consistent activity, your brain needs consolidation time.',
        ifSkipped: 'Continued learning without rest leads to diminishing returns.',
        unlocks: 'Stronger long-term retention and renewed motivation.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 0,
        estimatedMinutes: 0,
      ),
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 11: Explore Technology
// ═══════════════════════════════════════════════════════════════════════════

/// If the user has career goals but limited technology exposure, suggest exploration.
class ExploreTechnologyRule extends DecisionRule {
  const ExploreTechnologyRule();

  @override
  String get name => 'ExploreTechnology';

  @override
  int get priority => 2;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.careerScore < 0.4) return null;
    if ((ctx.portfolioSnapshot?.technologyCount ?? 0) >= 5) return null;

    final urgency = 40;
    final impact = 55;
    final confidence = 60;
    final overall = ((urgency * 0.3) + (impact * 0.4) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-explore-tech',
      type: DecisionType.exploreTechnology,
      title: 'Explore a New Technology',
      description: 'Broadening your technology stack makes you more versatile and '
          'opens up new career opportunities.',
      reason: DecisionReason(
        why: 'A diverse technology stack is valuable for career growth.',
        whyNow: 'You have room to expand beyond your current technologies.',
        ifSkipped: 'Your technology profile stays narrow, limiting opportunities.',
        unlocks: 'New project ideas, career paths, and market relevance.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 25,
        estimatedMinutes: 30,
      ),
      ruleName: name,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RULE 12: Career Action
// ═══════════════════════════════════════════════════════════════════════════

/// If career readiness is moderate, recommend a general career action.
class CareerActionRule extends DecisionRule {
  const CareerActionRule();

  @override
  String get name => 'CareerAction';

  @override
  int get priority => 3;

  @override
  DecisionRecommendation? evaluate(DecisionContext ctx) {
    if (ctx.careerScore < 0.5 || ctx.careerScore >= 0.85) return null;

    final urgency = 50;
    final impact = 60;
    final confidence = 65;
    final overall = ((urgency * 0.3) + (impact * 0.4) + (confidence * 0.3)).round();

    return DecisionRecommendation(
      id: 'dec-career-action',
      type: DecisionType.careerAction,
      title: 'Take a Career Action',
      description: 'Your career score is ${(ctx.careerScore * 100).round()}% — '
          'there\'s room to grow. Update your resume, practice interviews, or network.',
      reason: DecisionReason(
        why: 'Career development requires consistent proactive action.',
        whyNow: 'Your career score indicates good progress with room for growth.',
        ifSkipped: 'Career growth stalls without regular proactive steps.',
        unlocks: 'Better opportunities, higher confidence, and career advancement.',
      ),
      score: DecisionScore(
        overall: overall,
        urgency: urgency,
        impact: impact,
        confidence: confidence,
        estimatedXp: 20,
        estimatedMinutes: 30,
      ),
      ruleName: name,
    );
  }
}
