/// Represents the installation status of a plugin in the marketplace.
///
/// Tracks whether a plugin is installed, active, or available for installation.
enum InstallStatus {
  /// Plugin is not yet installed.
  notInstalled,

  /// Plugin is being installed (future use).
  installing,

  /// Plugin is installed but not active.
  installed,

  /// Plugin is installed and active.
  active,

  /// Plugin installation failed with an error.
  error,

  /// Plugin has been removed.
  removed,
}

/// Tracks a plugin's installation state in the marketplace.
///
/// Provides a snapshot of what happened during install/activate/deactivate
/// operations. No persistence, no networking, no AI.
class PluginInstallation {
  const PluginInstallation({
    required this.pluginId,
    required this.pluginName,
    this.status = InstallStatus.notInstalled,
    this.installedAt,
    this.error,
  });

  /// The unique identifier of the plugin.
  final String pluginId;

  /// Human-readable name of the plugin.
  final String pluginName;

  /// Current installation status.
  final InstallStatus status;

  /// When the plugin was installed. Null if not yet installed.
  final DateTime? installedAt;

  /// Error message if the installation failed.
  final String? error;

  /// Whether the plugin is successfully installed (installed or active).
  bool get isInstalled =>
      status == InstallStatus.installed || status == InstallStatus.active;

  /// Whether the plugin is currently active.
  bool get isActive => status == InstallStatus.active;

  /// Creates a copy with the given fields replaced.
  PluginInstallation copyWith({
    String? pluginId,
    String? pluginName,
    InstallStatus? status,
    DateTime? installedAt,
    String? error,
  }) {
    return PluginInstallation(
      pluginId: pluginId ?? this.pluginId,
      pluginName: pluginName ?? this.pluginName,
      status: status ?? this.status,
      installedAt: installedAt ?? this.installedAt,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PluginInstallation &&
        other.pluginId == pluginId &&
        other.pluginName == pluginName &&
        other.status == status &&
        other.installedAt == installedAt &&
        other.error == error;
  }

  @override
  int get hashCode =>
      Object.hash(pluginId, pluginName, status, installedAt, error);

  @override
  String toString() {
    return 'PluginInstallation($pluginId, status: ${status.name})';
  }
}
