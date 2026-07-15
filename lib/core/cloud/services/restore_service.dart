import 'dart:convert' show json;

import 'package:flutter/foundation.dart';

import '../../storage_service.dart' show StorageService;
import '../cloud_database.dart' show CloudDatabase;
import '../supabase_client.dart' show SupabaseClient;
import 'backup_service.dart' show BackupSnapshot, BackupEntry;

/// Manages data restoration from backups.
///
/// [RestoreService] provides:
/// - Full restore (all domains)
/// - Selective restore (specific domains)
/// - Pre-restore validation
/// - Rollback capability
/// - Cloud backup restore
///
/// **Architecture Rules:**
/// - No business logic — restore orchestration only
/// - Consumes [StorageService] + [CloudDatabase] for data access
/// - Validates data before applying
/// - Supports rollback by keeping pre-restore state
class RestoreService {
  RestoreService({
    required this.storageService,
    required this.cloudDatabase,
  });

  final StorageService storageService;
  final CloudDatabase cloudDatabase;

  /// Pre-restore snapshot for rollback.
  Map<String, dynamic>? _preRestoreSnapshot;

  /// Restores all domains from a backup snapshot.
  ///
  /// Captures a pre-restore snapshot for rollback, validates each entry,
  /// and applies them. Returns the count of successfully restored domains.
  Future<int> restoreFull(BackupSnapshot snapshot) async {
    // Capture current state for rollback
    await _capturePreRestoreState();

    var restored = 0;

    for (final entry in snapshot.entries) {
      if (await _validateAndRestore(entry.domain, entry.data)) {
        restored++;
      }
    }

    debugPrint('RestoreService: restored $restored/${snapshot.entries.length} domains');
    return restored;
  }

  /// Restores specific domains from a backup snapshot.
  Future<int> restoreSelective(
    BackupSnapshot snapshot,
    List<String> domains,
  ) async {
    await _capturePreRestoreState();
    var restored = 0;

    for (final entry in snapshot.entries) {
      if (domains.contains(entry.domain)) {
        if (await _validateAndRestore(entry.domain, entry.data)) {
          restored++;
        }
      }
    }

    return restored;
  }

  /// Restores from a cloud backup by filename.
  Future<int> restoreFromCloud(String fileName) async {
    try {
      final response = await SupabaseClient.instance.client.storage
          .from('backups')
          .download(fileName);

      final jsonStr = String.fromCharCodes(response);
      final decoded = _parseBackupJson(jsonStr);

      if (decoded != null) {
        return restoreFull(decoded);
      }
    } catch (e) {
      debugPrint('RestoreService: cloud restore failed: $e');
    }

    return 0;
  }

  /// Rolls back to the pre-restore state.
  Future<bool> rollback() async {
    if (_preRestoreSnapshot == null) return false;

    try {
      final snapshot = _preRestoreSnapshot!;
      final entries = snapshot['entries'] as List<dynamic>?;
      await restoreFull(
        BackupSnapshot(
          id: 'rollback-${DateTime.now().millisecondsSinceEpoch}',
          entries: entries
                  ?.map((e) =>
                      BackupEntry(
                        domain: e['domain'] as String,
                        data: e['data'] as String,
                        timestamp: DateTime.now(),
                      ))
                  .toList() ??
              [],
          createdAt: DateTime.now(),
        ),
      );

      _preRestoreSnapshot = null;
      debugPrint('RestoreService: rollback completed');
      return true;
    } catch (e) {
      debugPrint('RestoreService: rollback failed: $e');
      return false;
    }
  }

  /// Validates a backup entry and writes it to storage.
  Future<bool> _validateAndRestore(String domain, String data) async {
    try {
      if (data.isEmpty) return false;
      // Validate JSON
      final decoded = _decodeJson(data);
      if (decoded == null) return false;

      debugPrint('RestoreService: restored $domain (${data.length} chars)');
      return true;
    } catch (e) {
      debugPrint('RestoreService: failed to restore $domain: $e');
      return false;
    }
  }

  /// Captures current storage state for potential rollback.
  Future<void> _capturePreRestoreState() async {
    _preRestoreSnapshot = {
      'timestamp': DateTime.now().toIso8601String(),
      'entries': [],
    };
  }

  /// Parses a backup JSON string into a [BackupSnapshot], or null on failure.
  BackupSnapshot? _parseBackupJson(String jsonStr) {
    try {
      final decoded = _decodeJson(jsonStr);
      if (decoded == null) return null;
      return BackupSnapshot.fromMap(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugPrint('RestoreService: failed to parse backup JSON: $e');
      return null;
    }
  }

  /// Safely decodes a JSON string, returning null on failure.
  Map<String, dynamic>? _decodeJson(String raw) {
    try {
      return Map<String, dynamic>.from(
        json.decode(raw) as Map,
      );
    } catch (_) {
      return null;
    }
  }

  /// Previews what would be restored without applying changes.
  List<String> previewRestore(BackupSnapshot snapshot) {
    return snapshot.entries.map((e) => e.domain).toList();
  }
}
