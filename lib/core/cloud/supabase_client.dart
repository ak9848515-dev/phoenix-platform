import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'cloud_config.dart' show CloudConfig;

/// Singleton wrapper around the Supabase client.
class SupabaseClient {
  SupabaseClient._();

  static final SupabaseClient _instance = SupabaseClient._();
  static SupabaseClient get instance => _instance;

  supabase.GoTrueClient? _auth;
  supabase.SupabaseClient? _client;
  bool _initialized = false;

  supabase.SupabaseClient get client {
    _assertInitialized();
    return _client!;
  }

  supabase.GoTrueClient get auth {
    _assertInitialized();
    return _auth!;
  }

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await supabase.Supabase.initialize(
        url: CloudConfig.supabaseUrl,
        publishableKey: CloudConfig.supabasePublishableKey
      );
      _client = supabase.Supabase.instance.client;
      _auth = _client!.auth;
      _initialized = true;
      debugPrint('SupabaseClient: initialised');
    } catch (e) {
      debugPrint('SupabaseClient: init failed: $e');
      rethrow;
    }
  }

  supabase.PostgrestQueryBuilder from(String table) {
    _assertInitialized();
    return _client!.from(table);
  }

  Future<bool> tryRefreshSession() async {
    try {
      final response = await auth.refreshSession();
      return response.session != null;
    } catch (_) {
      return false;
    }
  }

  String? get currentUserId => _auth?.currentUser?.id;
  bool get isAuthenticated => _auth?.currentSession != null;

  void dispose() {
    _auth?.dispose();
    _client?.dispose();
    _initialized = false;
    _auth = null;
    _client = null;
  }

  void _assertInitialized() {
    assert(_initialized, 'SupabaseClient not initialised.');
  }
}
