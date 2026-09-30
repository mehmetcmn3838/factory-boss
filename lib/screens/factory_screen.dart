import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/factory_game.dart';
import '../models/machine_model.dart';
import '../systems/economy_system.dart';
import '../systems/factory_controller.dart';
import '../theme/app_theme.dart';
import '../utils/config.dart';
import 'missions_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'upgrades_screen.dart';

class FactoryScreen extends StatefulWidget {
  const FactoryScreen({required this.controller, super.key});

  final FactoryController controller;

  @override
  State<FactoryScreen> createState() => _FactoryScreenState();
}

class _FactoryScreenState extends State<FactoryScreen>
    with WidgetsBindingObserver {
  late final FactoryGame _game;
  int _tab = 0;
  bool _offlineShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = FactoryGame(widget.controller);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOfflineEarnings());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(widget.controller.save());
    }
  }

  Future<void> _showOfflineEarnings() async {
    final result = widget.controller.offlineResult;
    if (_offlineShown || result == null || !result.hasEarnings || !mounted) {
      return;
    }
    _offlineShown = true;
    final hours = result.duration.inHours;
    final minutes = result.duration.inMinutes.remainder(60);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.factory_rounded, color: AppTheme.accent, size: 42),
        title: const Text('WELCOME BACK'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your factory earned'),
            const SizedBox(height: 8),
            Text(
              EconomySystem.compactMoney(result.earned),
              style: const TextStyle(
                color: AppTheme.success,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text('${result.produced} parts in ${hours}h ${minutes}m'),
            const SizedBox(height: 8),
            const Text(
              'Offline progress is capped at 4 hours.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('COLLECT'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.controller.save());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(controller: widget.controller),
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: [
                      Stack(
                        children: [
                          Positioned.fill(child: GameWidget(game: _game)),
                          if (widget.controller.selectedMachine != null)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: _MachinePanel(
                                controller: widget.controller,
                                machine: widget.controller.selectedMachine!,
                              ),
                            ),
                        ],
                      ),
                      UpgradesScreen(controller: widget.controller),
                      MissionsScreen(controller: widget.controller),
                      ShopScreen(controller: widget.controller),
                      SettingsScreen(controller: widget.controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            height: 67,
            selectedIndex: _tab,
            onDestinationSelected: (index) {
              widget.controller.closeMachinePanel();
              setState(() => _tab = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.factory_outlined),
                selectedIcon: Icon(Icons.factory_rounded),
                label: 'Factory',
              ),
              NavigationDestination(
                icon: Icon(Icons.upgrade_outlined),
                selectedIcon: Icon(Icons.upgrade_rounded),
                label: 'Upgrades',
              ),
              NavigationDestination(
                icon: Icon(Icons.task_alt_outlined),
                selectedIcon: Icon(Icons.task_alt_rounded),
                label: 'Missions',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final FactoryController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    final needed = GameConfig.xpForLevel(data.factoryLevel);
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.panel,
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FACTORY LEVEL ${data.factoryLevel}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (data.xp / needed).clamp(0.0, 1.0).toDouble(),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.accent,
                ),
                const SizedBox(height: 3),
                Text(
                  '${data.xp.floor()} / $needed XP',
                  style: const TextStyle(fontSize: 10, color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('CASH', style: TextStyle(fontSize: 10, color: Colors.white60)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: Text(
                  EconomySystem.compactMoney(data.cash),
                  key: ValueKey(data.cash.floor()),
                  style: const TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.diamond_outlined, color: Color(0xFF6BB8D4), size: 20),
              Text('0', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MachinePanel extends StatelessWidget {
  const _MachinePanel({required this.controller, required this.machine});

  final FactoryController controller;
  final MachineModel machine;

  void _showFailed(BuildContext context, bool success) {
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough cash.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = controller.isUnlocked(machine);
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 14),
      decoration: BoxDecoration(
        color: AppTheme.panel.withAlpha(250),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: machine.isBroken ? AppTheme.danger : AppTheme.panelLight,
          width: 2,
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 14)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  machine.definition.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
              ),
              IconButton(
                onPressed: controller.closeMachinePanel,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          if (!unlocked)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'UNLOCKS AT FACTORY LEVEL ${machine.definition.unlockLevel}',
                style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w800),
              ),
            )
          else ...[
            if (machine.isBroken)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '⚠ MACHINE FAILURE',
                  style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w900),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(label: 'LEVEL', value: '${machine.level}'),
                _Stat(label: 'SPEED', value: '${machine.partsPerMinute.toStringAsFixed(1)}/m'),
                _Stat(label: 'INCOME', value: EconomySystem.compactMoney(machine.productValue)),
                _Stat(label: 'RELIABILITY', value: '${(machine.reliability * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 12),
            if (machine.isBroken)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showFailed(
                        context,
                        controller.repairMachine(machine),
                      ),
                      icon: const Icon(Icons.build_rounded),
                      label: Text('REPAIR ${EconomySystem.compactMoney(machine.repairCost)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Free repair (mock rewarded ad)',
                    onPressed: () => controller.rewardedRepair(machine),
                    icon: const Icon(Icons.play_circle_fill_rounded),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showFailed(
                    context,
                    controller.upgradeMachine(machine),
                  ),
                  icon: const Icon(Icons.upgrade_rounded),
                  label: Text(
                    'UPGRADE  ${EconomySystem.compactMoney(machine.upgradeCost)}',
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.white54)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      );
}
