import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_type.dart';
import '../theme/doodle.dart';

class ModuleCard extends StatelessWidget {
  final CurriculumModule module;
  final bool isCompleted;
  final VoidCallback onLaunch;

  const ModuleCard({
    super.key,
    required this.module,
    required this.isCompleted,
    required this.onLaunch,
  });

  IconData get _icon => switch (module.type) {
        ModuleType.logicGrid => Icons.videogame_asset,
        ModuleType.sqlTerminal => Icons.storage,
        ModuleType.rocketFlight => Icons.rocket_launch,
      };

  Color get _accent => switch (module.type) {
        ModuleType.logicGrid => DoodlePalette.blue,
        ModuleType.sqlTerminal => DoodlePalette.purple,
        ModuleType.rocketFlight => DoodlePalette.orange,
      };

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DoodleIconBadge(icon: _icon, color: _accent, size: 48, iconSize: 24, borderRadius: 14),
              if (isCompleted) const DoodlePill(text: 'Cleared', background: DoodlePalette.green),
            ],
          ),
          const SizedBox(height: 14),
          Text(module.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            module.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.black),
                  const SizedBox(width: 4),
                  Text('+${module.xpReward} XP', style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
              DoodleButton(
                key: Key('launch-${module.id}'),
                label: 'Launch',
                color: DoodlePalette.green,
                onPressed: onLaunch,
                icon: Icons.play_circle,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
