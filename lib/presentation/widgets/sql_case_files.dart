import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/session/user_session.dart';

class SqlCaseFiles extends StatelessWidget {
  final List<CurriculumModule> modules;
  final UserSession user;
  final void Function(CurriculumModule module) onLaunchModule;
  const SqlCaseFiles({
    super.key,
    required this.modules,
    required this.user,
    required this.onLaunchModule,
  });

  static const names = [
    'The Vanishing Briefcase',
    'The Stolen Sound',
    'The Miami Marina Murder',
    'The Vanishing Diamond',
    'The Silicon Sabotage',
  ];
  static const descriptions = [
    'A briefcase containing sensitive documents has vanished. Follow the clues to identify the thief.',
    'A prized vinyl record has been stolen from West Hollywood Records. Follow the clues to uncover the culprit.',
    'A body was found at Coral Bay Marina. Find the murderer and bring them to justice.',
    'The famous diamond disappeared from its display at the charity gala.',
    "Miami's leading tech corporation was about to unveil a groundbreaking prototype. Then it was destroyed.",
  ];

  @override
  Widget build(BuildContext context) {
    final ordered = [...modules]
      ..sort((a, b) => a.trackOrder.compareTo(b.trackOrder));
    final sections = {
      'Beginner': ordered.take(2).toList(),
      'Intermediate': ordered.skip(2).take(1).toList(),
      'Advanced': ordered.skip(3).toList(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Case Files',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 30,
            color: Color(0xFF693117),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 22),
        for (final entry in sections.entries) ...[
          _SectionTitle(entry.key, entry.key == 'Advanced'),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 560
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entry.value.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  mainAxisExtent: 234,
                ),
                itemBuilder: (context, index) {
                  final module = entry.value[index];
                  final number = ordered.indexOf(module);
                  final locked = entry.key == 'Advanced';
                  return _CaseCard(
                    title: names[number % names.length],
                    description: descriptions[number % descriptions.length],
                    xp: module.xpReward,
                    locked: locked,
                    completed: user.completedModuleIds.contains(module.id),
                    onTap: locked ? null : () => onLaunchModule(module),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final bool locked;
  const _SectionTitle(this.label, this.locked);
  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    runSpacing: 4,
    children: [
      Icon(
        locked ? Icons.workspace_premium_outlined : Icons.search,
        color: const Color(0xFFB34B16),
        size: 21,
      ),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Georgia',
          color: Color(0xFF9A3F13),
          fontSize: 20,
        ),
      ),
      if (locked) ...[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock_outline, color: Color(0xFFB34B16), size: 15),
            SizedBox(width: 4),
            Text(
              'License Required',
              style: TextStyle(
                fontFamily: 'Georgia',
                color: Color(0xFFB34B16),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

class _CaseCard extends StatelessWidget {
  final String title, description;
  final int xp;
  final bool locked, completed;
  final VoidCallback? onTap;
  const _CaseCard({
    required this.title,
    required this.description,
    required this.xp,
    required this.locked,
    required this.completed,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: locked ? .58 : 1,
    child: InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 22, 20, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEA),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE5D6B4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1C70431E),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                height: 1.18,
                color: Color(0xFF843710),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFAA4A25),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  color: const Color(0xFFFFF0BD),
                  child: Text(
                    'XP: $xp',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF5E401E),
                    ),
                  ),
                ),
                const Spacer(),
                if (completed)
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF55833B),
                    size: 20,
                  ),
                if (locked)
                  const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF9A542C),
                    size: 19,
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
