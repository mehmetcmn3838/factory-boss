import '../utils/config.dart';

class MachineModel {
  MachineModel({
    required this.id,
    this.level = 1,
    this.isBroken = false,
    this.productionProgress = 0,
  });

  final String id;
  int level;
  bool isBroken;
  double productionProgress;

  MachineDefinition get definition => MachineCatalog.byId(id);

  double get productionSeconds =>
      definition.baseProductionSeconds / (1 + ((level - 1) * .075));

  double get productValue =>
      definition.baseValue * (1 + ((level - 1) * .12));

  double get reliability =>
      (definition.baseReliability + ((level - 1) * .0015))
          .clamp(0.0, .995)
          .toDouble();

  double get upgradeCost =>
      GameConfig.scaledCost(definition.baseUpgradeCost, level);

  double get repairCost =>
      (definition.baseUpgradeCost * .18 * (1 + level * .08))
          .clamp(50.0, 999999.0)
          .toDouble();

  double get partsPerMinute => 60 / productionSeconds;

  Map<String, Object> toJson() => <String, Object>{
        'id': id,
        'level': level,
        'isBroken': isBroken,
        'productionProgress': productionProgress,
      };

  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(
        id: json['id'] as String? ?? MachineKind.lathe.name,
        level: json['level'] as int? ?? 1,
        isBroken: json['isBroken'] as bool? ?? false,
        productionProgress:
            (json['productionProgress'] as num?)?.toDouble() ?? 0,
      );
}
