import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../shared/infrastructure/performance/debounce_notifier.dart';
import '../../career/engine/career_engine.dart';
import '../../daily_brief/engine/daily_brief_engine.dart';
import '../../decision_intelligence/engine/decision_engine.dart';
import '../../growth_intelligence/engine/growth_intelligence_engine.dart';
import '../../identity/engine/identity_engine.dart';
import '../../interview/intelligence/engine/interview_intelligence_engine.dart';
import '../../opportunity/intelligence/engine/opportunity_intelligence_engine.dart';
import '../../opportunity/intelligence/models/opportunity_application_status.dart';
import '../../memory_engine/engine/memory_engine.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../../progress_engine/achievement_engine.dart';
import '../../recommendation_engine/engine/recommendation_engine.dart';
import '../models/notification_action.dart';
import '../models/notification_category.dart';
import '../models/notification_item.dart';
import '../models/notification_priority.dart';

/// Notification Engine — derives notifications from existing engine snapshots.
///
/// **Architecture:**
/// ```text
/// IdentityEngine + CareerEngine + MissionEngine + AchievementEngine + ...
///   ↓
/// NotificationEngine (derives notifications from snapshots)
///   ↓
/// NotificationItem list → NotificationCenterScreen
///   ↓
/// AppBar badge count
/// ```
///
/// **Rules:**
/// - No new business logic — derives existing engine data
/// - No AI calls
/// - Notifications are derived, not stored (persistence via SharedPreferences for read state)
class NotificationEngine extends ChangeNotifier
    with DebounceChangeNotifier {
  NotificationEngine({
    required this._identityEngine,
    required this._careerEngine,
    required this._missionEngine,
    required this._achievementEngine,
    required this._portfolioEngine,
    required this._decisionEngine,
    required this._recommendationEngine,
    required this._dailyBriefEngine,
    this._memoryEngine,
    this._growthEngine,
    this._interviewEngine,
    this._opportunityEngine,
  });

  // Engines used for notification derivation.
  // Some engines are kept for future notification types even if not
  // currently read — they are subscribed to engine change listeners.
  // ignore: unused_field
  final IdentityEngine _identityEngine;
  final CareerEngine _careerEngine;
  final MissionIntelligenceEngine _missionEngine;
  final AchievementEngine _achievementEngine;
  final PortfolioEngine _portfolioEngine;
  final DecisionEngine _decisionEngine;
  // ignore: unused_field
  final RecommendationEngine _recommendationEngine;
  final DailyBriefEngine _dailyBriefEngine;
  // ignore: unused_field
  final MemoryEngine? _memoryEngine;
  final GrowthIntelligenceEngine? _growthEngine;
  final InterviewIntelligenceEngine? _interviewEngine;
  final OpportunityIntelligenceEngine? _opportunityEngine;

  final PhoenixLogger _logger = PhoenixLogger.shared;

  static const String _storageKey = 'phx_notification_read_ids';

  bool _isInitialized = false;
  List<NotificationItem> _notifications = [];
  Set<String> _readIds = {};

  // ── Accessors ─────────────────────────────────────────────────────

  /// All derived notifications, sorted by priority then time.
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Unread notifications.
  List<NotificationItem> get unread =>
      _notifications.where((n) => !n.isRead).toList();

  /// Count of unread notifications (for badge display).
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  /// Whether there are any notifications.
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Whether there are any unread notifications.
  bool get hasUnread => unreadCount > 0;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine and derives initial notifications.
  Future<void> init() async {
    await _loadReadState();
    _deriveAll();
    _isInitialized = true;
    setDebounceMs(100); // 100ms debounce for 12-engine cascade
    _logger.info('NotificationEngine initialized',
        category: LogCategory.engine, source: 'NotificationEngine');
    notifyImmediately();
  }

  /// Refreshes all notifications from current engine snapshots.
  Future<void> refresh() async {
    _deriveAll();
    _logger.info('NotificationEngine refreshed',
        category: LogCategory.engine, source: 'NotificationEngine');
    notifyImmediately();
  }

  // ── Read State ────────────────────────────────────────────────────

  /// Marks a notification as read and persists the state.
  void markRead(String id) {
    _readIds.add(id);
    _persistReadState();
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].markRead();
      notifyImmediately();
    }
  }

  /// Marks all notifications as read.
  void markAllRead() {
    for (final n in _notifications) {
      _readIds.add(n.id);
    }
    _persistReadState();
    _notifications = _notifications.map((n) => n.markRead()).toList();
    notifyImmediately();
  }

  /// Removes a notification (dismiss).
  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _readIds.add(id);
    _persistReadState();
    notifyImmediately();
  }

  /// Clears all dismissed/read state and re-derives.
  Future<void> reset() async {
    _readIds.clear();
    await _persistReadState();
    _deriveAll();
    notifyImmediately();
  }

  // ── Derivation ────────────────────────────────────────────────────

  void _deriveAll() {
    final all = <NotificationItem>[];
    final now = DateTime.now();

    all.addAll(_deriveMissionNotifications(now));
    all.addAll(_deriveCareerNotifications(now));
    all.addAll(_deriveAchievementNotifications(now));
    all.addAll(_deriveDecisionNotifications(now));
    all.addAll(_deriveDailyBriefNotifications(now));
    all.addAll(_derivePortfolioNotifications(now));
    all.addAll(_deriveGrowthNotifications(now));
    all.addAll(_deriveInterviewNotifications(now));
    all.addAll(_deriveOpportunityNotifications(now));
    all.addAll(_deriveOrchestratorNotifications(now));

    // Sort: unread first, then by priority (desc), then by timestamp (desc)
    all.sort((a, b) {
      if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
      final priority = b.priority.weight.compareTo(a.priority.weight);
      if (priority != 0) return priority;
      return b.timestamp.compareTo(a.timestamp);
    });

    // Apply read state
    _notifications = all.map((n) {
      if (_readIds.contains(n.id)) return n.markRead();
      return n;
    }).toList();
  }

  // ── Mission Notifications ─────────────────────────────────────────

  List<NotificationItem> _deriveMissionNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _missionEngine.snapshot;
    if (snap == null) return items;

    if (snap.hasActiveRecommendation && snap.currentMission != null) {
      final mission = snap.currentMission!;
      items.add(NotificationItem(
        id: 'mission-active-${mission.title.hashCode}',
        title: 'Mission: ${mission.title}',
        description: mission.description.isNotEmpty
            ? mission.description
            : 'Your active mission is ready. Continue your growth journey.',
        timestamp: now,
        priority: NotificationPriority.high,
        category: NotificationCategory.mission,
        action: const NotificationAction(
          route: '/',
          label: 'View Missions',
        ),
        sourceEngine: 'MissionIntelligenceEngine',
      ));
    }

    if (snap.hasAlternatives && snap.alternatives.isNotEmpty) {
      items.add(NotificationItem(
        id: 'mission-alternatives-${snap.alternatives.length}',
        title: '${snap.alternatives.length} alternative mission${snap.alternatives.length > 1 ? 's' : ''} available',
        description: 'Explore different missions that match your growth goals.',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.mission,
        action: const NotificationAction(
          route: '/recommendation',
          label: 'Explore',
        ),
        sourceEngine: 'MissionIntelligenceEngine',
      ));
    }

    return items;
  }

  // ── Career Notifications ──────────────────────────────────────────

  List<NotificationItem> _deriveCareerNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _careerEngine.snapshot;
    if (snap == null || !snap.hasData) return items;

    if (snap.needsAttention) {
      items.add(NotificationItem(
        id: 'career-attention',
        title: 'Career readiness needs attention',
        description:
            'Your career score is ${(snap.careerScore * 100).round()}%. '
            'Focus on closing skill gaps.',
        timestamp: now,
        priority: NotificationPriority.high,
        category: NotificationCategory.career,
        action: const NotificationAction(
          route: '/career',
          label: 'View Career',
        ),
        sourceEngine: 'CareerEngine',
      ));
    }

    if (snap.interviewReadiness < 0.3) {
      items.add(NotificationItem(
        id: 'interview-practice',
        title: 'Interview readiness is low',
        description: 'Practice interviews to improve your confidence '
            'and readiness score.',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.interview,
        action: const NotificationAction(
          route: '/interview',
          label: 'Practice',
        ),
        sourceEngine: 'CareerEngine',
      ));
    }

    if (snap.skillGaps.length >= 3) {
      items.add(NotificationItem(
        id: 'skill-gaps',
        title: '${snap.skillGaps.length} skill gaps identified',
        description:
            'Top gaps: ${snap.skillGaps.take(2).join(", ")}. '
            'Address these through targeted learning.',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.learning,
        action: const NotificationAction(
          route: '/academy',
          label: 'Start Learning',
        ),
        sourceEngine: 'CareerEngine',
      ));
    }

    return items;
  }

  // ── Achievement Notifications ─────────────────────────────────────

  List<NotificationItem> _deriveAchievementNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _achievementEngine.snapshot;
    if (snap == null || !snap.hasAchievements) return items;

    if (snap.recentAchievements.isNotEmpty) {
      final recent = snap.recentAchievements.first;
      items.add(NotificationItem(
        id: 'achievement-${recent.id}',
        title: 'New ${recent.type}: ${recent.title}',
        description: recent.description ?? 'You earned a new achievement!',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.achievement,
        action: const NotificationAction(
          route: '/progress',
          label: 'View Achievements',
        ),
        sourceEngine: 'AchievementEngine',
      ));
    }

    if (snap.totalAchievements >= 10 && snap.totalAchievements % 10 == 0) {
      items.add(NotificationItem(
        id: 'achievement-milestone-${snap.totalAchievements}',
        title: 'Achievement milestone: ${snap.totalAchievements} earned!',
        description:
            'Your dedication is paying off. Keep completing missions!',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.achievement,
        action: const NotificationAction(
          route: '/progress',
          label: 'View All',
        ),
        sourceEngine: 'AchievementEngine',
      ));
    }

    return items;
  }

  // ── Decision Notifications ────────────────────────────────────────

  List<NotificationItem> _deriveDecisionNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _decisionEngine.snapshot;
    if (snap == null) return items;

    final top = snap.top;
    if (top != null) {
      items.add(NotificationItem(
        id: 'decision-top',
        title: top.title,
        description: top.description,
        timestamp: now,
        priority: NotificationPriority.urgent,
        category: NotificationCategory.decision,
        action: const NotificationAction(
          route: '/dashboard',
          label: 'View',
        ),
        sourceEngine: 'DecisionEngine',
      ));
    }

    return items;
  }

  // ── Daily Brief Notifications ────────────────────────────────────

  List<NotificationItem> _deriveDailyBriefNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _dailyBriefEngine.snapshot;
    if (snap == null || !snap.hasBrief) return items;

    items.add(NotificationItem(
      id: 'daily-brief-${now.day}${now.month}${now.year}',
      title: 'Daily Brief available',
      description: snap.todaysFocus.isNotEmpty
          ? snap.todaysFocus
          : 'Your personalized daily action plan is ready.',
      timestamp: now,
      priority: NotificationPriority.high,
      category: NotificationCategory.dailyBrief,
      action: const NotificationAction(
        route: '/daily-journey',
        label: 'View Brief',
      ),
      sourceEngine: 'DailyBriefEngine',
    ));

    return items;
  }

  // ── Portfolio Notifications ──────────────────────────────────────

  List<NotificationItem> _derivePortfolioNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _portfolioEngine.snapshot;
    if (snap == null || !snap.hasData) return items;

    if (snap.portfolioScore < 0.4) {
      items.add(NotificationItem(
        id: 'portfolio-attention',
        title: 'Portfolio needs improvement',
        description:
            'Your portfolio score is ${(snap.portfolioScore * 100).round()}%. '
            'Strengthen it with more projects.',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.portfolio,
        action: const NotificationAction(
          route: '/portfolio',
          label: 'View Portfolio',
        ),
        sourceEngine: 'PortfolioEngine',
      ));
    }

    return items;
  }

  // ── Interview Notifications ──────────────────────────────────────

  List<NotificationItem> _deriveInterviewNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _interviewEngine?.snapshot;
    if (snap == null || !snap.hasData) return items;

    // Readiness feedback
    if (snap.readiness.needsSignificantPrep) {
      items.add(NotificationItem(
        id: 'interview-readiness-low',
        title: 'Interview readiness needs significant preparation',
        description:
            'Your overall readiness is ${(snap.readiness.overall * 100).round()}%. '
            'Start practice sessions to improve.',
        timestamp: now,
        priority: NotificationPriority.high,
        category: NotificationCategory.interview,
        action: const NotificationAction(
          route: '/interview',
          label: 'Start Practice',
        ),
        sourceEngine: 'InterviewIntelligenceEngine',
      ));
    }

    // Weak topic detected
    if (snap.hasWeakTopics && snap.weakTopics.isNotEmpty) {
      final top = snap.weakTopics.first;
      items.add(NotificationItem(
        id: 'interview-weak-${top.subject.hashCode}',
        title: 'Weak topic detected: ${top.subject}',
        description: 'Your accuracy in ${top.subject} is '
            '${(top.accuracyRate * 100).round()}%. '
            'Review fundamentals and practice.',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.interview,
        action: const NotificationAction(
          route: '/interview',
          label: 'Study Topic',
        ),
        sourceEngine: 'InterviewIntelligenceEngine',
      ));
    }

    // Recent session feedback available
    if (snap.latestFeedback != null && snap.recentSessions.isNotEmpty) {
      final lastSession = snap.recentSessions.first;
      if (lastSession.isCompleted) {
        items.add(NotificationItem(
          id: 'interview-feedback-${lastSession.id}',
          title: 'Interview session feedback available',
          description: snap.latestFeedback!.summary.isNotEmpty
              ? snap.latestFeedback!.summary
              : 'Your latest mock interview is ready for review.',
          timestamp: now,
          priority: NotificationPriority.normal,
          category: NotificationCategory.interview,
          action: const NotificationAction(
            route: '/interview',
            label: 'View Feedback',
          ),
          sourceEngine: 'InterviewIntelligenceEngine',
        ));
      }
    }

    // Confidence improved
    if (snap.progress.isImproving && snap.progress.lastPracticedAt != null) {
      items.add(NotificationItem(
        id: 'interview-confidence-up',
        title: 'Interview confidence is growing',
        description:
            'Your average score is ${(snap.progress.averageScore * 100).round()}% '
            'with an improvement rate of '
            '${(snap.progress.improvementRate * 100).round()}%. Keep it up!',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.interview,
        action: const NotificationAction(
          route: '/interview',
          label: 'View Progress',
        ),
        sourceEngine: 'InterviewIntelligenceEngine',
      ));
    }

    // Ready for real interviews
    if (snap.isReadyForInterviews) {
      items.add(NotificationItem(
        id: 'interview-ready',
        title: 'You are interview-ready!',
        description:
            'Your readiness score is ${(snap.readiness.overall * 100).round()}%. '
            'You are prepared for real interviews.',
        timestamp: now,
        priority: NotificationPriority.high,
        category: NotificationCategory.interview,
        action: const NotificationAction(
          route: '/career',
          label: 'Apply Now',
        ),
        sourceEngine: 'InterviewIntelligenceEngine',
      ));
    }

    // Practice reminder (if last practice was > 7 days ago)
    if (snap.progress.lastPracticedAt != null) {
      final daysSince =
          now.difference(snap.progress.lastPracticedAt!).inDays;
      if (daysSince >= 7) {
        items.add(NotificationItem(
          id: 'interview-practice-reminder',
          title: 'Time for interview practice',
          description: 'It has been $daysSince days since your last practice '
              'session. Regular practice keeps you sharp.',
          timestamp: now,
          priority: NotificationPriority.normal,
          category: NotificationCategory.interview,
          action: const NotificationAction(
            route: '/interview',
            label: 'Practice Now',
          ),
          sourceEngine: 'InterviewIntelligenceEngine',
        ));
      }
    }

    return items;
  }

  // ── Opportunity Notifications ────────────────────────────────────

  List<NotificationItem> _deriveOpportunityNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _opportunityEngine?.snapshot;
    if (snap == null || !snap.hasData) return items;

    // High match found
    if (snap.topOpportunity != null && snap.bestMatchScore >= 0.7) {
      items.add(NotificationItem(
        id: 'opportunity-high-match',
        title: 'High match opportunity: ${snap.topOpportunity!.title}',
        description:
            'Your match score is ${(snap.bestMatchScore * 100).round()}%. '
            'You are well-positioned for this role.',
        timestamp: now,
        priority: NotificationPriority.high,
        category: NotificationCategory.career,
        action: const NotificationAction(
          route: '/opportunity',
          label: 'View Opportunity',
        ),
        sourceEngine: 'OpportunityIntelligenceEngine',
      ));
    }

    // Application reminder
    if (snap.applications.any((a) => a.isActive)) {
      final active = snap.applications.firstWhere((a) => a.isActive);
      items.add(NotificationItem(
        id: 'opportunity-application-${active.id}',
        title: 'Application active: ${active.opportunityTitle}',
        description: 'Your application is in progress. Follow up if needed.',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.career,
        action: const NotificationAction(
          route: '/opportunity',
          label: 'View Application',
        ),
        sourceEngine: 'OpportunityIntelligenceEngine',
      ));
    }

    // Interview invitation
    if (snap.applications.any((a) => a.status == ApplicationStatus.interviewScheduled)) {
      final interview = snap.applications.firstWhere(
          (a) => a.status == ApplicationStatus.interviewScheduled);
      items.add(NotificationItem(
        id: 'opportunity-interview-${interview.id}',
        title: 'Interview scheduled: ${interview.opportunityTitle}',
        description: 'Prepare for your interview at ${interview.companyName}.',
        timestamp: now,
        priority: NotificationPriority.high,
        category: NotificationCategory.interview,
        action: const NotificationAction(
          route: '/interview',
          label: 'Prepare',
        ),
        sourceEngine: 'OpportunityIntelligenceEngine',
      ));
    }

    // Application status changed / offer received
    if (snap.applications.any((a) => a.hasOffer)) {
      final offer = snap.applications.firstWhere((a) => a.hasOffer);
      items.add(NotificationItem(
        id: 'opportunity-offer-${offer.id}',
        title: 'Offer received: ${offer.opportunityTitle}',
        description: 'Congratulations! You received an offer from ${offer.companyName}.',
        timestamp: now,
        priority: NotificationPriority.high,
        category: NotificationCategory.career,
        action: const NotificationAction(
          route: '/opportunity',
          label: 'View Offer',
        ),
        sourceEngine: 'OpportunityIntelligenceEngine',
      ));
    }

    return items;
  }

  // ── Growth Notifications ─────────────────────────────────────────

  List<NotificationItem> _deriveGrowthNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final snap = _growthEngine?.snapshot;
    if (snap == null || !snap.hasData) return items;

    if (snap.milestones.isNotEmpty) {
      final next = snap.milestones.first;
      items.add(NotificationItem(
        id: 'growth-milestone-${next.title.hashCode}',
        title: 'Growth Milestone: ${next.title}',
        description: next.description.isNotEmpty
            ? next.description
            : 'You\'re on track to reach this milestone in '
                '${next.daysRemaining ?? "?"} days.',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.growthForecast,
        action: const NotificationAction(
          route: '/progress',
          label: 'View Forecast',
        ),
        sourceEngine: 'GrowthIntelligenceEngine',
      ));
    }

    return items;
  }

  // ── Orchestrator Notifications ─────────────────────────────────

  List<NotificationItem> _deriveOrchestratorNotifications(DateTime now) {
    final items = <NotificationItem>[];
    final orchestrator = AppBootstrap.maybeDecisionIntelligenceOrchestrator;
    final snap = orchestrator?.snapshot;
    if (snap == null || !snap.hasData) return items;

    final top = snap.topPriority;
    items.add(NotificationItem(
      id: 'orchestrator-top-${top.id}',
      title: top.title,
      description: top.reasoning.isNotEmpty
          ? top.reasoning
          : top.description,
      timestamp: now,
      priority: NotificationPriority.high,
      category: NotificationCategory.decision,
      action: NotificationAction(
        route: top.route.isNotEmpty ? top.route : '/dashboard',
        label: 'View',
      ),
      sourceEngine: 'DecisionIntelligenceOrchestrator',
    ));

    if (snap.hasQuickWins) {
      items.add(NotificationItem(
        id: 'orchestrator-quickwins-${snap.quickWins.length}',
        title: '${snap.quickWins.length} quick win${snap.quickWins.length > 1 ? 's' : ''} available',
        description: 'High-ROI, low-effort actions you can complete today.',
        timestamp: now,
        priority: NotificationPriority.normal,
        category: NotificationCategory.learning,
        action: const NotificationAction(
          route: '/dashboard',
          label: 'View Quick Wins',
        ),
        sourceEngine: 'DecisionIntelligenceOrchestrator',
      ));
    }

    return items;
  }

  // ── Persistence ──────────────────────────────────────────────────

  Future<void> _loadReadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey);
      if (raw != null) {
        _readIds = raw.toSet();
      }
    } catch (e) {
      _logger.warning('NotificationEngine: failed to load read state: $e',
          category: LogCategory.engine, source: 'NotificationEngine');
    }
  }

  Future<void> _persistReadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _readIds.toList());
    } catch (e) {
      _logger.warning('NotificationEngine: failed to persist read state: $e',
          category: LogCategory.engine, source: 'NotificationEngine');
    }
  }

  // DebounceChangeNotifier.dispose() handles timer cleanup — no override needed
}
