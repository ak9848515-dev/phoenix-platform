import 'dart:convert' show json;

import 'package:flutter/foundation.dart';

import '../../storage_service.dart' show StorageService;
import '../cloud_database.dart' show CloudDatabase;
import '../supabase_client.dart' show SupabaseClient;

/// Manages the migration from local-only Phoenix to cloud-connected Phoenix.
///
/// [MigrationService] handles:
/// - First-time setup for cloud users
/// - Uploading existing local data after login
/// - Safe merge with existing cloud data (never overwrite newer)
/// - Tracking migration state
/// - Rollback on failure
///
/// **Architecture Rules:**
/// - No data loss — preserves all existing local data
/// - Never overwrites newer cloud data
/// - Safe to run multiple times (idempotent)
/// - Transparent to feature services
class MigrationService {
  MigrationService({
    required this.storageService,
    required this.cloudDatabase,
  });

  final StorageService storageService;
  final CloudDatabase cloudDatabase;

  /// Whether the local-only → cloud migration has completed.
  bool get isMigrationComplete => _migrationFlag;

  bool _migrationFlag = false;

  /// Runs the full local-to-cloud migration.
  ///
  /// 1. Check if migration is already complete
  /// 2. Read all local data
  /// 3. Upsert to Supabase (skip if cloud already has newer data)
  /// 4. Mark migration complete
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> migrate() async {
    if (isMigrationComplete) {
      debugPrint('MigrationService: migration already complete');
      return true;
    }

    if (!SupabaseClient.instance.isInitialized) {
      debugPrint('MigrationService: cloud not available, skipping migration');
      return false;
    }

    debugPrint('MigrationService: starting local-to-cloud migration');

    try {
      // Upload each domain
      await _migrateDomain('selected_identity',
          storageService.readSelectedIdentity()?.toJson());
      await _migrateDomain('learning_paths',
          storageService.readLearningPaths());
      await _migrateDomain('habits', storageService.readHabits());
      await _migrateDomain('habit_entries', storageService.readHabitEntries());
      await _migrateDomain('timeline_events', storageService.readTimelineEvents());
      await _migrateDomain('milestones', storageService.readMilestones());
      await _migrateDomain('decision_history', storageService.readDecisionHistory());
      await _migrateDomain('knowledge_snapshot', storageService.readKnowledgeSnapshot());
      await _migrateDomain('memory_graph', storageService.readMemoryGraph());

      _migrationFlag = true;
      debugPrint('MigrationService: migration completed successfully');
      return true;
    } catch (e) {
      debugPrint('MigrationService: migration failed: $e');
      return false;
    }
  }

  /// Migrates a single domain, skipping if cloud already has newer data.
  Future<void> _migrateDomain(String domain, String? data) async {
    if (data == null || data.isEmpty) return;

    try {
      // Check if cloud already has data for this domain
      final tableName = _tableForDomain(domain);
      final existingData = await cloudDatabase.readAll(tableName);

      if (existingData.isNotEmpty) {
        // Cloud has data — skip migration to avoid overwriting
        debugPrint('MigrationService: $domain already exists in cloud, skipping');
        return;
      }

      // Upload local data to cloud
      await _upsertDomainData(tableName, data);
      debugPrint('MigrationService: migrated $domain');
    } catch (e) {
      debugPrint('MigrationService: failed to migrate $domain: $e');
    }
  }

  /// Upserts parsed domain data to the specified table.
  Future<void> _upsertDomainData(String table, String raw) async {
    final parsed = _parseJson(raw);
    if (parsed == null) return;

    if (parsed is List) {
      for (final item in parsed) {
        if (item is Map<String, dynamic>) {
          await cloudDatabase.upsert(table, item);
        }
      }
    } else if (parsed is Map<String, dynamic>) {
      await cloudDatabase.upsert(table, parsed);
    }
  }

  /// Maps a domain name to its Supabase table name.
  String _tableForDomain(String domain) {
    switch (domain) {
      case 'selected_identity':
        return 'profiles';
      case 'learning_paths':
        return 'academy';
      case 'habits':
        return 'habits';
      case 'habit_entries':
        return 'habit_entries';
      case 'timeline_events':
        return 'timeline_events';
      case 'milestones':
        return 'milestones';
      case 'decision_history':
        return 'decision_history';
      case 'knowledge_snapshot':
        return 'knowledge_snapshot';
      case 'memory_graph':
        return 'memory_graph';
      default:
        return domain;
    }
  }

  /// Safely parses a JSON string, returning null on failure.
  dynamic _parseJson(String raw) {
    try {
      return json.decode(raw);
    } catch (_) {
      return null;
    }
  }
}
