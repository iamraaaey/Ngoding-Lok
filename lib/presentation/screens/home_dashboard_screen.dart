import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../theme/doodle.dart';
import '../theme/league_style.dart';

/// Screen 4 — the Home Dashboard ("The Hub"). Surfaces the player's identity
/// and momentum at a glance (avatar, level/XP, daily streak), a one-tap
/// "Resume Playing" hero that jumps straight to their next unfinished puzzle,
/// a league-tier tracker with a progress bar to the next rank, and quick links
/// to the full level map and the leaderboard.
class HomeDashboardScreen extends StatefulWidget {
  final UserSession user;

  /// The next puzzle to resume, or null when every level is cleared.
  final CurriculumModule? nextModule;

  final void Function(CurriculumModule module) onResume;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenCodeGolf;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;

  const HomeDashboardScreen({
    super.key,
    required this.user,
    required this.nextModule,
    required this.onResume,
    required this.onOpenMap,
    required this.onOpenCodeGolf,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onLogout,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) =>
      CurvedAnimation(parent: _entrance, curve: Interval(begin, end, curve: Curves.easeOutCubic));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? DoodlePalette.dark : DoodlePalette.cream;
    final progression = Progression(widget.user.xp);

    final appBar = DoodleFadeSlide(
      animation: _interval(0.0, 0.5),
      yOffset: -16,
      child: _TopAppBar(
        user: widget.user,
        progression: progression,
        onAvatarTap: widget.onOpenProfile,
        onLogout: widget.onLogout,
      ),
    );
    final hero = DoodleFadeSlide(
      animation: _interval(0.12, 0.62),
      yOffset: 24,
      child: _HeroSection(
        nextModule: widget.nextModule,
        onResume: widget.onResume,
        onOpenMap: widget.onOpenMap,
      ),
    );
    final league = DoodleFadeSlide(
      animation: _interval(0.24, 0.74),
      yOffset: 24,
      child: _LeagueTracker(progression: progression),
    );
    final nav = DoodleFadeSlide(
      animation: _interval(0.36, 0.86),
      yOffset: 24,
      child: _HubNav(
        onOpenMap: widget.onOpenMap,
        onOpenCodeGolf: widget.onOpenCodeGolf,
        onOpenProfile: widget.onOpenProfile,
        onOpenSettings: widget.onOpenSettings,
      ),
    );

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
                    appBar,
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Wide screens: hero + league share the top row, nav
                        // fills a full-width grid below — no dead side margins.
                        if (constraints.maxWidth > 900) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: hero),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 2, child: league),
                                ],
                              ),
                              const SizedBox(height: 20),
                              nav,
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            hero,
                            const SizedBox(height: 16),
                            league,
                            const SizedBox(height: 16),
                            nav,
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

/// Top app bar: avatar, name, derived level + XP, a daily-streak flame pill,
/// and a logout badge. Name is [Expanded] so the row never overflows on
/// narrow phones.
class _TopAppBar extends StatelessWidget {
  final UserSession user;
  final Progression progression;
  final VoidCallback onAvatarTap;
  final VoidCallback onLogout;

  const _TopAppBar({
    required this.user,
    required this.progression,
    required this.onAvatarTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      child: Row(
        children: [
          GestureDetector(onTap: onAvatarTap, child: _avatar()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'Level ${progression.level}  ·  ${user.xp} XP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StreakPill(streak: user.streak),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onLogout,
            child: const DoodleIconBadge(
              icon: Icons.logout,
              color: DoodlePalette.white,
              iconColor: Colors.black,
              size: 40,
              iconSize: 18,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (user.photoUrl != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 2),
          image: DecorationImage(image: NetworkImage(user.photoUrl!), fit: BoxFit.cover),
        ),
      );
    }
    return const DoodleIconBadge(icon: Icons.person, color: DoodlePalette.blue, size: 48, iconSize: 24, borderRadius: 14);
  }
}

class _StreakPill extends StatelessWidget {
  final int streak;
  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: DoodlePalette.yellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 18, color: DoodlePalette.red),
          const SizedBox(width: 4),
          Text('$streak', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }
}

/// Hero "Resume Playing" card targeting the next unfinished puzzle. When all
/// levels are cleared it flips to an "open the map" call-to-action instead of
/// a dead-end.
class _HeroSection extends StatelessWidget {
  final CurriculumModule? nextModule;
  final void Function(CurriculumModule module) onResume;
  final VoidCallback onOpenMap;

