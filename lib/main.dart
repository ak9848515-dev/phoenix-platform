import 'package:flutter/material.dart';

import 'core/bootstrap.dart';

export 'core/bootstrap.dart' show PhoenixApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.init();
  runApp(AppBootstrap.createApp());
}
