import 'package:flutter/foundation.dart';import '../../academy/models/learning_progress.dart';
import '../../habit/models/habit.dart';
import '../../habit/models/habit_entry.dart';
import '../../decision/models/decision_analysis.dart';
import '../../identity/models/identity.dart';
import '../../journey/models/journey.dart';
import '../../journey/models/journey_stage.dart';
import '../../knowledge_dna/models/knowledge_dna.dart';
import '../../mission_engine/mission_engine.dart' as mission_engine;
import '../../portfolio/models/portfolio.dart';
import '../../progress_engine/level_calculator.dart';
import '../../resume/models/resume.dart';
import '../../career/models/career_profile.dart';
import '../../interview/models/interview_profile.dart';
import '../../opportunity/models/opportunity.dart';
import '../../../models/user_settings.dart';
import '../../../models/achievement.dart';
import '../engine/user_state_engine.dart';
import '../models/user_state.dart';

/// Public API for all Phoenix feature modules to read and update user state.
///
/// [UserStateService] is the ONLY entry point for accessing user state.
/// All features (Dashboard, Profile, AI, Mission Engine, Portfolio, Resume,
/// Interview, Opportunity, Academy, etc.) must go through this service.
///
/// Feature engines update User State through this service:
///   MissionEngine → UserStateService
///   ProgressEngine → UserStateService
///   KnowledgeDNA → UserStateService
///   Portfolio → UserStateService
///   Resume → UserStateService
///   Career → UserStateService
///   AI → UserStateService
class UserStateService {
  UserStateService({required this._engine});

  final UserStateEngine _engine;
  final LevelCalculator _levelCalculator = const LevelCalculator();

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the service by loading state from persistence.
  Future<UserState> init() => _engine.load();

  /// Persists the current state.
  Future<void> save() => _engine.save();

  /// Clears all state.
  Future<void> clear() => _engine.clear();

  // ── State Access ──────────────────────────────────────────────────

  /// The current user state (immutable).
  UserState get currentState => _engine.currentState;

  /// Whether the state has been loaded from persistence.
  bool get isLoaded => _engine.isLoaded;

  // ── Read Convenience ──────────────────────────────────────────────

  Identity? get identity => currentState.identity;
  Journey? get journey => currentState.journey;
  JourneyStage? get currentJourneyStage => currentState.currentJourneyStage;
  List<mission_engine.Mission> get missions => currentState.missions;
  KnowledgeDNA? get knowledgeDNA => currentState.knowledgeDNA;
  Portfolio? get portfolio => currentState.portfolio;
  Resume? get resume => currentState.resume;
  CareerProfile? get careerProfile => currentState.careerProfile;
  InterviewProfile? get interviewProfile => currentState.interviewProfile;
  List<Opportunity> get opportunities => currentState.opportunities;
  List<LearningProgress> get learningProgress =>
      currentState.learningProgress;
  List<DecisionAnalysis> get decisionHistory =>
      currentState.decisionHistory;
  List<Habit> get habits => currentState.habits;
  List<HabitEntry> get habitEntries => currentState.habitEntries;
  UserSettings get settings => currentState.settings;
  List<Achievement> get achievements => currentState.achievements;
  Map<String, dynamic>? get memoryGraphData =>
      currentState.memoryGraphData;
  Map<String, dynamic>? get knowledgeSnapshot =>
      currentState.knowledgeSnapshot;
  String? get aiContext => currentState.aiContext;
  int get totalXp => currentState.totalXp;
  int get level => currentState.level;
  bool get hasIdentity => currentState.hasIdentity;
  bool get onboardingComplete => currentState.onboardingComplete;

  // ── Update Convenience ────────────────────────────────────────────

  /// Merges partial updates via callback and persists.
  Future<void> update(
    UserState Function(UserState current) updater,
  ) =>
      _engine.update(updater);

  /// Replaces the entire state.
  Future<void> replace(UserState state) => _engine.replace(state);

  /// Updates just the identity.
  Future<void> setIdentity(Identity identity) =>
      _engine.update((s) => s.copyWith(identity: identity));

  /// Updates just the journey.
  Future<void> setJourney(Journey journey) =>
      _engine.update((s) => s.copyWith(journey: journey));

  /// Updates just the missions.
  Future<void> setMissions(List<mission_engine.Mission> missions) =>
      _engine.update((s) => s.copyWith(missions: missions));

  /// Updates just the knowledge DNA.
  Future<void> setKnowledgeDNA(KnowledgeDNA dna) =>
      _engine.update((s) => s.copyWith(knowledgeDNA: dna));

  /// Updates just the portfolio.
  Future<void> setPortfolio(Portfolio portfolio) =>
      _engine.update((s) => s.copyWith(portfolio: portfolio));

  /// Updates just the resume.
  Future<void> setResume(Resume resume) =>
      _engine.update((s) => s.copyWith(resume: resume));

  /// Updates just the career profile.
  Future<void> setCareerProfile(CareerProfile profile) =>
      _engine.update((s) => s.copyWith(careerProfile: profile));

  /// Updates just the interview profile.
  Future<void> setInterviewProfile(InterviewProfile profile) =>
      _engine.update((s) => s.copyWith(interviewProfile: profile));

  /// Updates just the opportunities.
  Future<void> setOpportunities(List<Opportunity> opportunities) =>
      _engine.update((s) => s.copyWith(opportunities: opportunities));

  /// Updates just the learning progress.
  Future<void> setLearningProgress(List<LearningProgress> progress) =>
      _engine.update((s) => s.copyWith(learningProgress: progress));

  /// Updates just the settings.
  Future<void> setSettings(UserSettings settings) =>
      _engine.update((s) => s.copyWith(settings: settings));

  /// Updates just the AI context.
  Future<void> setAiContext(String context) =>
      _engine.update((s) => s.copyWith(aiContext: context));

  /// Adds XP and recalculates level using [LevelCalculator].
  Future<void> addXp(int amount) => _engine.update((s) {
    final newXp = s.totalXp + amount;
    final newLevel = _levelCalculator.calculate(newXp);
    return s.copyWith(totalXp: newXp, level: newLevel);
  });

  /// Records the current timestamp as last activity.
  Future<void> touch() =>
      _engine.update((s) => s.copyWith(
        lastActivityAt: DateTime.now(),
      ));

  // ── Listeners ─────────────────────────────────────────────────────

  /// Registers a state change listener. Returns a dispose function.
  VoidCallback addListener(VoidCallback listener) =>
      _engine.addListener(listener);

  /// Removes a listener.
  void removeListener(VoidCallback listener) =>
      _engine.removeListener(listener);

  // ── Diagnostics ───────────────────────────────────────────────────

  /// Returns diagnostic info about the current state.
  Map<String, dynamic> diagnostics() => _engine.diagnostics();

  /// Returns validation issues.
  List<String> validate() => _engine.validate();
}
