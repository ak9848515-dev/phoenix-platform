import 'package:flutter/material.dart';

import '../../features/voice/models/voice_command.dart';
import '../../features/voice/services/voice_command_router.dart';
import '../../features/voice/services/voice_service.dart';
import '../../features/voice/widgets/listening_overlay.dart';
import '../../features/voice/widgets/voice_button.dart';
import '../../core/bootstrap.dart';
import '../../features/notification_center/engine/notification_engine.dart';
import '../../routes/app_routes.dart';
import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_spacing.dart';

/// Returns the FAB icon for each navigation tab.
IconData _fabIconForIndex(int index) {
  switch (index) {
    case 0:
      return Icons.play_circle_rounded; // Dashboard: Continue Journey
    case 1:
      return Icons.play_arrow_rounded; // Missions: Resume Mission
    case 2:
      return Icons.auto_awesome_rounded; // Learn: Ask AI
    case 3:
      return Icons.assessment_rounded; // Progress: Generate Report
    case 4:
      return Icons.edit_rounded; // Profile: Quick Edit
    default:
      return Icons.add_rounded;
  }
}

/// A reusable shell layout that owns the AppBar, navigation, FAB, and content area.
///
/// - **Phone**: BottomNavigationBar at the bottom
/// - **Tablet/Desktop**: NavigationRail on the left
/// - **FAB**: One per screen, changes by tab
///
/// The shell does **not** contain any business logic.
class PhoenixShell extends StatefulWidget {
  const PhoenixShell({
    super.key,
    required this.body,
    required this.selectedIndex,
    this.title,
    this.actions,
    this.onFabTap,
  });

  /// The content widget displayed in the shell's body area.
  final Widget body;

  /// The index of the currently selected navigation destination (0-4).
  final int selectedIndex;

  /// Optional title displayed in the AppBar.
  final String? title;

  /// Optional list of widgets displayed as actions in the AppBar.
  final List<Widget>? actions;

  /// Optional FAB tap handler. If null, no FAB is shown.
  final VoidCallback? onFabTap;

  @override
  State<PhoenixShell> createState() => _PhoenixShellState();
}

class _PhoenixShellState extends State<PhoenixShell> {
  final VoiceCommandRouter _voiceRouter = VoiceCommandRouter();
  NotificationEngine? _notifEngine;

  static const List<_NavigationDestination> _destinations = [
    _NavigationDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: '/dashboard',
    ),
    _NavigationDestination(
      label: 'Missions',
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
      label: 'Progress',
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up,
      route: '/progress',
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
  void initState() {
    super.initState();
    _notifEngine = AppBootstrap.maybeNotificationEngine;
    _notifEngine?.addListener(_onNotifChanged);
  }

  @override
  void dispose() {
    _notifEngine?.removeListener(_onNotifChanged);
    super.dispose();
  }

  void _onNotifChanged() {
    if (mounted) setState(() {});
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

  // ── Shared AppBar Actions ──────────────────────────────────────────
  //
  // Top App Bar contains ONLY:
  //   Community · Notifications · Phoenix AI · Search · Voice
  //
  // Profile icon removed to eliminate duplicate navigation.
  // Profile is accessed via bottom navigation (tab index 4).

  List<Widget> _buildAppBarActions(BuildContext context) {
    final voiceService = AppBootstrap.maybeVoiceService;

    return [
      if (widget.actions != null) ...widget.actions!,
      Semantics(
        label: 'Notifications',
        button: true,
        child: _NotificationBadge(
          count: AppBootstrap.maybeNotificationEngine?.unreadCount ?? 0,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.notifications),
        ),
      ),
      Semantics(
        label: 'AI Assistant',
        button: true,
        child: IconButton(
          icon: const Icon(Icons.auto_awesome_rounded),
          tooltip: 'AI Assistant',
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.ai),
        ),
      ),
      Semantics(
        label: 'Search Knowledge',
        button: true,
        child: IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search',
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.globalSearch),
        ),
      ),
      if (voiceService != null)
        VoiceButton(
          voiceService: voiceService,
          size: 40,
          onCommand: (command) => _handleVoiceCommand(context, command),
        ),
    ];
  }

  // ── Phone Layout ──────────────────────────────────────────────────

  Widget _buildWithBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final voiceService = AppBootstrap.maybeVoiceService;

    return Scaffold(
      appBar: AppBar(
        title: widget.title != null
            ? Text(widget.title!, style: theme.textTheme.titleLarge)
            : null,
        actions: _buildAppBarActions(context),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBodyWithVoiceOverlay(context, voiceService),
      ),
      floatingActionButton: widget.onFabTap != null
          ? FloatingActionButton(
              mini: true,
              onPressed: widget.onFabTap,
              tooltip: _fabLabelForIndex(widget.selectedIndex),
              child: Icon(_fabIconForIndex(widget.selectedIndex)),
            )
          : null,
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

  // ── Tablet/Desktop Layout ─────────────────────────────────────────

  Widget _buildWithNavigationRail(BuildContext context) {
    final theme = Theme.of(context);
    final voiceService = AppBootstrap.maybeVoiceService;

    return Scaffold(
      appBar: AppBar(
        title: widget.title != null
            ? Text(widget.title!, style: theme.textTheme.titleLarge)
            : null,
        actions: _buildAppBarActions(context),
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
                padding: const EdgeInsets.symmetric(vertical: PhoenixSpacing.md),
                child: Icon(
                  Icons.auto_awesome,
                  color: PhoenixColors.primary,
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
      floatingActionButton: widget.onFabTap != null
          ? FloatingActionButton(
              mini: true,
              onPressed: widget.onFabTap,
              tooltip: _fabLabelForIndex(widget.selectedIndex),
              child: Icon(_fabIconForIndex(widget.selectedIndex)),
            )
          : null,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  static String _fabLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Continue Journey';
      case 1:
        return 'Resume Mission';
      case 2:
        return 'Ask AI';
      case 3:
        return 'Generate Report';
      case 4:
        return 'Quick Edit';
      default:
        return 'Action';
    }
  }

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

  void _handleVoiceCommand(BuildContext context, VoiceCommand command) {
    _voiceRouter.execute(command, Navigator.of(context));
  }
}

/// A notification bell icon with an animated unread badge count.
class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: count > 0
          ? Badge(
              isLabelVisible: count > 0,
              label: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
              child: const Icon(Icons.notifications_outlined),
            )
          : const Icon(Icons.notifications_outlined),
      tooltip: 'Notifications',
      onPressed: onPressed,
    );
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