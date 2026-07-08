import 'package:flutter/material.dart';

import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/theme.dart';

void main() {
  runApp(const PhoenixApp());
}

class PhoenixApp extends StatelessWidget {
  const PhoenixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phoenix Platform',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.missionCenter,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

