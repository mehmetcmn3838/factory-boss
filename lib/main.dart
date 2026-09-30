import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/factory_screen.dart';
import 'systems/factory_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final controller = FactoryController();
  await controller.initialize();
  runApp(FactoryBossApp(controller: controller));
}

class FactoryBossApp extends StatelessWidget {
  const FactoryBossApp({required this.controller, super.key});

  final FactoryController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Factory Boss',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: FactoryScreen(controller: controller),
    );
  }
}
