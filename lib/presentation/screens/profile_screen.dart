import 'package:flutter/material.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../../core/social/achievement.dart';
import '../theme/landing_tokens.dart';
import '../theme/league_style.dart';
import '../theme/noir_skin.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';

/// Screen 10 — User Profile & Achievements, in the terminal noir style. A
/// profile card (name, linked GitHub, current league), streak management with
/// a calendar of recent activity and an XP-priced "Streak Freeze" purchase,
/// and a grid of unlocked and locked achievement badges.
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
    final skin = NoirSkin.of(context);

    final profileCard = _ProfileCard(user: user, skin: skin);
    final streakCard = _StreakCard(
      user: user,
      cost: streakFreezeCost,
      skin: skin,
      onBuy: () {
        final ok = onPurchaseStreakFreeze();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? 'Streak Freeze purchased! ($streakFreezeCost XP spent)'
                  : 'Not enough XP for a Streak Freeze ($streakFreezeCost needed).',
            ),
          ),
        );
      },
    );
    final badgesCard = _BadgesCard(user: user, skin: skin);

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1800),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NoirHeader(
                        title: 'Profile',
                        eyebrow: 'Player card',
                        skin: skin,
                        onBack: onBack,
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Wide: identity + streak on the left, the badge wall
                          // on the right, filling the whole width.
                          if (constraints.maxWidth > 900) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      profileCard,
                                      const SizedBox(height: 20),
                                      streakCard,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(child: badgesCard),
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
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;

  const _ProfileCard({required this.user, required this.skin});

  @override
  Widget build(BuildContext context) {
    final tier = Progression(user.xp).tier;
    return NoirPanel(
      skin: skin,
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
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: skin.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.mono(
                        fontSize: 12,
                        color: skin.faint,
                      ),
                    ),
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
            skin: skin,
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: LandingTokens.smallRadius,
                border: Border.all(color: tier.color.withValues(alpha: 0.6)),
                color: tier.color.withValues(alpha: 0.1),
              ),
              child: Text(
                '${tier.label.toUpperCase()} TIER',
                style: LandingTokens.label(fontSize: 9, color: tier.color),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.code,
            iconColor: skin.text,
            label: 'GitHub',
            skin: skin,
            valueWidget: _LinkGitHubButton(skin: skin),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (user.photoUrl != null) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: LandingTokens.smallRadius,
          border: Border.all(color: skin.borderStrong),
          image: DecorationImage(
            image: NetworkImage(user.photoUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        color: LandingTokens.ember,
        borderRadius: LandingTokens.smallRadius,
      ),
      child: const Icon(Icons.person, color: Color(0xFF0A0500), size: 30),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget valueWidget;
  final NoirSkin skin;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valueWidget,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: skin.sub,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        valueWidget,
      ],
    );
  }
}

class _LinkGitHubButton extends StatelessWidget {
  final NoirSkin skin;

  const _LinkGitHubButton({required this.skin});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("GitHub linking isn't configured yet — coming soon."),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: LandingTokens.smallRadius,
            border: Border.all(color: skin.borderStrong),
          ),
          child: Text(
            'NOT LINKED · LINK',
            style: LandingTokens.label(fontSize: 9, color: skin.sub),
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final UserSession user;
  final int cost;
  final NoirSkin skin;
  final VoidCallback onBuy;

  const _StreakCard({
    required this.user,
    required this.cost,
    required this.skin,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return NoirPanel(
      skin: skin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: LandingTokens.ember,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '// CODING STREAK',
                  style: LandingTokens.label(
                    fontSize: 10,
                    color: LandingTokens.ember,
                  ),
                ),
              ),
              Text(
                '${user.streak}-DAY',
                style: LandingTokens.label(fontSize: 10, color: skin.faint),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StreakCalendar(streak: user.streak, skin: skin),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak Freeze',
                      style: TextStyle(
                        color: skin.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'OWNED: ${user.streakFreezes} · PROTECTS A MISSED DAY',
                      maxLines: 2,
                      style: LandingTokens.label(
                        fontSize: 9,
                        color: skin.faint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GradientButton(
                label: '$cost XP',
                icon: Icons.ac_unit,
                onPressed: onBuy,
                compact: true,
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
  final NoirSkin skin;

  const _StreakCalendar({required this.streak, required this.skin});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayCol = today.weekday % 7; // Sun=0 .. Sat=6
    final start = today.subtract(
      Duration(days: todayCol + 21),
    ); // first Sunday, 4 rows total

    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Row(
          children: [
            for (final l in labels)
              Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: LandingTokens.label(fontSize: 10, color: skin.faint),
                  ),
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
                for (var day = 0; day < 7; day++)
                  _cell(start.add(Duration(days: week * 7 + day)), today),
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
                  ? LandingTokens.ember
                  : skin.panelRaised,
              borderRadius: LandingTokens.smallRadius,
              border: Border.all(
                color: isToday ? LandingTokens.ember : skin.border,
                width: isToday ? 1.6 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: isActive
                ? const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Color(0xFF0A0500),
                  )
                : Text(
                    '${date.day}',
                    style: LandingTokens.mono(
                      fontSize: 10,
                      color: isFuture ? skin.faint : skin.sub,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BadgesCard extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;

  const _BadgesCard({required this.user, required this.skin});

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
    'first_steps' => LandingTokens.signal,
    'grid_master' => LandingTokens.circuit,
    'sql_sleuth' => const Color(0xFF9E9CFF),
    'rocket_scientist' => LandingTokens.ember,
    'persistence' => LandingTokens.ember,
    'polyglot' => const Color(0xFFFFD166),
    'high_roller' => LandingTokens.signal,
    'efficiency_expert' => const Color(0xFFFFD166),
    _ => LandingTokens.circuit,
  };

  @override
  Widget build(BuildContext context) {
    final badges = Achievements.forUser(user);
    final unlockedCount = badges.where((b) => b.unlocked).length;

    return NoirPanel(
      skin: skin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium,
                color: LandingTokens.ember,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '// ACHIEVEMENTS',
                  style: LandingTokens.label(
                    fontSize: 10,
                    color: LandingTokens.ember,
                  ),
                ),
              ),
              Text(
                '$unlockedCount / ${badges.length}',
                style: LandingTokens.mono(
                  fontSize: 12,
                  color: skin.sub,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
              const gap = 12.0;
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
                        skin: skin,
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
  final NoirSkin skin;

  const _BadgeTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.unlocked,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked ? skin.panelRaised : skin.panel,
          borderRadius: LandingTokens.smallRadius,
          border: Border.all(
            color: unlocked ? color.withValues(alpha: 0.5) : skin.border,
          ),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (unlocked ? color : skin.faint).withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(
                      color: (unlocked ? color : skin.faint).withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: unlocked ? color : skin.faint,
                    size: 22,
                  ),
                ),
                if (!unlocked)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: skin.borderStrong,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Icon(Icons.lock, size: 11, color: skin.bg),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: skin.text,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.body(fontSize: 10, color: skin.faint),
            ),
          ],
        ),
      ),
    );
  }
}
