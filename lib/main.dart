import 'package:flutter/material.dart';

import 'core/bootstrap/bootstrap_result.dart';
import 'core/bootstrap/phoenix_bootstrap.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/theme.dart';

Future<void> main() async {
  final bootstrapResult = await PhoenixBootstrap.initialize();
  runApp(PhoenixApp(bootstrapResult: bootstrapResult));
}

class PhoenixApp extends StatelessWidget {
  const PhoenixApp({super.key, this.bootstrapResult});

  final BootstrapResult? bootstrapResult;

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

