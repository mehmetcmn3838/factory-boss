import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/machine_model.dart';
import '../models/mission_model.dart';
import '../models/player_data.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import '../utils/config.dart';
import 'economy_system.dart';
import 'offline_system.dart';

class FactoryController extends ChangeNotifier {
  FactoryController({
    SaveService? saveService,
    AudioService? audioService,
    AdService? adService,
    Random? random,
  })  : _saveService = saveService ?? SaveService(),
        _audioService = audioService ?? AudioService(),
        _adService = adService ?? AdService(),
        _random = random ?? Random();

  final SaveService _saveService;
  final AudioService _audioService;
  final AdService _adService;
  final Random _random;
  PlayerData data = PlayerData();
  MachineModel? selectedMachine;
  OfflineResult? offlineResult;
  double _salesAccumulator = 0;
  double _saveAccumulator = 0;

  Future<void> initialize() async {
    data = await _saveService.load();
    offlineResult = OfflineSystem.calculate(data, DateTime.now());
    final result = offlineResult;
    if (result != null && result.hasEarnings) {
      data.cash += result.earned;
      data.totalEarned += result.earned;
      data.totalProduction += result.produced;
      _addMissionProgress(MissionType.earn, result.earned);
      _addMissionProgress(MissionType.produce, result.produced.toDouble());
      _addXp(result.produced * GameConfig.xpPerPart);
    }
    _syncAudio();
    await save();
    notifyListeners();
  }

  void tick(double dt) {
    _salesAccumulator += dt * data.salesPerMinute / 60;
    final requested = _salesAccumulator.floor();
    if (requested > 0 && data.storedParts > 0) {
      final sold = min(requested, data.storedParts);
      _salesAccumulator -= sold;
      data.storedParts -= sold;
      final earned = sold * averageProductValue * data.incomeMultiplier;
      data.cash += earned;
      data.totalEarned += earned;
      _addMissionProgress(MissionType.earn, earned);
      unawaited(_audioService.playCoin());
      notifyListeners();
    }

    _saveAccumulator += dt;
    if (_saveAccumulator >= GameConfig.autosaveSeconds) {
      _saveAccumulator = 0;
      unawaited(save());
    }
  }

  double get averageProductValue {
    final unlocked = data.machines.where(isUnlocked).toList();
    if (unlocked.isEmpty) {
      return 10;
    }
    return unlocked
            .map((machine) => machine.productValue)
            .reduce((a, b) => a + b) /
        unlocked.length;
  }

  bool isUnlocked(MachineModel machine) =>
      data.factoryLevel >= machine.definition.unlockLevel;

  bool get warehouseHasSpace =>
      data.storedParts < data.warehouseCapacity;

  double get productionSpeedMultiplier => 1 + (data.operatorLevel * .05);

  bool completeProduction(MachineModel machine) {
    if (!isUnlocked(machine) || machine.isBroken || !warehouseHasSpace) {
      return false;
    }
    const produced = 1;
    final actual = min(produced, data.warehouseCapacity - data.storedParts);
    data.storedParts += actual;
    data.totalProduction += actual;
    _addXp(actual * GameConfig.xpPerPart);
    _addMissionProgress(MissionType.produce, actual.toDouble());

    final mechanicReduction =
        (1 - data.mechanicLevel * .1).clamp(.3, 1.0).toDouble();
    final failureChance = (1 - machine.reliability) * .04 * mechanicReduction;
    if (_random.nextDouble() < failureChance) {
      machine.isBroken = true;
      unawaited(_audioService.playFailure());
    }
    notifyListeners();
    return true;
  }

  void selectMachine(MachineModel machine) {
    selectedMachine = machine;
    notifyListeners();
  }

  void closeMachinePanel() {
    selectedMachine = null;
    notifyListeners();
  }

  bool upgradeMachine(MachineModel machine) {
    final cost = machine.upgradeCost;
    if (!EconomySystem.canAfford(data.cash, cost) || !isUnlocked(machine)) {
      return false;
    }
    data.cash -= cost;
    machine.level++;
    data.totalUpgrades++;
    _addXp(GameConfig.xpPerUpgrade);
    _addMissionProgress(MissionType.upgrade, 1);
    unawaited(_audioService.playUpgrade());
    unawaited(save());
    notifyListeners();
    return true;
  }

