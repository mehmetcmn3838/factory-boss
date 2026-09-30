import 'dart:math' as math;

abstract final class GameConfig {
  static const int offlineLimitHours = 4;
  static const double startingCash = 500;
  static const int baseWarehouseCapacity = 100;
  static const double upgradeGrowth = 1.15;
  static const double warehouseUpgradeGrowth = 1.55;
  static const double salesUpgradeGrowth = 1.45;
  static const int autosaveSeconds = 10;
  static const double xpPerPart = 2;
  static const double xpPerUpgrade = 35;

  static int xpForLevel(int level) => 300 + ((level - 1) * 180);

  static double scaledCost(double baseCost, int level) =>
      (baseCost * math.pow(upgradeGrowth, level - 1)).toDouble();
}

enum MachineKind { lathe, drill, milling, packaging }

class MachineDefinition {
  const MachineDefinition({
    required this.kind,
    required this.name,
    required this.productName,
    required this.unlockLevel,
    required this.baseProductionSeconds,
    required this.baseValue,
    required this.baseUpgradeCost,
    required this.baseReliability,
  });

  final MachineKind kind;
  final String name;
  final String productName;
  final int unlockLevel;
  final double baseProductionSeconds;
  final double baseValue;
  final double baseUpgradeCost;
  final double baseReliability;
}

abstract final class MachineCatalog {
  static const List<MachineDefinition> all = <MachineDefinition>[
    MachineDefinition(
      kind: MachineKind.lathe,
      name: 'CNC Lathe',
      productName: 'Basic Metal Part',
      unlockLevel: 1,
      baseProductionSeconds: 5,
      baseValue: 10,
      baseUpgradeCost: 250,
      baseReliability: .94,
    ),
    MachineDefinition(
      kind: MachineKind.drill,
      name: 'Drill Press',
      productName: 'Drilled Plate',
      unlockLevel: 3,
      baseProductionSeconds: 6.5,
      baseValue: 18,
      baseUpgradeCost: 850,
      baseReliability: .95,
    ),
    MachineDefinition(
      kind: MachineKind.milling,
      name: 'CNC Milling',
      productName: 'Precision Block',
      unlockLevel: 5,
      baseProductionSeconds: 8,
      baseValue: 32,
      baseUpgradeCost: 2200,
      baseReliability: .96,
    ),
    MachineDefinition(
      kind: MachineKind.packaging,
      name: 'Packaging Machine',
      productName: 'Packed Assembly',
      unlockLevel: 8,
      baseProductionSeconds: 10,
      baseValue: 55,
      baseUpgradeCost: 6500,
      baseReliability: .97,
    ),
  ];

  static MachineDefinition byId(String id) => all.firstWhere(
        (definition) => definition.kind.name == id,
        orElse: () => all.first,
      );
}
