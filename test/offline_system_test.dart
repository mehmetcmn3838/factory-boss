import 'package:factory_boss/models/player_data.dart';
import 'package:factory_boss/systems/offline_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offline progress is capped at four hours', () {
    final now = DateTime(2026, 1, 2, 12);
    final data = PlayerData(lastLogin: now.subtract(const Duration(hours: 12)));

    final result = OfflineSystem.calculate(data, now);

    expect(result.duration, const Duration(hours: 4));
    expect(result.produced, greaterThan(0));
    expect(result.earned, greaterThan(0));
  });

  test('very short absence is ignored', () {
    final now = DateTime(2026, 1, 2, 12);
    final data = PlayerData(lastLogin: now.subtract(const Duration(seconds: 3)));

    final result = OfflineSystem.calculate(data, now);

    expect(result.hasEarnings, isFalse);
  });
}