  bool repairMachine(MachineModel machine, {bool free = false}) {
    if (!machine.isBroken) {
      return true;
    }
    if (!free && !EconomySystem.canAfford(data.cash, machine.repairCost)) {
      return false;
    }
    if (!free) {
      data.cash -= machine.repairCost;
    }
    machine.isBroken = false;
    data.totalRepairs++;
    _addMissionProgress(MissionType.repair, 1);
    unawaited(save());
    notifyListeners();
    return true;
  }

  bool upgradeWarehouse() {
    final cost = data.warehouseUpgradeCost;
    if (!EconomySystem.canAfford(data.cash, cost)) {
      return false;
    }
    data.cash -= cost;
    data.warehouseLevel++;
    _addXp(25);
    unawaited(save());
    notifyListeners();
    return true;
  }

  bool upgradeSales() {
    final cost = data.salesUpgradeCost;
    if (!EconomySystem.canAfford(data.cash, cost)) {
      return false;
    }
    data.cash -= cost;
    data.salesLevel++;
    _addXp(25);
    unawaited(save());
    notifyListeners();
    return true;
  }

  bool buyWorker(String type) {
    final currentLevel = switch (type) {
      'operator' => data.operatorLevel,
      'mechanic' => data.mechanicLevel,
      _ => data.supervisorLevel,
    };
    final cost = 1200 * (1 + currentLevel * .8);
    if (!EconomySystem.canAfford(data.cash, cost)) {
      return false;
    }
    data.cash -= cost;
    if (type == 'operator') {
      data.operatorLevel++;
    } else if (type == 'mechanic') {
      data.mechanicLevel++;
    } else {
      data.supervisorLevel++;
    }
    notifyListeners();
    unawaited(save());
    return true;
  }

  void claimMission(MissionModel mission) {
    if (!mission.isComplete || mission.claimed) {
      return;
    }
    mission.claimed = true;
    data.cash += mission.reward;
    notifyListeners();
    unawaited(save());
  }

  Future<bool> activateDoubleIncome() async {
    if (!await _adService.showRewarded(RewardedAdReward.doubleIncome)) {
      return false;
    }
    data.doubleIncomeUntil = DateTime.now().add(const Duration(minutes: 10));
    notifyListeners();
    await save();
    return true;
  }

  Future<bool> rewardedRepair(MachineModel machine) async {
    if (!await _adService.showRewarded(RewardedAdReward.freeRepair)) {
      return false;
    }
    return repairMachine(machine, free: true);
  }

  void updateSetting(String setting, bool value) {
    if (setting == 'music') {
      data.musicEnabled = value;
    } else if (setting == 'sound') {
      data.soundEnabled = value;
    } else if (setting == 'vibration') {
      data.vibrationEnabled = value;
    } else if (setting == 'notifications') {
      data.notificationsEnabled = value;
    }
    _syncAudio();
    notifyListeners();
    unawaited(save());
  }

  Future<void> resetProgress() async {
    await _saveService.reset();
    data = PlayerData();
    selectedMachine = null;
    offlineResult = null;
    await save();
    notifyListeners();
  }

  Future<void> save() => _saveService.save(data);

  void _syncAudio() {
    _audioService.musicEnabled = data.musicEnabled;
    _audioService.soundEnabled = data.soundEnabled;
  }

  void _addMissionProgress(MissionType type, double amount) {
    for (final mission in data.missions.where((item) => item.type == type)) {
      if (!mission.claimed) {
        mission.progress = min(mission.target, mission.progress + amount);
      }
    }
  }

  void _addXp(double amount) {
    data.xp += amount;
    var needed = GameConfig.xpForLevel(data.factoryLevel).toDouble();
    while (data.xp >= needed) {
      data.xp -= needed;
      data.factoryLevel++;
      needed = GameConfig.xpForLevel(data.factoryLevel).toDouble();
    }
  }

  @override
  void dispose() {
    unawaited(save());
    unawaited(_audioService.dispose());
    super.dispose();
  }
}
