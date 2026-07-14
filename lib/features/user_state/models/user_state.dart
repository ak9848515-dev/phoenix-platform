import 'dart:convert';

import '../../academy/models/learning_progress.dart';
import '../../decision/models/decision_analysis.dart';
import '../../identity/models/identity.dart';
import '../../journey/models/journey.dart';
import '../../journey/models/journey_stage.dart';
import '../../knowledge_dna/models/knowledge_dna.dart';
import '../../mission_engine/mission_engine.dart' as mission_engine;
import '../../portfolio/models/portfolio.dart';
import '../../resume/models/resume.dart';
import '../../career/models/career_profile.dart';
import '../../interview/models/interview_profile.dart';
import '../../opportunity/models/opportunity.dart';
import '../../habit/models/habit.dart';
import '../../habit/models/habit_entry.dart';
import '../../../models/user_settings.dart';
import '../../../models/achievement.dart';

/// Schema version for state serialization.
/// Increment when making breaking changes to the state structure.
const int userStateVersion = 1;

/// Unified, immutable representation of the user's entire state across
/// all Phoenix OS modules.
///
/// [UserState] is the single source of truth. No module should maintain
/// duplicate copies of the data contained here.
///
/// All fields are read-only. Use [copyWith] to produce modified copies.
/// Use [toMap] / [fromMap] for serialization.
class UserState {
  const UserState({
    this.version = userStateVersion,
    this.identity,
    this.journey,
    this.currentJourneyStage,
    this.missions = const [],
    this.knowledgeDNA,
    this.portfolio,
    this.resume,
    this.careerProfile,
    this.interviewProfile,
    this.opportunities = const [],
    this.settings = const UserSettings(),
    this.achievements = const [],
    this.learningProgress = const [],
    this.habits = const [],
    this.habitEntries = const [],
    this.decisionHistory = const [],
    this.memoryGraphData,
    this.knowledgeSnapshot,
    this.aiContext,
    this.lastActivityAt,
    this.currentFocus,
    this.totalXp = 0,
    this.level = 1,
  });

  /// Schema version for migration support.
  final int version;

  // ── Core Identity & Journey ───────────────────────────────────────

  /// The user's selected identity.
  final Identity? identity;

  /// The user's full journey.
  final Journey? journey;

  /// The current in-progress journey stage.
  final JourneyStage? currentJourneyStage;

  // ── Missions ──────────────────────────────────────────────────────

  /// All missions (active + completed).
  final List<mission_engine.Mission> missions;

  // ── Knowledge DNA ─────────────────────────────────────────────────

  /// The user's Knowledge DNA profile.
  final KnowledgeDNA? knowledgeDNA;

  // ── Portfolio ─────────────────────────────────────────────────────

  /// The user's Living Portfolio.
  final Portfolio? portfolio;

  // ── Resume ────────────────────────────────────────────────────────

  /// The user's Living Resume.
  final Resume? resume;

  // ── Career ────────────────────────────────────────────────────────

  /// The user's career readiness profile.
  final CareerProfile? careerProfile;

  // ── Interview ─────────────────────────────────────────────────────

  /// The user's interview readiness profile.
  final InterviewProfile? interviewProfile;

  // ── Opportunities ─────────────────────────────────────────────────

  /// Recommended opportunities.
  final List<Opportunity> opportunities;

  // ── Preferences & Settings ────────────────────────────────────────

  /// User preferences and settings.
  final UserSettings settings;

  // ── Achievements ──────────────────────────────────────────────────

  /// Earned achievements.
  final List<Achievement> achievements;

  // ── Academy Learning Progress ─────────────────────────────────────

  /// Learning progress across all Academy paths.
  final List<LearningProgress> learningProgress;

  // ── Habit Intelligence Data ────────────────────────────────────────

  /// All tracked habits.
  final List<Habit> habits;

  /// Daily habit entries.
  final List<HabitEntry> habitEntries;

  // ── Decision Intelligence History ─────────────────────────────────

  /// Past decision analyses with outcomes.
  final List<DecisionAnalysis> decisionHistory;

  // ── Memory Graph Data ─────────────────────────────────────────────

  /// Serialized memory graph data (entities + relations).
  final Map<String, dynamic>? memoryGraphData;

  // ── Personal Knowledge Graph Data ─────────────────────────────────

  /// Serialized knowledge snapshot (nodes + edges + context).
  final Map<String, dynamic>? knowledgeSnapshot;

  // ── AI Context ────────────────────────────────────────────────────

  /// AI context string for the Phoenix AI experience.
  /// Stores conversation context, user preferences for AI interactions,
  /// and any state the AI needs to maintain across sessions.
  final String? aiContext;

