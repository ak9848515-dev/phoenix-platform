import '../core/bootstrap.dart';

/// A single search result item from any engine.
class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceEngine,
    required this.route,
    required this.relevance,
    this.subtitle,
    this.icon,
  });

  final String id;
  final String title;
  final String? description;
  final String sourceEngine;
  final String route;
  final double relevance;
  final String? subtitle;
  final String? icon;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'sourceEngine': sourceEngine,
    'route': route,
    'relevance': relevance,
    'subtitle': subtitle,
    'icon': icon,
  };
}

/// A group of search results from the same source engine.
class SearchResultGroup {
  const SearchResultGroup({
    required this.engine,
    required this.label,
    required this.icon,
    required this.results,
  });

  final String engine;
  final String label;
  final String icon;
  final List<SearchResult> results;

  int get count => results.length;
}

/// Global Search Service — aggregates search results from all 11 engines.
///
/// No duplicated search logic. Each engine's existing search/public API
/// is called directly. Results are grouped by source engine.
///
/// Engines searched:
/// - Missions
/// - Academy (learning paths)
/// - Portfolio
/// - Resume
/// - Interview
/// - Opportunities
/// - Timeline
/// - Habits
/// - Memory Graph
/// - Knowledge Graph
/// - Decisions
class GlobalSearchService {
  /// Searches across all engines and returns grouped results.
  List<SearchResultGroup> search(String query) {
    if (query.trim().isEmpty) return [];

    final lower = query.toLowerCase().trim();
    final groups = <SearchResultGroup>[];

    // 1. Missions
    final missionResults = _searchMissions(lower);
    if (missionResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'mission_engine',
        label: 'Missions',
        icon: 'rocket_launch',
        results: missionResults,
      ));
    }

    // 2. Academy
    final academyResults = _searchAcademy(lower);
    if (academyResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'academy',
        label: 'Academy',
        icon: 'school',
        results: academyResults,
      ));
    }

    // 3. Portfolio
    final portfolioResults = _searchPortfolio(lower);
    if (portfolioResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'portfolio',
        label: 'Portfolio',
        icon: 'folder',
        results: portfolioResults,
      ));
    }

    // 4. Resume
    final resumeResults = _searchResume(lower);
    if (resumeResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'resume',
        label: 'Resume',
        icon: 'description',
        results: resumeResults,
      ));
    }

    // 5. Interview
    final interviewResults = _searchInterview(lower);
    if (interviewResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'interview',
        label: 'Interview',
        icon: 'record_voice_over',
        results: interviewResults,
      ));
    }

    // 6. Opportunities
    final opportunityResults = _searchOpportunities(lower);
    if (opportunityResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'opportunity',
        label: 'Opportunities',
        icon: 'work',
        results: opportunityResults,
      ));
    }

    // 7. Timeline
    final timelineResults = _searchTimeline(lower);
    if (timelineResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'timeline',
        label: 'Timeline',
        icon: 'timeline',
        results: timelineResults,
      ));
    }

    // 8. Habits
    final habitResults = _searchHabits(lower);
    if (habitResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'habit',
        label: 'Habits',
        icon: 'checklist',
        results: habitResults,
      ));
    }

    // 9. Memory Graph
    final memoryResults = _searchMemoryGraph(lower);
    if (memoryResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'memory_graph',
        label: 'Memory Graph',
        icon: 'hub',
        results: memoryResults,
      ));
    }

    // 10. Knowledge Graph
    final knowledgeResults = _searchKnowledgeGraph(lower);
    if (knowledgeResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'knowledge',
        label: 'Knowledge',
        icon: 'psychology',
        results: knowledgeResults,
      ));
    }

    // 11. Decisions
    final decisionResults = _searchDecisions(lower);
    if (decisionResults.isNotEmpty) {
      groups.add(SearchResultGroup(
        engine: 'decision',
        label: 'Decisions',
        icon: 'account_tree',
        results: decisionResults,
      ));
    }

    return groups;
  }

  // ── Engine-specific search methods ─────────────────────────────────

  List<SearchResult> _searchMissions(String query) {
    final results = <SearchResult>[];
    final state = AppBootstrap.maybeUserStateService?.currentState;
    if (state == null) return results;

    for (final mission in state.missions) {
      if (_matches(mission.title, query) ||
          _matches(mission.description, query)) {
        results.add(SearchResult(
          id: 'mission-${mission.id}',
          title: mission.title,
          description: mission.description,
          sourceEngine: 'mission_engine',
          route: '/',
          relevance: _score(mission.title, mission.description, query),
          subtitle: mission.status.name,
          icon: 'rocket_launch',
        ));
      }
    }
    return results..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<SearchResult> _searchAcademy(String query) {
    final results = <SearchResult>[];
    final academyService = AppBootstrap.maybeAcademyService;
    if (academyService == null) return results;

    for (final path in academyService.allPaths) {
      if (_matches(path.title, query) ||
          _matches(path.description, query)) {
        results.add(SearchResult(
          id: 'academy-${path.id}',
          title: path.title,
          description: path.description,
          sourceEngine: 'academy',
          route: '/academy',
          relevance: _score(path.title, path.description, query),
          subtitle: '${path.modules.length} modules',
          icon: 'school',
        ));
      }
    }
    return results..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<SearchResult> _searchPortfolio(String query) {
    final results = <SearchResult>[];
    final state = AppBootstrap.maybeUserStateService?.currentState;
    if (state?.portfolio == null) return results;

    final portfolio = state!.portfolio!;
    if (_matches(portfolio.careerReadiness, query)) {
      results.add(SearchResult(
        id: 'portfolio-main',
        title: 'Portfolio — ${portfolio.careerReadiness}',
        description: '${portfolio.projectCount} projects, ${portfolio.skills.length} skills',
        sourceEngine: 'portfolio',
        route: '/portfolio',
        relevance: 0.5,
        icon: 'folder',
      ));
    }
    return results;
  }

  List<SearchResult> _searchResume(String query) {
    final results = <SearchResult>[];
    final state = AppBootstrap.maybeUserStateService?.currentState;
    if (state?.resume == null) return results;

    final resume = state!.resume!;
    if (_matches(resume.professionalSummary, query)) {
      results.add(SearchResult(
        id: 'resume-main',
        title: 'Resume — ${resume.resumeType.label}',
        description: resume.professionalSummary,
        sourceEngine: 'resume',
        route: '/resume',
        relevance: 0.5,
        icon: 'description',
      ));
    }
    return results;
  }

  List<SearchResult> _searchInterview(String query) {
    final results = <SearchResult>[];
    final state = AppBootstrap.maybeUserStateService?.currentState;
    if (state?.interviewProfile == null) return results;

    final profile = state!.interviewProfile!;
    for (final topic in profile.recommendedTopics) {
      if (_matches(topic, query)) {
        results.add(SearchResult(
          id: 'interview-topic-$topic',
          title: topic,
          description: 'Interview preparation topic',
          sourceEngine: 'interview',
          route: '/interview',
          relevance: 0.6,
          icon: 'record_voice_over',
        ));
      }
    }
    return results;
  }

  List<SearchResult> _searchOpportunities(String query) {
    final results = <SearchResult>[];
    final state = AppBootstrap.maybeUserStateService?.currentState;
    if (state == null) return results;

    for (final opp in state.opportunities) {
      if (_matches(opp.title, query) ||
          _matches(opp.description, query)) {
        results.add(SearchResult(
          id: 'opportunity-${opp.id}',
          title: opp.title,
          description: opp.description,
          sourceEngine: 'opportunity',
          route: '/opportunity',
          relevance: _score(opp.title, opp.description, query),
          subtitle: opp.type.name,
          icon: 'work',
        ));
      }
    }
    return results..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<SearchResult> _searchTimeline(String query) {
    final results = <SearchResult>[];
    final timelineService = AppBootstrap.maybeTimelineService;
    if (timelineService == null) return results;

    final events = timelineService.search(query);
    for (final event in events) {
      results.add(SearchResult(
        id: 'timeline-${event.id}',
        title: event.title,
        description: event.description,
        sourceEngine: 'timeline',
        route: '/timeline',
        relevance: event.importance.toDouble(),
        subtitle: event.category.label,
        icon: 'timeline',
      ));
    }
    return results..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<SearchResult> _searchHabits(String query) {
    final results = <SearchResult>[];
    final habitService = AppBootstrap.maybeHabitService;
    if (habitService == null) return results;

    for (final habit in habitService.allHabits) {
      if (_matches(habit.title, query) ||
          _matches(habit.description ?? '', query)) {
        results.add(SearchResult(
          id: 'habit-${habit.id}',
          title: habit.title,
          description: habit.description ?? '',
          sourceEngine: 'habit',
          route: '/habits/detail',
          relevance: _score(habit.title, habit.description ?? '', query),
          subtitle: habit.type.label,
          icon: 'checklist',
        ));
      }
    }
    return results..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<SearchResult> _searchMemoryGraph(String query) {
    final results = <SearchResult>[];
    final memoryService = AppBootstrap.maybeMemoryGraphService;
    if (memoryService == null) return results;

    final entities = memoryService.search(query);
    for (final entity in entities) {
      results.add(SearchResult(
        id: 'memory-${entity.id}',
        title: entity.title,
        description: entity.description ?? '',
        sourceEngine: 'memory_graph',
        route: '/memory-graph/entity',
        relevance: entity.importance,
        subtitle: entity.type.name,
        icon: 'hub',
      ));
    }
    return results..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<SearchResult> _searchKnowledgeGraph(String query) {
    final results = <SearchResult>[];
    final knowledgeService = AppBootstrap.maybeKnowledgeService;
    if (knowledgeService == null) return results;

    final nodes = knowledgeService.search(query);
    for (final node in nodes) {
      results.add(SearchResult(
        id: 'knowledge-${node.id}',
        title: node.label,
        description: node.description ?? '',
        sourceEngine: 'knowledge',
        route: '/knowledge',
        relevance: node.importance,
        subtitle: node.domain.name,
        icon: 'psychology',
      ));
    }
    return results..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  List<SearchResult> _searchDecisions(String query) {
    final results = <SearchResult>[];
    final state = AppBootstrap.maybeUserStateService?.currentState;
    if (state == null) return results;

    for (final decision in state.decisionHistory) {
      if (_matches(decision.title, query)) {
        results.add(SearchResult(
          id: 'decision-${decision.id}',
          title: decision.title,
          description: '${decision.options.length} options analyzed',
          sourceEngine: 'decision',
          route: '/decision',
          relevance: decision.confidence,
          subtitle: decision.decisionType.label,
          icon: 'account_tree',
        ));
      }
    }
    return results..sort((a, b) => b.relevance.compareTo(a.relevance));
  }

  // ── Helpers ───────────────────────────────────────────────────────

  bool _matches(String? text, String query) {
    if (text == null || text.isEmpty) return false;
    return text.toLowerCase().contains(query);
  }

  double _score(String? title, String? description, String query) {
    double score = 0.0;
    if (title != null) {
      final lower = title.toLowerCase();
      if (lower.startsWith(query)) score += 1.0;
      if (lower.contains(query)) score += 0.5;
    }
    if (description != null) {
      if (description.toLowerCase().contains(query)) score += 0.3;
    }
    return score;
  }
}