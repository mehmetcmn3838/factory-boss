import 'player_data.dart';

class AchievementModel {
  const AchievementModel({
    required this.title,
    required this.description,
    required this.unlocked,
  });

  final String title;
  final String description;
  final bool unlocked;
}

List<AchievementModel> achievementsFor(PlayerData data) => <AchievementModel>[
      AchievementModel(
        title: 'First Upgrade',
        description: 'Upgrade any machine once.',
        unlocked: data.totalUpgrades >= 1,
      ),
      AchievementModel(
        title: '1,000 Parts Produced',
        description: 'Keep the production lines moving.',
        unlocked: data.totalProduction >= 1000,
      ),
      AchievementModel(
        title: 'Factory Level 10',
        description: 'Grow into an industrial operation.',
        unlocked: data.factoryLevel >= 10,
      ),
      AchievementModel(
        title: 'Millionaire',
        description: 'Earn a total of \$1,000,000.',
        unlocked: data.totalEarned >= 1000000,
      ),
    ];