  // ── Timestamps & Metadata ─────────────────────────────────────────

  /// When the user last performed an action.
  final DateTime? lastActivityAt;

  /// The user's current focus/goal description.
  final String? currentFocus;

  /// Total XP earned across all activities.
  final int totalXp;

  /// Current level.
  final int level;

  // ── Computed Properties ───────────────────────────────────────────

  /// Whether the user has completed onboarding.
  bool get onboardingComplete => settings.onboardingComplete;

  /// Whether the user has selected an identity.
  bool get hasIdentity => identity != null;

  /// Returns a copy with the given fields replaced.
  UserState copyWith({
    int? version,
    Identity? identity,
    Journey? journey,
    JourneyStage? currentJourneyStage,
    List<mission_engine.Mission>? missions,
    KnowledgeDNA? knowledgeDNA,
    Portfolio? portfolio,
    Resume? resume,
    CareerProfile? careerProfile,
    InterviewProfile? interviewProfile,
    List<Opportunity>? opportunities,
    UserSettings? settings,
    List<Achievement>? achievements,
    List<LearningProgress>? learningProgress,
    List<Habit>? habits,
    List<HabitEntry>? habitEntries,
    List<DecisionAnalysis>? decisionHistory,
    Map<String, dynamic>? memoryGraphData,
    Map<String, dynamic>? knowledgeSnapshot,
    String? aiContext,
    DateTime? lastActivityAt,
    String? currentFocus,
    int? totalXp,
    int? level,
    bool clearIdentity = false,
    bool clearJourney = false,
    bool clearKnowledgeDNA = false,
    bool clearPortfolio = false,
    bool clearResume = false,
    bool clearCareerProfile = false,
    bool clearInterviewProfile = false,
    bool clearAiContext = false,
  }) {
    return UserState(
      version: version ?? this.version,
      identity: clearIdentity ? null : (identity ?? this.identity),
      journey: clearJourney ? null : (journey ?? this.journey),
      currentJourneyStage: currentJourneyStage ?? this.currentJourneyStage,
      missions: missions ?? this.missions,
      knowledgeDNA:
          clearKnowledgeDNA ? null : (knowledgeDNA ?? this.knowledgeDNA),
      portfolio: clearPortfolio ? null : (portfolio ?? this.portfolio),
      resume: clearResume ? null : (resume ?? this.resume),
      careerProfile:
          clearCareerProfile ? null : (careerProfile ?? this.careerProfile),
      interviewProfile: clearInterviewProfile
          ? null
          : (interviewProfile ?? this.interviewProfile),
      opportunities: opportunities ?? this.opportunities,
      settings: settings ?? this.settings,
      achievements: achievements ?? this.achievements,
      learningProgress: learningProgress ?? this.learningProgress,
      habits: habits ?? this.habits,
      habitEntries: habitEntries ?? this.habitEntries,
      decisionHistory: decisionHistory ?? this.decisionHistory,
      memoryGraphData: memoryGraphData ?? this.memoryGraphData,
      knowledgeSnapshot: knowledgeSnapshot ?? this.knowledgeSnapshot,
      aiContext: clearAiContext ? null : (aiContext ?? this.aiContext),
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      currentFocus: currentFocus ?? this.currentFocus,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
    );
  }

