import 'cloud_constants.dart' show CloudConstants;
import 'supabase_client.dart' show SupabaseClient;

/// Production database operations for all Phoenix cloud domains.
class CloudDatabase {
  CloudDatabase({required this.supabase});

  final SupabaseClient supabase;

  /// Builds the shared columns for a new row.
  Map<String, dynamic> _sharedRow(Map<String, dynamic> data,
      {bool isUpdate = false}) {
    final now = DateTime.now().toUtc().toIso8601String();
    final userId = supabase.currentUserId ?? '';

    if (!isUpdate) {
      return {
        CloudConstants.colId: data['id'] ?? _generateId(),
        CloudConstants.colUserId: userId,
        CloudConstants.colCreatedAt: now,
        CloudConstants.colUpdatedAt: now,
        CloudConstants.colVersion: 1,
        CloudConstants.colLastSynced: now,
        CloudConstants.colDeletedAt: null,
        ...data,
      };
    }

    return {
      ...data,
      CloudConstants.colUpdatedAt: now,
      CloudConstants.colLastSynced: now,
    };
  }

  // ── Generic CRUD ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data, {
    bool isUpdate = false,
  }) async {
    final row = _sharedRow(data, isUpdate: isUpdate);
    final response = await supabase
        .from(table)
        .upsert(row, onConflict: CloudConstants.colId)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>?> readById(String table, String id) async {
    final response = await supabase
        .from(table)
        .select()
        .eq(CloudConstants.colId, id)
        .filter(CloudConstants.colDeletedAt, 'is', 'null')
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> readAll(String table) async {
    final response = await supabase
        .from(table)
        .select()
        .eq(CloudConstants.colUserId, supabase.currentUserId ?? '')
        .filter(CloudConstants.colDeletedAt, 'is', 'null')
        .order(CloudConstants.colUpdatedAt, ascending: false);
    return response;
  }

  Future<void> softDelete(String table, String id) async {
    await supabase.from(table).update({
      CloudConstants.colDeletedAt: DateTime.now().toUtc().toIso8601String(),
    }).eq(CloudConstants.colId, id);
  }

  Future<void> hardDelete(String table, String id) async {
    await supabase.from(table).delete().eq(CloudConstants.colId, id);
  }

  // ── Domain-specific Read Methods ───────────────────────────────────

  Future<Map<String, dynamic>?> readUserState() async {
    final rows = await supabase
        .from(CloudConstants.tableUserState)
        .select()
        .eq(CloudConstants.colUserId, supabase.currentUserId ?? '')
        .filter(CloudConstants.colDeletedAt, 'is', 'null')
        .limit(1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> readAcademy() =>
      readAll(CloudConstants.tableAcademy);

  Future<List<Map<String, dynamic>>> readHabits() =>
      readAll(CloudConstants.tableHabits);

  Future<List<Map<String, dynamic>>> readHabitEntries() =>
      readAll(CloudConstants.tableHabitEntries);

  Future<List<Map<String, dynamic>>> readTimelineEvents() =>
      readAll(CloudConstants.tableTimelineEvents);

  Future<List<Map<String, dynamic>>> readMilestones() =>
      readAll(CloudConstants.tableMilestones);

  Future<List<Map<String, dynamic>>> readDecisionHistory() =>
      readAll(CloudConstants.tableDecisionHistory);

  Future<Map<String, dynamic>?> readKnowledgeSnapshot() async {
    final rows = await supabase
        .from(CloudConstants.tableKnowledgeSnapshot)
        .select()
        .eq(CloudConstants.colUserId, supabase.currentUserId ?? '')
        .filter(CloudConstants.colDeletedAt, 'is', 'null')
        .limit(1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> readMemoryGraph() =>
      readAll(CloudConstants.tableMemoryGraph);

  // ── Helpers ─────────────────────────────────────────────────────────

  String _generateId() =>
      'phx_${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}';

  String _randomSuffix() =>
      (DateTime.now().microsecondsSinceEpoch % 10000).toString().padLeft(4, '0');
}
