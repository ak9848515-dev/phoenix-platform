import 'career_roadmap.dart';

/// Templates for generating deterministic career roadmaps.
///
/// Each horizon has milestones for learning, projects, certifications,
/// interviews, portfolio improvements, and networking.
class RoadmapPlan {
  RoadmapPlan._();

  /// Generates a roadmap for the specified horizon.
  static CareerRoadmap generate({
    required String id,
    required int horizonDays,
    required List<String> skillGaps,
    required double interviewReadiness,
    required double resumeProgress,
    required double portfolioProgress,
    bool isReady = false,
    bool careerUndefined = false,
  }) {
    switch (horizonDays) {
      case 30:
        return _plan30(id, skillGaps, interviewReadiness, resumeProgress, portfolioProgress, careerUndefined);
      case 90:
        return _plan90(id, skillGaps, interviewReadiness, resumeProgress, portfolioProgress, isReady);
      case 180:
        return _plan180(id, skillGaps, isReady);
      case 365:
        return _plan365(id, skillGaps, isReady);
      default:
        return _plan30(id, skillGaps, interviewReadiness, resumeProgress, portfolioProgress, careerUndefined);
    }
  }

  static CareerRoadmap _plan30(
    String id,
    List<String> gaps,
    double interview,
    double resume,
    double portfolio,
    bool undefined,
  ) {
    final milestones = <RoadmapMilestone>[];

    if (undefined) {
      milestones.add(const RoadmapMilestone(
        id: '30_define_career',
        title: 'Define Your Career Goal',
        description: 'Complete your identity profile to set a clear career direction.',
        category: 'assessment',
        estimatedDays: 1,
        route: '/identity',
      ));
    }

    if (gaps.isNotEmpty) {
      final topGap = gaps.first;
      milestones.add(RoadmapMilestone(
        id: '30_learn_${topGap.toLowerCase().replaceAll(' ', '_')}',
        title: 'Learn $topGap',
        description: 'Start learning $topGap through guided learning paths.',
        category: 'learning',
        estimatedDays: 14,
        route: '/academy',
      ));
    }

    if (resume < 0.6) {
      milestones.add(const RoadmapMilestone(
        id: '30_update_resume',
        title: 'Update Your Resume',
        description: 'Polish your resume with current skills and projects.',
        category: 'resume',
        estimatedDays: 2,
        route: '/resume',
      ));
    }

    if (portfolio < 0.5) {
      milestones.add(const RoadmapMilestone(
        id: '30_portfolio_project',
        title: 'Build a Portfolio Project',
        description: 'Create a project demonstrating your core skills.',
        category: 'project',
        estimatedDays: 14,
        route: '/portfolio',
      ));
    }

    milestones.add(const RoadmapMilestone(
      id: '30_assessment',
      title: 'Complete Skill Assessment',
      description: 'Evaluate your current skill level across key areas.',
      category: 'assessment',
      estimatedDays: 1,
      route: '/progress',
    ));

    return CareerRoadmap(
      id: id,
      horizonDays: 30,
      title: 'Foundation & Momentum',
      description: 'Build foundational skills and update career materials.',
      milestones: milestones,
    );
  }

