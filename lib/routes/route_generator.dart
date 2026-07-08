import 'package:flutter/material.dart';

import '../features/knowledge_dna/presentation/knowledge_dna_screen.dart';
import '../features/mission_center/mission_center_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.missionCenter:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const MissionCenterScreen(),
        );
      case AppRoutes.knowledgeDna:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const KnowledgeDNAScreen(),
        );
      default:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const MissionCenterScreen(),
        );
    }
  }
}
