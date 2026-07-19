import 'dart:async';
import 'package:flutter/foundation.dart';

/// A mixin for [ChangeNotifier] that debounces [notifyListeners] calls.
///
/// When multiple state changes happen within [debounceMs], only one
/// notification is sent. This prevents cascading rebuilds when multiple
/// engines update simultaneously.
///
/// Unlike an opt-in `_debouncedNotify()` method, this mixin **overrides**
/// [notifyListeners] so every call is automatically debounced. For
/// immediate notification (e.g., during initialization), call
/// [notifyImmediately] instead.
///
/// Usage:
/// ```dart
/// class MyEngine extends ChangeNotifier with DebounceChangeNotifier {
///   void update() {
///     // Automatically debounced — called 10 times in 50ms = 1 notification
///     notifyListeners();
///   }
///   void urgentUpdate() {
///     // Skips debounce, notifies immediately
///     notifyImmediately();
///   }
/// }
/// ```
mixin DebounceChangeNotifier on ChangeNotifier {
  Timer? _debounceTimer;
  int _debounceMs = 50;
  bool _disposed = false;

  /// Sets the debounce duration in milliseconds.
  /// Lower values = more responsive but more rebuilds.
  /// Higher values = fewer rebuilds but slightly delayed UI updates.
  void setDebounceMs(int ms) {
    _debounceMs = ms;
  }

  /// Overrides [ChangeNotifier.notifyListeners] to debounce rapid calls.
  /// The notification is delayed by [debounceMs]ms. If called again
  /// within that window, the timer resets. The last call always fires.
  @override
  void notifyListeners() {
    if (_disposed) return;
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(Duration(milliseconds: _debounceMs), () {
      if (!_disposed) {
        _debounceTimer = null;
        super.notifyListeners();
      }
    });
  }

  /// Sends an immediate notification, cancelling any pending debounce.
  void notifyImmediately() {
    if (_disposed) return;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.notifyListeners();
  }

  /// Whether a debounced notification is currently pending.
  bool get hasPendingNotification =>
      _debounceTimer?.isActive ?? false;

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }
}
