import 'package:flutter/material.dart';

import 'core/bootstrap.dart';

export 'core/bootstrap.dart' show PhoenixApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppBootstrap.createApp());
}
