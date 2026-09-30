import 'package:flutter/material.dart';

import '../systems/economy_system.dart';
import '../systems/factory_controller.dart';
import '../theme/app_theme.dart';

class UpgradesScreen extends StatelessWidget {
  const UpgradesScreen({required this.controller, super.key});

  final FactoryController controller;

  void _result(BuildContext context, bool success) {
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough cash.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    return Material(
      color: AppTheme.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
        children: [
          const Text(
            'FACTORY UPGRADES',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _UpgradeCard(
            icon: Icons.warehouse_rounded,
            title: 'Warehouse Level ${data.warehouseLevel}',
            detail: 'Capacity: ${data.warehouseCapacity} parts',
            cost: data.warehouseUpgradeCost,
            onPressed: () => _result(context, controller.upgradeWarehouse()),
          ),
          _UpgradeCard(
            icon: Icons.local_shipping_rounded,
            title: 'Sales Level ${data.salesLevel}',
            detail: 'Sell speed: ${data.salesPerMinute.toStringAsFixed(0)} items/min',
            cost: data.salesUpgradeCost,
            onPressed: () => _result(context, controller.upgradeSales()),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 20, 4, 6),
            child: Text(
              'WORKERS',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white70),
            ),
          ),
          _WorkerCard(
            title: 'Operator',
            level: data.operatorLevel,
            bonus: 'Production +5% per level',
            onPressed: () => _result(context, controller.buyWorker('operator')),
          ),
          _WorkerCard(
            title: 'Mechanic',
            level: data.mechanicLevel,
            bonus: 'Failure chance -10% per level',
            onPressed: () => _result(context, controller.buyWorker('mechanic')),
          ),
          _WorkerCard(
            title: 'Supervisor',
            level: data.supervisorLevel,
            bonus: 'Factory income +5% per level',
            onPressed: () => _result(context, controller.buyWorker('supervisor')),
          ),
        ],
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.cost,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String detail;
  final double cost;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: AppTheme.accent, size: 32),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(detail),
          trailing: FilledButton(
            onPressed: onPressed,
            child: Text(EconomySystem.compactMoney(cost)),
          ),
        ),
      );
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({
    required this.title,
    required this.level,
    required this.bonus,
    required this.onPressed,
  });

  final String title;
  final int level;
  final String bonus;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cost = 1200 * (1 + level * .8);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.engineering_rounded, color: AppTheme.accent),
        title: Text('$title • Lv $level'),
        subtitle: Text(bonus),
        trailing: FilledButton.tonal(
          onPressed: onPressed,
          child: Text(EconomySystem.compactMoney(cost)),
        ),
      ),
    );
  }
}
