import 'package:flutter/material.dart';

import 'route_generator.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return RouteGenerator.generateRoute(settings);
  }
}
