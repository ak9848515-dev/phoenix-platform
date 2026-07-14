import 'package:flutter/material.dart';

import '../../features/voice/models/voice_command.dart';
import '../../features/voice/services/voice_command_router.dart';
import '../../features/voice/services/voice_service.dart';
import '../../features/voice/widgets/listening_overlay.dart';
import '../../features/voice/widgets/voice_button.dart';
import '../../core/bootstrap.dart';
import '../../routes/app_routes.dart';
import '../../theme/spacing.dart';
import '../../theme/colors.dart';

/// A reusable shell layout that owns the AppBar, navigation, and content area.
///
/// This shell adapts to the form factor:
/// - **Phone**: BottomNavigationBar at the bottom
/// - **Tablet/Desktop**: NavigationRail on the left
///
/// It expects to be hosted inside a route and will navigate to the appropriate
/// route when a navigation destination is tapped.
///
/// The shell does **not** contain any business logic. It is purely a layout
/// and navigation wrapper.
class PhoenixShell extends StatefulWidget {
  const PhoenixShell({
    super.key,
    required this.body,
    required this.selectedIndex,
    this.title,
    this.actions,
  });

  /// The content widget displayed in the shell's body area.
  final Widget body;

  /// The index of the currently selected navigation destination.
  final int selectedIndex;

  /// Optional title displayed in the AppBar.
  final String? title;

  /// Optional list of widgets displayed as actions in the AppBar.
  final List<Widget>? actions;

  @override
  State<PhoenixShell> createState() => _PhoenixShellState();
}

class _PhoenixShellState extends State<PhoenixShell> {
  final VoiceCommandRouter _voiceRouter = VoiceCommandRouter();

  static const List<_NavigationDestination> _destinations = [
    _NavigationDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: '/dashboard',
    ),
    _NavigationDestination(
      label: 'Mission',
      icon: Icons.rocket_launch_outlined,
      activeIcon: Icons.rocket_launch,
      route: '/',
    ),
    _NavigationDestination(
      label: 'Learn',
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      route: '/academy',
    ),
    _NavigationDestination(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile',
    ),
  ];

  void _onDestinationTap(BuildContext context, int index) {
    final destination = _destinations[index];
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(destination.route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useNavigationRail = constraints.maxWidth >= 720;

        if (useNavigationRail) {
          return _buildWithNavigationRail(context);
        }

        return _buildWithBottomNav(context);
      },
    );
  }

  Widget _buildWithBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final voiceService = AppBootstrap.maybeVoiceService;

    // Build AppBar actions with Search + VoiceButton appended
    final appBarActions = <Widget>[
      if (widget.actions != null) ...widget.actions!,
      IconButton(
        icon: const Icon(Icons.search_rounded),
        tooltip: 'Search',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.globalSearch),
      ),
      if (voiceService != null)
        VoiceButton(
          voiceService: voiceService,
          size: 40,
          onCommand: (command) => _handleVoiceCommand(context, command),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: widget.title != null
            ? Text(widget.title!, style: theme.textTheme.titleLarge)
            : null,
        actions: appBarActions,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBodyWithVoiceOverlay(context, voiceService),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: (index) => _onDestinationTap(context, index),
        destinations: _destinations.map((d) {
          return NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.activeIcon),
            label: d.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWithNavigationRail(BuildContext context) {
    final theme = Theme.of(context);
    final voiceService = AppBootstrap.maybeVoiceService;

    // Build AppBar actions with Search + VoiceButton appended
    final appBarActions = <Widget>[
      if (widget.actions != null) ...widget.actions!,
      IconButton(
        icon: const Icon(Icons.search_rounded),
        tooltip: 'Search',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.globalSearch),
      ),
      if (voiceService != null)
        VoiceButton(
          voiceService: voiceService,
          size: 40,
          onCommand: (command) => _handleVoiceCommand(context, command),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: widget.title != null
            ? Text(widget.title!, style: theme.textTheme.titleLarge)
            : null,
        actions: appBarActions,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: (index) =>
                  _onDestinationTap(context, index),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              destinations: _destinations.map((d) {
                return NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: Text(d.label),
                );
              }).toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildBodyWithVoiceOverlay(context, voiceService),
            ),
          ],
        ),
      ),
    );
  }

  /// Wraps the body in a Stack with the voice overlay positioned
  /// at the bottom when voice is available.
  Widget _buildBodyWithVoiceOverlay(
    BuildContext context,
    VoiceService? voiceService,
  ) {
    if (voiceService == null) return widget.body;

    return Stack(
      children: [
        widget.body,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ListeningOverlay(voiceService: voiceService),
        ),
      ],
    );
  }

  /// Handles a recognised voice command by routing it to the
  /// appropriate navigation destination.
  ///
  /// Uses the pre-parsed [VoiceCommand] directly to avoid a redundant
  /// re-parse cycle. The command's [VoiceCommand.route] is pushed
  /// onto the navigator stack via [VoiceCommandRouter.execute].
  void _handleVoiceCommand(BuildContext context, VoiceCommand command) {
    _voiceRouter.execute(command, Navigator.of(context));
  }
}

/// Internal data class for a navigation destination.
class _NavigationDestination {
  const _NavigationDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}
