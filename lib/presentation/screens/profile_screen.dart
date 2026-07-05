import 'package:flutter/material.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../../core/social/achievement.dart';
import '../theme/doodle.dart';
import '../theme/league_style.dart';

/// Screen 10 — User Profile & Achievements. A profile card (name, linked
/// GitHub, current league), streak management with a calendar of recent
/// activity and an XP-priced "Streak Freeze" purchase, and a grid of unlocked
/// and locked achievement badges.
class ProfileScreen extends StatelessWidget {
  final UserSession user;

  /// Attempts to buy a Streak Freeze with XP; returns whether it succeeded
  /// (false when the player can't afford it). Implemented by the orchestrator
  /// so it can mutate the shared session.
  final bool Function() onPurchaseStreakFreeze;
  final VoidCallback onBack;

  static const int streakFreezeCost = 200;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onPurchaseStreakFreeze,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? DoodlePalette.dark : DoodlePalette.cream;

    final profileCard = _ProfileCard(user: user);
    final streakCard = _StreakCard(
      user: user,
      cost: streakFreezeCost,
      onBuy: () {
        final ok = onPurchaseStreakFreeze();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'Streak Freeze purchased! ($streakFreezeCost XP spent)'
                : 'Not enough XP for a Streak Freeze ($streakFreezeCost needed).'),
          ),
        );
      },
    );
    final badgesCard = _BadgesCard(user: user);

    return Scaffold(
      backgroundColor: bg,
      body: DoodleDotBackground(
        backgroundColor: bg,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(title: 'Profile', onBack: onBack),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Wide: identity + streak on the left, the badge wall
                        // on the right, filling the whole width.
                        if (constraints.maxWidth > 900) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [profileCard, const SizedBox(height: 20), streakCard],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(flex: 1, child: badgesCard),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            profileCard,
                            const SizedBox(height: 16),
                            streakCard,
                            const SizedBox(height: 16),
                            badgesCard,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const DoodleIconBadge(
              icon: Icons.arrow_back,
              color: DoodlePalette.white,
              iconColor: Colors.black,
              size: 40,
              iconSize: 20,
              borderRadius: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserSession user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final tier = Progression(user.xp).tier;
    return DoodleCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _avatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.emoji_events,
            iconColor: tier.color,
            label: 'Current League',
            valueWidget: DoodlePill(text: '${tier.label} Tier', background: tier.color),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.code,
            iconColor: Colors.black,
            label: 'GitHub',
            valueWidget: _LinkGitHubButton(),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (user.photoUrl != null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3),
          image: DecorationImage(image: NetworkImage(user.photoUrl!), fit: BoxFit.cover),
        ),
      );
    }
    return const DoodleIconBadge(icon: Icons.person, color: DoodlePalette.blue, size: 60, iconSize: 30, borderRadius: 16);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget valueWidget;

  const _InfoRow({required this.icon, required this.iconColor, required this.label, required this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 13)),
        ),
        valueWidget,
      ],
    );
  }
}

class _LinkGitHubButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("GitHub linking isn't configured yet — coming soon.")),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: DoodlePalette.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: const Text('Not linked · Link',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final UserSession user;
  final int cost;
  final VoidCallback onBuy;

  const _StreakCard({required this.user, required this.cost, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final canAfford = user.xp >= cost;
    return DoodleCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: DoodlePalette.red, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Coding Streak',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              Text('${user.streak}-day streak',
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          _StreakCalendar(streak: user.streak),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Streak Freeze',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('Owned: ${user.streakFreezes}  ·  Protects a missed day',
                        maxLines: 2,
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              DoodleButton(
                label: '$cost XP',
                color: canAfford ? DoodlePalette.yellow : const Color(0xFFE0E0E0),
                icon: Icons.ac_unit,
                onPressed: onBuy,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Four-week calendar aligned to weekday columns, with the most recent
/// [streak] days lit as active. Today is outlined.
class _StreakCalendar extends StatelessWidget {
  final int streak;
  const _StreakCalendar({required this.streak});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayCol = today.weekday % 7; // Sun=0 .. Sat=6
    final start = today.subtract(Duration(days: todayCol + 21)); // first Sunday, 4 rows total

    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Row(
          children: [
            for (final l in labels)
              Expanded(
                child: Center(
                  child: Text(l, style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w800, fontSize: 11)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var week = 0; week < 4; week++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                for (var day = 0; day < 7; day++) _cell(start.add(Duration(days: week * 7 + day)), today),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(DateTime date, DateTime today) {
    final isFuture = date.isAfter(today);
    final diff = today.difference(date).inDays;
    final isActive = !isFuture && diff >= 0 && diff < streak;
    final isToday = diff == 0;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: isFuture
                  ? Colors.transparent
                  : isActive
                      ? DoodlePalette.orange
                      : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isToday ? Colors.black : Colors.black26, width: isToday ? 3 : 1.5),
            ),
            alignment: Alignment.center,
            child: isActive
                ? const Icon(Icons.local_fire_department, size: 14, color: Colors.black)
                : Text('${date.day}',
                    style: TextStyle(
                      color: isFuture ? Colors.black26 : Colors.black54,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    )),
          ),
        ),
      ),
    );
  }
}

class _BadgesCard extends StatelessWidget {
  final UserSession user;
  const _BadgesCard({required this.user});

  IconData _iconFor(String id) => switch (id) {
        'first_steps' => Icons.flag,
        'grid_master' => Icons.grid_view,
        'sql_sleuth' => Icons.storage,
        'rocket_scientist' => Icons.rocket_launch,
        'persistence' => Icons.local_fire_department,
        'polyglot' => Icons.translate,
        'high_roller' => Icons.savings,
        'efficiency_expert' => Icons.bolt,
        _ => Icons.emoji_events,
      };

  Color _colorFor(String id) => switch (id) {
        'first_steps' => DoodlePalette.green,
        'grid_master' => DoodlePalette.blue,
        'sql_sleuth' => DoodlePalette.purple,
        'rocket_scientist' => DoodlePalette.orange,
        'persistence' => DoodlePalette.red,
        'polyglot' => DoodlePalette.yellow,
        'high_roller' => DoodlePalette.green,
        'efficiency_expert' => DoodlePalette.yellow,
        _ => DoodlePalette.blue,
      };

  @override
  Widget build(BuildContext context) {
    final badges = Achievements.forUser(user);
    final unlockedCount = badges.where((b) => b.unlocked).length;

    return DoodleCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Achievements',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              Text('$unlockedCount / ${badges.length}',
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 720
                  ? 4
                  : constraints.maxWidth > 380
                      ? 3
                      : 2;
              final gap = 12.0;
              final tileW = (constraints.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final b in badges)
                    SizedBox(
                      width: tileW,
                      child: _BadgeTile(
                        icon: _iconFor(b.id),
                        color: _colorFor(b.id),
                        title: b.title,
                        description: b.description,
                        unlocked: b.unlocked,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool unlocked;

  const _BadgeTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked ? DoodlePalette.white : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                DoodleIconBadge(
                  icon: icon,
                  color: unlocked ? color : const Color(0xFFBDBDBD),
                  size: 44,
                  iconSize: 22,
                  borderRadius: 12,
                ),
                if (!unlocked)
                  const Positioned(
                    right: -2,
                    bottom: -2,
                    child: CircleAvatar(radius: 9, backgroundColor: Colors.black, child: Icon(Icons.lock, size: 11, color: Colors.white)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 2),
            Text(description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 10, height: 1.2)),
          ],
        ),
      ),
    );
  }
}
