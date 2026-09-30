import '../utils/config.dart';
import 'machine_model.dart';
import 'mission_model.dart';

class PlayerData {
  PlayerData({
    this.cash = GameConfig.startingCash,
    this.factoryLevel = 1,
    this.xp = 0,
    this.warehouseLevel = 1,
    this.storedParts = 0,
    this.salesLevel = 1,
    this.totalProduction = 0,
    this.totalEarned = 0,
    this.totalUpgrades = 0,
    this.totalRepairs = 0,
    this.operatorLevel = 0,
    this.mechanicLevel = 0,
    this.supervisorLevel = 0,
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationsEnabled = false,
    this.doubleIncomeUntil,
    DateTime? lastLogin,
    List<MachineModel>? machines,
    List<MissionModel>? missions,
  })  : lastLogin = lastLogin ?? DateTime.now(),
        machines = machines ??
            MachineCatalog.all
                .map((definition) => MachineModel(id: definition.kind.name))
                .toList(),
        missions = missions ?? defaultMissions();

  double cash;
  int factoryLevel;
  double xp;
  int warehouseLevel;
  int storedParts;
  int salesLevel;
  int totalProduction;
  double totalEarned;
  int totalUpgrades;
  int totalRepairs;
  int operatorLevel;
  int mechanicLevel;
  int supervisorLevel;
  bool musicEnabled;
  bool soundEnabled;
  bool vibrationEnabled;
  bool notificationsEnabled;
  DateTime lastLogin;
  DateTime? doubleIncomeUntil;
  final List<MachineModel> machines;
  final List<MissionModel> missions;

  int get warehouseCapacity =>
      GameConfig.baseWarehouseCapacity + ((warehouseLevel - 1) * 100);

  double get salesPerMinute => 12 + ((salesLevel - 1) * 4);

  double get warehouseUpgradeCost =>
      600 * _pow(GameConfig.warehouseUpgradeGrowth, warehouseLevel - 1);

  double get salesUpgradeCost =>
      450 * _pow(GameConfig.salesUpgradeGrowth, salesLevel - 1);

  double get incomeMultiplier {
    final workerMultiplier = 1 + (supervisorLevel * .05);
    final doubled = doubleIncomeUntil?.isAfter(DateTime.now()) ?? false;
    return workerMultiplier * (doubled ? 2 : 1);
  }

  static double _pow(double base, int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
