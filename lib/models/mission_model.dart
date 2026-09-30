enum MissionType { produce, upgrade, earn, repair }

class MissionModel {
  MissionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.target,
    required this.reward,
    this.progress = 0,
    this.claimed = false,
  });

  final String id;
  final String title;
  final MissionType type;
  final double target;
  final double reward;
  double progress;
  bool claimed;

  bool get isComplete => progress >= target;

  Map<String, Object> toJson() => <String, Object>{
        'id': id,
        'progress': progress,
        'claimed': claimed,
      };
}

List<MissionModel> defaultMissions() => <MissionModel>[
      MissionModel(
        id: 'produce_100',
        title: 'Produce 100 parts',
        type: MissionType.produce,
        target: 100,
        reward: 750,
      ),
      MissionModel(
        id: 'upgrade_5',
        title: 'Upgrade machines 5 times',
        type: MissionType.upgrade,
        target: 5,
        reward: 1200,
      ),
      MissionModel(
        id: 'earn_10000',
        title: 'Earn \$10,000',
        type: MissionType.earn,
        target: 10000,
        reward: 1800,
      ),
      MissionModel(
        id: 'repair_2',
        title: 'Repair 2 machines',
        type: MissionType.repair,
        target: 2,
        reward: 1000,
      ),
    ];
