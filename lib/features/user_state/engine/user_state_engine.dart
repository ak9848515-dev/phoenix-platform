import 'package:flutter/foundation.dart';

import '../models/user_state.dart';
import '../repository/user_state_repository.dart';

/// Manages the user state lifecycle.
///
/// The [UserStateEngine] is responsible for:
/// - Loading state from persistence
/// - Saving state to persistence
/// - Merging partial updates
/// - Notifying listeners of state changes
/// - Handling schema migrations
/// - Validating state integrity
/// - Caching state for quick access
///
/// No other module should manage user state lifecycle directly.
class UserStateEngine {
  UserStateEngine({required this._repository});

  final UserStateRepository _repository;
  UserState? _currentState;
  final ListenerList _listeners = ListenerList();

  // ── State Access ──────────────────────────────────────────────────

  /// Returns the current in-memory state, or a default if not loaded.
  UserState get currentState =>
      _currentState ?? const UserState();

  /// Whether the state has been loaded from persistence.
  bool get isLoaded => _currentState != null;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Loads state from persistence. Returns the loaded state or default.
  Future<UserState> load() async {
    final persisted = await _repository.loadState();
    if (persisted != null) {
      _currentState = _migrateIfNeeded(persisted);
    } else {
      // Try cache
      final cached = await _repository.loadCachedState();
      _currentState = cached != null
          ? _migrateIfNeeded(cached)
          : const UserState();
    }
    _notifyListeners();
    return currentState;
  }

  /// Persists the current state.
  Future<void> save() async {
    if (_currentState == null) return;
    await _repository.saveState(_currentState!);
    await _repository.cacheState(_currentState!);
  }

  /// Replaces the entire state and persists.
  Future<void> replace(UserState newState) async {
    _currentState = newState;
    await save();
    _notifyListeners();
  }

  /// Updates specific fields via [copyWith] and persists.
  Future<void> update(UserState Function(UserState current) updater) async {
    final updated = updater(currentState);
    _currentState = updated;
    await save();
    _notifyListeners();
  }

  /// Clears all state (memory + persistence).
  Future<void> clear() async {
    _currentState = null;
    await _repository.clearState();
    _notifyListeners();
  }

  // ── Listener Management ───────────────────────────────────────────

  /// Registers a listener that is called whenever state changes.
  /// Returns a function that removes the listener when called.
  VoidCallback addListener(VoidCallback listener) {
    return _listeners.add(listener);
  }

  /// Removes a previously registered listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    _listeners.notify();
  }

  // ── Migration ─────────────────────────────────────────────────────

  /// Checks if the persisted state needs migration and applies it.
  UserState _migrateIfNeeded(UserState persisted) {
    if (persisted.version >= userStateVersion) return persisted;
    // Future migrations go here:
    // if (persisted.version < 2) { ... }
    return persisted.copyWith(version: userStateVersion);
  }

  // ── Validation ────────────────────────────────────────────────────

  /// Validates the current state and returns a list of issues.
  List<String> validate() {
    final issues = <String>[];
    final state = currentState;

    if (state.totalXp < 0) {
      issues.add('totalXp cannot be negative.');
    }
    if (state.level < 1) {
      issues.add('level must be at least 1.');
    }
    if (state.missions.length > 1000) {
      issues.add('Excessive mission count: ${state.missions.length}.');
    }

    return issues;
  }

  // ── Statistics ────────────────────────────────────────────────────

  /// Returns a map of diagnostic statistics about the current state.
  Map<String, dynamic> diagnostics() {
    final state = currentState;
    return {
      'loaded': isLoaded,
      'version': state.version,
      'hasIdentity': state.hasIdentity,
      'onboardingComplete': state.onboardingComplete,
      'missionCount': state.missions.length,
      'achievementCount': state.achievements.length,
      'opportunityCount': state.opportunities.length,
      'totalXp': state.totalXp,
      'level': state.level,
    };
  }
}

// ── ListenerList ──────────────────────────────────────────────────────────

/// Thread-safe list of listeners with efficient add/remove/notify.
class ListenerList {
  final List<VoidCallback> _listeners = [];

  /// Adds a listener and returns a disposable token.
  VoidCallback add(VoidCallback listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  /// Removes a previously added listener.
  void remove(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners.
  void notify() {
    // Iterate over a copy to prevent concurrent modification issues.
    final copy = List<VoidCallback>.from(_listeners);
    for (final listener in copy) {
      listener();
    }
  }
}
