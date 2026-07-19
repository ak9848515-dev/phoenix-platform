import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/memory_category.dart';
import '../models/memory_entry.dart';
import '../models/memory_importance.dart';
import '../models/memory_index.dart';
import '../models/memory_relationship.dart';
import '../models/memory_snapshot.dart';
import 'memory_repository_interface.dart';

/// Local implementation of [MemoryRepositoryInterface] using [SharedPreferences].
class LocalMemoryRepository implements MemoryRepositoryInterface {
  const LocalMemoryRepository();

  static const String _entriesKey = 'memory_entries';
  static const String _relationshipsKey = 'memory_relationships';
  static const String _snapshotKey = 'memory_snapshot';
  static const String _indexKey = 'memory_index';

  @override
  Future<List<MemoryEntry>> loadAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => _entryFromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAllEntries(List<MemoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final list = entries.map((e) => _entryToMap(e)).toList();
    await prefs.setString(_entriesKey, json.encode(list));
  }

  @override
  Future<List<MemoryRelationship>> loadAllRelationships() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_relationshipsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => _relationshipFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAllRelationships(
      List<MemoryRelationship> relationships) async {
    final prefs = await SharedPreferences.getInstance();
    final list = relationships.map((r) => _relationshipToMap(r)).toList();
    await prefs.setString(_relationshipsKey, json.encode(list));
  }

  @override
  Future<MemorySnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return MemorySnapshot(
        totalMemories: map['totalMemories'] as int? ?? 0,
        totalRelationships: map['totalRelationships'] as int? ?? 0,
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(MemorySnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'totalMemories': snapshot.totalMemories,
      'totalRelationships': snapshot.totalRelationships,
      'lastUpdated': snapshot.lastUpdated?.toIso8601String(),
    };
    await prefs.setString(_snapshotKey, json.encode(map));
  }

  @override
  Future<MemoryIndex> loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_indexKey);
    if (raw == null || raw.isEmpty) return const MemoryIndex();
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return MemoryIndex(
        keywordIndex: _stringListMap(map['keywordIndex']),
        tagIndex: _stringListMap(map['tagIndex']),
        categoryIndex: _stringListMap(map['categoryIndex']),
      );
    } catch (_) {
      return const MemoryIndex();
    }
  }

  @override
  Future<void> saveIndex(MemoryIndex index) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'keywordIndex': index.keywordIndex,
      'tagIndex': index.tagIndex,
      'categoryIndex': index.categoryIndex,
    };
    await prefs.setString(_indexKey, json.encode(map));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
    await prefs.remove(_relationshipsKey);
    await prefs.remove(_snapshotKey);
    await prefs.remove(_indexKey);
  }

  // ── Serialisation ─────────────────────────────────────────────────

  Map<String, dynamic> _entryToMap(MemoryEntry e) => {
        'id': e.id,
        'title': e.title,
        'content': e.content,
        'category': e.category.name,
        'importance': e.importance.name,
        'tags': e.tags,
        'relatedMemoryIds': e.relatedMemoryIds,
        'source': e.source,
        'confidence': e.confidence,
        'archived': e.archived,
        'favorite': e.favorite,
        'created': e.created?.toIso8601String(),
        'updated': e.updated?.toIso8601String(),
      };

  MemoryEntry _entryFromMap(Map<String, dynamic> m) => MemoryEntry(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        content: m['content'] as String? ?? '',
        category: _parseCategory(m['category'] as String? ?? ''),
        importance: _parseImportance(m['importance'] as String? ?? ''),
        tags: (m['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        relatedMemoryIds:
            (m['relatedMemoryIds'] as List<dynamic>?)?.cast<String>() ?? [],
        source: m['source'] as String? ?? '',
        confidence: (m['confidence'] as num?)?.toDouble() ?? 1.0,
        archived: m['archived'] as bool? ?? false,
        favorite: m['favorite'] as bool? ?? false,
        created: m['created'] != null
            ? DateTime.parse(m['created'] as String)
            : null,
        updated: m['updated'] != null
            ? DateTime.parse(m['updated'] as String)
            : null,
      );

  Map<String, dynamic> _relationshipToMap(MemoryRelationship r) => {
        'sourceId': r.sourceId,
        'targetId': r.targetId,
        'type': r.type,
        'weight': r.weight,
        'description': r.description,
      };

  MemoryRelationship _relationshipFromMap(Map<String, dynamic> m) =>
      MemoryRelationship(
        sourceId: m['sourceId'] as String,
        targetId: m['targetId'] as String,
        type: m['type'] as String? ?? 'related',
        weight: (m['weight'] as num?)?.toDouble() ?? 1.0,
        description: m['description'] as String? ?? '',
      );

  MemoryCategory _parseCategory(String name) => MemoryCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => MemoryCategory.custom,
      );

  MemoryImportance _parseImportance(String name) =>
      MemoryImportance.values.firstWhere(
        (i) => i.name == name,
        orElse: () => MemoryImportance.medium,
      );

  Map<String, List<String>> _stringListMap(dynamic value) {
    if (value is! Map) return {};
    return value.map((k, v) => MapEntry(
          k as String,
          (v as List<dynamic>).cast<String>(),
        ));
  }
}