  static CareerRoadmap _plan90(
    String id,
    List<String> gaps,
    double interview,
    double resume,
    double portfolio,
    bool isReady,
  ) {
    final milestones = <RoadmapMilestone>[];

    // Address remaining skill gaps
    for (var i = 0; i < gaps.length && i < 2; i++) {
      final gap = gaps[i];
      milestones.add(RoadmapMilestone(
        id: '90_learn_${gap.toLowerCase().replaceAll(' ', '_')}',
        title: 'Master $gap',
        description: 'Achieve proficiency in $gap through projects and practice.',
        category: 'learning',
        estimatedDays: 21,
        route: '/academy',
      ));
    }

    // Build projects
    if (!isReady) {
      milestones.add(const RoadmapMilestone(
        id: '90_build_projects',
        title: 'Complete 2 Portfolio Projects',
        description: 'Build projects that demonstrate your skills.',
        category: 'project',
        estimatedDays: 30,
        route: '/portfolio',
      ));
    }

    // Interview prep
    if (interview < 0.5) {
      milestones.add(const RoadmapMilestone(
        id: '90_interview_prep',
        title: 'Practice Mock Interviews',
        description: 'Complete at least 5 mock interview sessions.',
        category: 'interview',
        estimatedDays: 14,
        route: '/interview',
      ));
    }

    // Resume and portfolio
    if (resume < 0.7) {
      milestones.add(const RoadmapMilestone(
        id: '90_resume_polish',
        title: 'Polish Resume',
        description: 'Finalize your resume with all projects and skills.',
        category: 'resume',
        estimatedDays: 3,
        route: '/resume',
      ));
    }

    // Networking
    milestones.add(const RoadmapMilestone(
      id: '90_networking',
      title: 'Start Networking',
      description: 'Connect with professionals in your target industry.',
      category: 'networking',
      estimatedDays: 7,
      route: '/career',
    ));

    // Certification
    if (!isReady) {
      milestones.add(const RoadmapMilestone(
        id: '90_certification',
        title: 'Earn a Certification',
        description: 'Obtain an industry-recognized certification.',
        category: 'certification',
        estimatedDays: 30,
      ));
    }

    return CareerRoadmap(
      id: id,
      horizonDays: 90,
      title: 'Skill Building & Certification',
      description: 'Deepen skills, earn certifications, and prepare for interviews.',
      milestones: milestones,
    );
  }

  static CareerRoadmap _plan180(
    String id,
    List<String> gaps,
    bool isReady,
  ) {
    final milestones = <RoadmapMilestone>[];

    milestones.add(const RoadmapMilestone(
      id: '180_advanced_skills',
      title: 'Develop Advanced Skills',
      description: 'Deepen expertise in your primary technologies.',
      category: 'learning',
      estimatedDays: 45,
      route: '/academy',
    ));

    milestones.add(const RoadmapMilestone(
      id: '180_major_project',
      title: 'Complete a Major Project',
      description: 'Build a substantial project for your portfolio.',
      category: 'project',
      estimatedDays: 45,
      route: '/portfolio',
    ));

    milestones.add(const RoadmapMilestone(
      id: '180_network',
      title: 'Build Professional Network',
      description: 'Attend events and connect with industry professionals.',
      category: 'networking',
      estimatedDays: 14,
    ));

    if (isReady) {
      milestones.add(const RoadmapMilestone(
        id: '180_applications',
        title: 'Submit Job Applications',
        description: 'Begin actively applying for target roles.',
        category: 'application',
        estimatedDays: 30,
        route: '/career',
      ));
    }

    return CareerRoadmap(
      id: id,
      horizonDays: 180,
      title: 'Portfolio Strengthening & Networking',
      description: 'Build advanced projects, expand your network, and prepare for applications.',
      milestones: milestones,
    );
  }

  static CareerRoadmap _plan365(String id, List<String> gaps, bool isReady) {
    final milestones = <RoadmapMilestone>[];

    milestones.add(const RoadmapMilestone(
      id: '365_expertise',
      title: 'Achieve Expert-Level Skills',
      description: 'Reach expert proficiency in your core technology stack.',
      category: 'learning',
      estimatedDays: 90,
      route: '/academy',
    ));

    milestones.add(const RoadmapMilestone(
      id: '365_open_source',
      title: 'Contribute to Open Source',
      description: 'Make meaningful contributions to open source projects.',
      category: 'project',
      estimatedDays: 60,
    ));

    milestones.add(const RoadmapMilestone(
      id: '365_leadership',
      title: 'Develop Leadership Skills',
      description: 'Take on mentoring, speaking, or team lead opportunities.',
      category: 'assessment',
      estimatedDays: 60,
    ));

    if (isReady) {
      milestones.add(const RoadmapMilestone(
        id: '365_career_advancement',
        title: 'Career Advancement',
        description: 'Secure a position or promotion in your target role.',
        category: 'application',
        estimatedDays: 90,
        route: '/career',
      ));
    }

    return CareerRoadmap(
      id: id,
      horizonDays: 365,
      title: 'Expertise & Career Advancement',
      description: 'Achieve mastery, build reputation, and advance your career.',
      milestones: milestones,
    );
  }
}
