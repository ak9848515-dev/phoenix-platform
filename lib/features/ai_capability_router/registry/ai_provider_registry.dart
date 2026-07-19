import '../adapters/ai_provider_interface.dart';
import '../models/ai_provider.dart';

/// Registry that maps providers to their adapter implementations.
///
/// Providers are registered dynamically, allowing future providers
/// to be added without changing the router.
///
/// Each provider maps to exactly one adapter at any time.
class AIProviderRegistry {
  final Map<AIProvider, AIProviderInterface> _adapters = {};

  /// Registers an adapter for a provider.
  ///
  /// If an adapter already exists for this provider, it is replaced.
  void register(AIProviderInterface adapter) {
    _adapters[adapter.provider] = adapter;
  }

  /// Registers multiple adapters at once.
  void registerAll(List<AIProviderInterface> adapters) {
    for (final adapter in adapters) {
      register(adapter);
    }
  }

  /// Returns the adapter for the given provider, or `null` if not registered.
  AIProviderInterface? getAdapter(AIProvider provider) => _adapters[provider];

  /// Returns all registered providers.
  List<AIProvider> get registeredProviders =>
      _adapters.keys.toList();

  /// Returns all registered adapters.
  List<AIProviderInterface> get registeredAdapters =>
      _adapters.values.toList();

  /// Whether a provider is registered.
  bool isRegistered(AIProvider provider) => _adapters.containsKey(provider);

  /// Removes an adapter from the registry.
  void unregister(AIProvider provider) {
    _adapters.remove(provider);
  }

  /// Clears all registered adapters.
  void clear() {
    _adapters.clear();
  }

  /// Returns the number of registered providers.
  int get count => _adapters.length;
}