  const _HeroSection({required this.nextModule, required this.onResume, required this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    final next = nextModule;
    return DoodleCard(
      color: DoodlePalette.purple,
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoodlePill(text: next == null ? 'All Cleared' : 'Up Next', background: DoodlePalette.yellow),
          const SizedBox(height: 14),
          Text(
            next == null ? "You've cleared every level!" : next.title,
            style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            next == null
                ? 'Replay any level from the map to push your efficiency score higher.'
                : next.description,
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: PulsingGlow(
              glowColor: DoodlePalette.green,
              borderRadius: 16,
              child: DoodleButton(
                label: next == null ? 'Open Level Map' : 'Resume Playing',
                color: DoodlePalette.green,
                icon: next == null ? Icons.map : Icons.play_arrow,
                onPressed: next == null ? onOpenMap : () => onResume(next),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// League-tier tracker: current tier badge, a progress bar toward the next
/// tier, and the XP still needed to rank up.
class _LeagueTracker extends StatelessWidget {
  final Progression progression;
  const _LeagueTracker({required this.progression});

  @override
  Widget build(BuildContext context) {
    final tier = progression.tier;
    final next = progression.nextTier;
    final toNext = progression.xpToNextTier;

    return DoodleCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DoodleIconBadge(icon: tier.icon, color: tier.color, size: 46, iconSize: 24, borderRadius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LEAGUE',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text('${tier.label} Tier',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
              ),
              if (next != null) DoodlePill(text: 'Next: ${next.label}', background: DoodlePalette.cream),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFECECEC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progression.tierProgress,
                child: Container(color: tier.color),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            toNext == null ? "Top tier reached — you're a legend! 🏆" : '$toNext XP to ${next!.label}',
            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Quick-nav tiles below the fold: Level Map, Code Golf, Profile, Settings.
/// Laid out in a responsive two-column grid (single column on narrow phones).
class _HubNav extends StatelessWidget {
  final VoidCallback onOpenMap;
  final VoidCallback onOpenCodeGolf;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;

  const _HubNav({
    required this.onOpenMap,
    required this.onOpenCodeGolf,
    required this.onOpenProfile,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _NavTile(icon: Icons.map, color: DoodlePalette.blue, title: 'Level Map', subtitle: 'Pick your next challenge', onTap: onOpenMap),
      _NavTile(icon: Icons.emoji_events, color: DoodlePalette.orange, title: 'Code Golf', subtitle: 'Byte-count leaderboards', onTap: onOpenCodeGolf),
      _NavTile(icon: Icons.person, color: DoodlePalette.green, title: 'Profile', subtitle: 'Badges & streaks', onTap: onOpenProfile),
      _NavTile(icon: Icons.settings, color: DoodlePalette.purple, title: 'Settings', subtitle: 'Theme, account & legal', onTap: onOpenSettings),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        // Scale column count with available width so the tiles always fill the
        // row rather than leaving a gap on the right.
        final cols = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 520
                ? 2
                : 1;
        final tileWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: 12,
          children: [for (final t in tiles) SizedBox(width: tileWidth, child: t)],
        );
      },
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DoodleCard(
        padding: const EdgeInsets.all(18),
        borderRadius: 18,
        child: Row(
          children: [
            DoodleIconBadge(icon: icon, color: color, size: 44, iconSize: 22, borderRadius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
