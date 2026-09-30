import '../models/machine_model.dart';

abstract final class EconomySystem {
  static bool canAfford(double cash, double cost) => cash + .0001 >= cost;

  static double productionValue(MachineModel machine, double multiplier) =>
      machine.productValue * multiplier;

  static String compactMoney(double amount) {
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(2)}B';
    }
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(2)}K';
    }
    return '\$${amount.toStringAsFixed(amount >= 100 ? 0 : 2)}';
  }
}
