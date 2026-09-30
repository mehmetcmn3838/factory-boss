import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/machine_model.dart';
import '../models/mission_model.dart';
import '../models/player_data.dart';

class SaveService {
  static const _saveKey = 'factory_boss_save_v1';

  Future<PlayerData> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_saveKey);
    if (raw == null) {
      return PlayerData();
    }

    try {
      final json = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final machineJson = (json['machines'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => MachineModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
      final machines = PlayerData().machines;
      for (final saved in machineJson) {
        final index = machines.indexWhere((machine) => machine.id == saved.id);
        if (index >= 0) {
          machines[index] = saved;
        }
      }

      final missions = defaultMissions();
      final missionJson = json['missions'] as List<dynamic>? ?? <dynamic>[];
      for (final item in missionJson) {
        final saved = Map<String, dynamic>.from(item as Map);
        final index = missions.indexWhere((mission) => mission.id == saved['id']);
        if (index >= 0) {
          missions[index].progress =
              (saved['progress'] as num?)?.toDouble() ?? 0;
          missions[index].claimed = saved['claimed'] as bool? ?? false;
        }
      }

      return PlayerData(
        cash: (json['cash'] as num?)?.toDouble() ?? 500,
        factoryLevel: json['factoryLevel'] as int? ?? 1,
        xp: (json['xp'] as num?)?.toDouble() ?? 0,
        warehouseLevel: json['warehouseLevel'] as int? ?? 1,
        storedParts: json['storedParts'] as int? ?? 0,
        salesLevel: json['salesLevel'] as int? ?? 1,
        totalProduction: json['totalProduction'] as int? ?? 0,
        totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0,
        totalUpgrades: json['totalUpgrades'] as int? ?? 0,
        totalRepairs: json['totalRepairs'] as int? ?? 0,
        operatorLevel: json['operatorLevel'] as int? ?? 0,
        mechanicLevel: json['mechanicLevel'] as int? ?? 0,
        supervisorLevel: json['supervisorLevel'] as int? ?? 0,
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
        notificationsEnabled:
            json['notificationsEnabled'] as bool? ?? false,
        lastLogin: DateTime.tryParse(json['lastLogin'] as String? ?? '') ??
            DateTime.now(),
        doubleIncomeUntil:
            DateTime.tryParse(json['doubleIncomeUntil'] as String? ?? ''),
        machines: machines,
        missions: missions,
      );
    } catch (_) {
      return PlayerData();
    }
  }

  Future<void> save(PlayerData data) async {
    data.lastLogin = DateTime.now();
    final payload = <String, Object?>{
      'cash': data.cash,
      'factoryLevel': data.factoryLevel,
      'xp': data.xp,
      'warehouseLevel': data.warehouseLevel,
      'storedParts': data.storedParts,
      'salesLevel': data.salesLevel,
      'totalProduction': data.totalProduction,
      'totalEarned': data.totalEarned,
      'totalUpgrades': data.totalUpgrades,
      'totalRepairs': data.totalRepairs,
      'operatorLevel': data.operatorLevel,
      'mechanicLevel': data.mechanicLevel,
      'supervisorLevel': data.supervisorLevel,
      'musicEnabled': data.musicEnabled,
      'soundEnabled': data.soundEnabled,
      'vibrationEnabled': data.vibrationEnabled,
      'notificationsEnabled': data.notificationsEnabled,
      'lastLogin': data.lastLogin.toIso8601String(),
      'doubleIncomeUntil': data.doubleIncomeUntil?.toIso8601String(),
      'machines': data.machines.map((machine) => machine.toJson()).toList(),
      'missions': data.missions.map((mission) => mission.toJson()).toList(),
    };
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_saveKey, jsonEncode(payload));
  }

  Future<void> reset() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_saveKey);
  }
}
