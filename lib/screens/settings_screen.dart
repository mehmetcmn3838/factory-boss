import 'package:flutter/material.dart';

import '../systems/factory_controller.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, super.key});

  final FactoryController controller;

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('Cash, upgrades and all factory progress will be erased.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.resetProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    return Material(
      color: AppTheme.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 28),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'SETTINGS',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Music'),
            secondary: const Icon(Icons.music_note_rounded),
            value: data.musicEnabled,
            onChanged: (value) => controller.updateSetting('music', value),
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            secondary: const Icon(Icons.volume_up_rounded),
            value: data.soundEnabled,
            onChanged: (value) => controller.updateSetting('sound', value),
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            secondary: const Icon(Icons.vibration_rounded),
            value: data.vibrationEnabled,
            onChanged: (value) => controller.updateSetting('vibration', value),
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Placeholder for a future release'),
            secondary: const Icon(Icons.notifications_rounded),
            value: data.notificationsEnabled,
            onChanged: (value) => controller.updateSetting('notifications', value),
          ),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About'),
            subtitle: const Text('Factory Boss • MVP 1.0.0\nFlutter + Flame'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _reset(context),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('RESET PROGRESS'),
          ),
        ],
      ),
    );
  }
}
