import 'package:flutter/material.dart';

import '../features/academy/academy_screen.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/identity/presentation/identity_selection_screen.dart';
import '../features/memory/presentation/memory_screen.dart';
import '../features/recommendation/presentation/recommendation_screen.dart';
import '../features/knowledge_dna/presentation/knowledge_dna_screen.dart';
import '../features/mission_center/mission_center_screen.dart';
import '../features/progress/progress_screen.dart';
import '../shared/widgets/phoenix_shell.dart';
import 'app_routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dashboard:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Dashboard',
            body: DashboardPage(),
          ),
        );
      case AppRoutes.missionCenter:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 1,
            title: 'Mission Center',
            body: MissionCenterScreen(),
          ),
        );
      case AppRoutes.knowledgeDna:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Knowledge DNA',
            body: KnowledgeDNAScreen(),
          ),
        );
      case AppRoutes.academy:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 2,
            title: 'Academy',
            body: AcademyScreen(),
          ),
        );
      case AppRoutes.progress:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Progress',
            body: ProgressScreen(),
          ),
        );
      case AppRoutes.recommendation:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Recommendations',
            body: RecommendationScreen(),
          ),
        );
      case AppRoutes.memory:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Memory',
            body: MemoryScreen(),
          ),
        );
      case AppRoutes.identity:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Identity',
            body: IdentitySelectionScreen(),
          ),
        );
      case AppRoutes.profile:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 3,
            title: 'Profile',
            body: _PlaceholderPage(label: 'Profile'),
          ),
        );
      default:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 1,
            title: 'Mission Center',
            body: MissionCenterScreen(),
          ),
        );
    }
  }
}

/// Temporary placeholder for routes that don't have a screen yet.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text('$label — Coming Soon', style: theme.textTheme.titleMedium),
    );
  }
}