  // ── Serialization ─────────────────────────────────────────────────

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'version': version,
      'identity': identity?.toMap(),
      'journey': journey?.toMap(),
      'currentJourneyStage': currentJourneyStage?.toMap(),
      'missions': missions.map((m) => m.toMap()).toList(),
      'knowledgeDNA': knowledgeDNA?.toMap(),
      'portfolio': portfolio?.toMap(),
      'resume': resume?.toMap(),
      'careerProfile': careerProfile?.toMap(),
      'interviewProfile': interviewProfile?.toMap(),
      'opportunities': opportunities.map((o) => o.toMap()).toList(),
      'settings': settings.toMap(),
      'achievements': achievements.map((a) => a.toMap()).toList(),
      'learningProgress': learningProgress.map((lp) => lp.toMap()).toList(),
      'habits': habits.map((h) => h.toMap()).toList(),
      'habitEntries': habitEntries.map((e) => e.toMap()).toList(),
      'decisionHistory': decisionHistory.map((da) => da.toMap()).toList(),
      'memoryGraphData': memoryGraphData,
      'knowledgeSnapshot': knowledgeSnapshot,
      'aiContext': aiContext,
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'currentFocus': currentFocus,
      'totalXp': totalXp,
      'level': level,
    };
  }

  /// Creates from a JSON-compatible map.
  factory UserState.fromMap(Map<String, dynamic> map) {
    return UserState(
      version: map['version'] as int? ?? userStateVersion,
      identity: map['identity'] != null
          ? Identity.fromMap(Map<String, dynamic>.from(map['identity'] as Map))
          : null,
      journey: map['journey'] != null
          ? Journey.fromMap(Map<String, dynamic>.from(map['journey'] as Map))
          : null,
      currentJourneyStage: map['currentJourneyStage'] != null
          ? JourneyStage.fromMap(
              Map<String, dynamic>.from(map['currentJourneyStage'] as Map))
          : null,
      missions: _parseMissions(map['missions']),
      knowledgeDNA: map['knowledgeDNA'] != null
          ? KnowledgeDNA.fromMap(
              Map<String, dynamic>.from(map['knowledgeDNA'] as Map))
          : null,
      portfolio: map['portfolio'] != null
          ? Portfolio.fromMap(
              Map<String, dynamic>.from(map['portfolio'] as Map))
          : null,
      resume: map['resume'] != null
          ? Resume.fromMap(
              Map<String, dynamic>.from(map['resume'] as Map))
          : null,
      careerProfile: map['careerProfile'] != null
          ? CareerProfile.fromMap(
              Map<String, dynamic>.from(map['careerProfile'] as Map))
          : null,
      interviewProfile: map['interviewProfile'] != null
          ? InterviewProfile.fromMap(
              Map<String, dynamic>.from(map['interviewProfile'] as Map))
          : null,
      opportunities: _parseOpportunities(map['opportunities']),
      settings: map['settings'] != null
          ? UserSettings.fromMap(
              Map<String, dynamic>.from(map['settings'] as Map))
          : const UserSettings(),
      achievements: _parseAchievements(map['achievements']),
      learningProgress: _parseLearningProgress(map['learningProgress']),
      habits: _parseHabits(map['habits']),
      habitEntries: _parseHabitEntries(map['habitEntries']),
      decisionHistory: _parseDecisionHistory(map['decisionHistory']),
      memoryGraphData: map['memoryGraphData'] != null
          ? Map<String, dynamic>.from(map['memoryGraphData'] as Map)
          : null,
      knowledgeSnapshot: map['knowledgeSnapshot'] != null
          ? Map<String, dynamic>.from(map['knowledgeSnapshot'] as Map)
          : null,
      aiContext: map['aiContext'] as String?,
      lastActivityAt: map['lastActivityAt'] != null
          ? DateTime.parse(map['lastActivityAt'] as String)
          : null,
      currentFocus: map['currentFocus'] as String?,
      totalXp: map['totalXp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
    );
  }

  /// Serializes to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates from a JSON string.
  factory UserState.fromJson(String source) =>
      UserState.fromMap(json.decode(source) as Map<String, dynamic>);

  // ── Serialization Helpers ─────────────────────────────────────────

  static List<mission_engine.Mission> _parseMissions(dynamic data) {
    if (data == null) return const [];
    return (data as List)
        .map((m) => mission_engine.Mission.fromMap(
            Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  static List<LearningProgress> _parseLearningProgress(dynamic data) {
    if (data == null) return const [];
    return (data as List)
        .map((lp) => LearningProgress.fromMap(
            Map<String, dynamic>.from(lp as Map)))
        .toList();
  }

  static List<DecisionAnalysis> _parseDecisionHistory(dynamic data) {
    if (data == null) return const [];
    return (data as List)
        .map((da) => DecisionAnalysis.fromMap(
            Map<String, dynamic>.from(da as Map)))
        .toList();
  }

  static List<Habit> _parseHabits(dynamic data) {
    if (data == null) return const [];
    return (data as List)
        .map((h) => Habit.fromMap(
            Map<String, dynamic>.from(h as Map)))
        .toList();
  }

  static List<HabitEntry> _parseHabitEntries(dynamic data) {
    if (data == null) return const [];
    return (data as List)
        .map((e) => HabitEntry.fromMap(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static List<Opportunity> _parseOpportunities(dynamic data) {
    if (data == null) return const [];
    return (data as List)
        .map((o) => Opportunity.fromMap(
            Map<String, dynamic>.from(o as Map)))
        .toList();
  }

  static List<Achievement> _parseAchievements(dynamic data) {
    if (data == null) return const [];
    return (data as List)
        .map((a) => Achievement.fromMap(
            Map<String, dynamic>.from(a as Map)))
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserState && other.version == version;
  }

  @override
  int get hashCode => version.hashCode;

  @override
  String toString() =>
      'UserState(version: $version, identity: ${identity?.title}, '
      'missions: ${missions.length}, xp: $totalXp, level: $level)';
}
