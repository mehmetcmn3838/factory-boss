import 'package:flutter/material.dart';

import '../models/achievement_model.dart';
import '../systems/economy_system.dart';
import '../systems/factory_controller.dart';
import '../theme/app_theme.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({required this.controller, super.key});

  final FactoryController controller;

  @override
  Widget build(BuildContext context) {
    return _PanelScaffold(
      title: 'MISSIONS',
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: controller.data.missions.length + 1,
        itemBuilder: (context, index) {
          if (index == controller.data.missions.length) {
            final achievements = achievementsFor(controller.data);
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 22, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACHIEVEMENTS',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...achievements.map(
                    (achievement) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        achievement.unlocked
                            ? Icons.emoji_events_rounded
                            : Icons.lock_outline_rounded,
                        color: achievement.unlocked
                            ? AppTheme.accent
                            : Colors.white38,
                      ),
                      title: Text(achievement.title),
                      subtitle: Text(achievement.description),
                      trailing: achievement.unlocked
                          ? const Icon(Icons.check_circle, color: AppTheme.success)
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }
          final mission = controller.data.missions[index];
          final progress = (mission.progress / mission.target)
              .clamp(0.0, 1.0)
              .toDouble();
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mission.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(EconomySystem.compactMoney(mission.reward)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    color: mission.isComplete
                        ? AppTheme.success
                        : AppTheme.accent,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${mission.progress.floor()} / ${mission.target.floor()}',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const Spacer(),
                      if (mission.claimed)
                        const Text(
                          'CLAIMED',
                          style: TextStyle(color: AppTheme.success),
                        )
                      else
                        FilledButton.tonal(
                          onPressed: mission.isComplete
                              ? () => controller.claimMission(mission)
                              : null,
                          child: const Text('CLAIM'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PanelScaffold extends StatelessWidget {
  const _PanelScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
