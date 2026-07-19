import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/app_settings.dart';
import '../models/settings_snapshot.dart';
import '../services/settings_service.dart';

/// Lifecycle state of the settings engine.
enum SettingsEngineState {
  uninitialized,
  loading,
  ready,
  error,
}

/// Single source of truth for application settings.
///
/// [SettingsEngine] owns all settings state and produces a unified
/// [SettingsSnapshot] that every consumer (widget) reads.
///
/// **Architecture:**
/// ```
/// Widget → SettingsSnapshot ← SettingsEngine ← SettingsService ← Repository
/// ```
///
/// **Responsibilities:**
/// - Expose immutable [SettingsSnapshot] for all consumers
/// - Track dirty state (unsaved changes)
/// - Track initialization status
/// - Delegate persistence to [SettingsService]
/// - Notify listeners on state changes
///
/// **Rules:**
/// - No AI logic
/// - No business logic — delegates to [SettingsService]
/// - Widgets read [SettingsSnapshot] only
class SettingsEngine extends ChangeNotifier {
  SettingsEngine({required this._settingsService})
      : _logger = PhoenixLogger.shared {
    _settingsService.addListener(_onSettingsChanged);
  }

  final SettingsService _settingsService;
  final PhoenixLogger _logger;

  SettingsSnapshot? _snapshot;
  SettingsEngineState _state = SettingsEngineState.uninitialized;
  AppSettings? _savedSettings;

  // ── Accessors ─────────────────────────────────────────────────────

  /// Current settings snapshot. [SettingsSnapshot.uninitialized] before init.
  SettingsSnapshot get snapshot =>
      _snapshot ?? SettingsSnapshot.uninitialized();

  /// Current lifecycle state.
  SettingsEngineState get state => _state;

  /// Whether the engine has been initialized.
  bool get isInitialized => _state == SettingsEngineState.ready;

  /// Whether there are unsaved changes.
  bool get isDirty => _snapshot?.isDirty ?? false;

  /// Whether the engine is in an error state.
  bool get hasError => _state == SettingsEngineState.error;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine by loading settings from the service.
  ///
  /// Must be called once before any consumer reads the snapshot.
  Future<void> init() async {
    _state = SettingsEngineState.loading;
    notifyListeners();

    try {
      final settings = await _settingsService.load();
      _savedSettings = settings;
      _snapshot = _buildSnapshot(settings, isDirty: false);
      _state = SettingsEngineState.ready;
      _logger.info('SettingsEngine initialized',
          category: LogCategory.config, source: 'SettingsEngine');
    } catch (e) {
      _state = SettingsEngineState.error;
      _snapshot = SettingsSnapshot.uninitialized();
      _logger.error('SettingsEngine init failed',
          category: LogCategory.config,
          source: 'SettingsEngine',
          errorDetail: e.toString());
    }

    notifyListeners();
  }

  /// Reloads settings from storage and refreshes the snapshot.
  Future<void> refresh() async {
    final settings = await _settingsService.load();
    _savedSettings = settings;
    _snapshot = _buildSnapshot(settings, isDirty: false);
    _logger.info('SettingsEngine refreshed',
        category: LogCategory.config, source: 'SettingsEngine');
    notifyListeners();
  }

  /// Resets all settings to defaults.
  Future<void> reset() async {
    _savedSettings = const AppSettings();
    _snapshot = _buildSnapshot(_savedSettings!, isDirty: false);
    await _settingsService.resetAll();
    _logger.info('SettingsEngine reset',
        category: LogCategory.config, source: 'SettingsEngine');
    notifyListeners();
  }

  /// Disposes the engine and cleans up listeners.
  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  // ── Mutation Helpers ──────────────────────────────────────────────

  /// Updates the theme mode via the settings service.
  Future<void> updateThemeMode(ThemeModePreference mode) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateThemeMode(current, mode);
  }

  /// Updates the accent color via the settings service.
  Future<void> updateAccentColor(String color) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateAccentColor(current, color);
  }

  /// Updates notification settings via the settings service.
  Future<void> updateNotifications(NotificationSettings notifications) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateNotifications(current, notifications);
  }

  /// Updates sync settings via the settings service.
  Future<void> updateSync(SyncSettings sync) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateSync(current, sync);
  }

  /// Updates privacy settings via the settings service.
  Future<void> updatePrivacy(PrivacySettings privacy) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updatePrivacy(current, privacy);
  }

  /// Updates learning preferences via the settings service.
  Future<void> updateLearning(LearningPreferences learning) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateLearning(current, learning);
  }

  /// Updates AI provider preferences via the settings service.
  Future<void> updateAIProvider(AIProviderPreferences aiProvider) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateAIProvider(current, aiProvider);
  }

  /// Updates accessibility settings via the settings service.
  Future<void> updateAccessibility(AccessibilitySettings accessibility) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateAccessibility(current, accessibility);
  }

  /// Updates storage settings via the settings service.
  Future<void> updateStorage(StorageSettings storage) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateStorage(current, storage);
  }

  /// Updates diagnostics settings via the settings service.
  Future<void> updateDiagnostics(DiagnosticsSettings diagnostics) async {
    final current = _snapshot?.settings ?? const AppSettings();
    await _settingsService.updateDiagnostics(current, diagnostics);
  }

  // ── Import / Export ──────────────────────────────────────────────

  /// Exports settings as a JSON string.
  Future<String> exportJson() => _settingsService.exportJson();

  /// Imports settings from a JSON string and refreshes.
  Future<bool> importJson(String jsonString) async {
    final success = await _settingsService.importJson(jsonString);
    if (success) {
      await refresh();
    }
    return success;
  }

  // ── Internal ─────────────────────────────────────────────────────

  void _onSettingsChanged(AppSettings settings) {
    _savedSettings = settings;
    _snapshot = _buildSnapshot(settings, isDirty: false);
    notifyListeners();
  }

  SettingsSnapshot _buildSnapshot(AppSettings settings, {required bool isDirty}) {
    return SettingsSnapshot(
      settings: settings,
      lastUpdated: DateTime.now(),
      isDirty: isDirty,
      isInitialized: _state == SettingsEngineState.ready,
    );
  }
}
