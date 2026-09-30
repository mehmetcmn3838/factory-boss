import 'package:factory_boss/models/machine_model.dart';
import 'package:factory_boss/systems/economy_system.dart';
import 'package:factory_boss/utils/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EconomySystem', () {
    test('machine upgrade cost scales by configured growth', () {
      final machine = MachineModel(id: MachineKind.lathe.name, level: 2);
      expect(machine.upgradeCost, closeTo(287.5, .001));
    });

    test('compact money formats common ranges', () {
      expect(EconomySystem.compactMoney(12500), r'$12.50K');
      expect(EconomySystem.compactMoney(2000000), r'$2.00M');
    });
  });
}
