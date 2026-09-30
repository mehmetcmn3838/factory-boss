import 'package:factory_boss/main.dart';
import 'package:factory_boss/systems/factory_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Factory Boss app starts on the factory screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = FactoryController();
    await controller.initialize();

    await tester.pumpWidget(FactoryBossApp(controller: controller));
    await tester.pump();

    expect(find.text('FACTORY LEVEL 1'), findsOneWidget);
    expect(find.text('CASH'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await controller.save();
    controller.dispose();
  });
}
