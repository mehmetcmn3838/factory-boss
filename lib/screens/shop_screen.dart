import 'package:flutter/material.dart';

import '../systems/factory_controller.dart';
import '../theme/app_theme.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({required this.controller, super.key});

  final FactoryController controller;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _loading = false;

  Future<void> _activate() async {
    setState(() => _loading = true);
    final success = await widget.controller.activateDoubleIncome();
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '2x income activated for 10 minutes.'
            : 'Reward could not be loaded.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.controller.data.doubleIncomeUntil
            ?.isAfter(DateTime.now()) ??
        false;
    return Material(
      color: AppTheme.background,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'SHOP',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppTheme.accent, size: 52),
                  const Text(
                    '2x FACTORY INCOME',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mock rewarded ad • lasts 10 minutes\nNo forced advertisements.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: active || _loading ? null : _activate,
                    icon: _loading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_circle_fill_rounded),
                    label: Text(active ? 'ACTIVE' : 'WATCH AD'),
                  ),
                ],
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.workspace_premium_rounded),
              title: Text('Premium upgrades'),
              subtitle: Text('Remove Ads, +10% Income and Starter Pack are ready for a future release.'),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
