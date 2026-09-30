import 'dart:math' as math;

import '../models/player_data.dart';
import '../utils/config.dart';

class OfflineResult {
  const OfflineResult({
    required this.duration,
    required this.earned,
    required this.produced,
  });

  final Duration duration;
  final double earned;
  final int produced;

  bool get hasEarnings => earned > 0 || produced > 0;
}

abstract final class OfflineSystem {
  static OfflineResult calculate(PlayerData data, DateTime now) {
    final rawSeconds = now.difference(data.lastLogin).inSeconds;
    if (rawSeconds < 10) {
      return const OfflineResult(
        duration: Duration.zero,
        earned: 0,
        produced: 0,
      );
    }
    final cappedSeconds = math.min(
      rawSeconds,
      GameConfig.offlineLimitHours * 3600,
    );
    final availableSpace = data.warehouseCapacity - data.storedParts;
    final unlocked = data.machines.where(
      (machine) =>
          machine.definition.unlockLevel <= data.factoryLevel && !machine.isBroken,
    );
    var potential = 0.0;
    var weightedValue = 0.0;
    for (final machine in unlocked) {
      final count = cappedSeconds / machine.productionSeconds;
      potential += count;
      weightedValue += count * machine.productValue;
    }
    if (potential <= 0) {
      return OfflineResult(
        duration: Duration(seconds: cappedSeconds),
        earned: 0,
        produced: 0,
      );
    }
    final canSell = data.salesPerMinute * cappedSeconds / 60;
    final produced = math.min(potential.floor(), availableSpace + canSell.floor());
    final averageValue = weightedValue / potential;
    final sold = math.min(produced + data.storedParts, canSell.floor());
    final remaining = data.storedParts + produced - sold;
    data.storedParts = remaining.clamp(0, data.warehouseCapacity).toInt();
    final earned = sold * averageValue * data.incomeMultiplier;
    return OfflineResult(
      duration: Duration(seconds: cappedSeconds),
      earned: earned,
      produced: produced,
    );
  }
}
