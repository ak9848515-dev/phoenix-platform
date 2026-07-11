import 'package:flutter/material.dart';

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
class PhoenixShell extends StatelessWidget {
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

    return Scaffold(
      appBar: AppBar(
        title: title != null
            ? Text(title!, style: theme.textTheme.titleLarge)
            : null,
        actions: actions,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
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

    return Scaffold(
      appBar: AppBar(
        title: title != null
            ? Text(title!, style: theme.textTheme.titleLarge)
            : null,
        actions: actions,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
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
            Expanded(child: body),
          ],
        ),
      ),
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
