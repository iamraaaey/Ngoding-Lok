import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../theme/landing_tokens.dart';
import '../theme/league_style.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';

/// Screen 4 — the Home Dashboard ("The Hub") in the terminal noir style.
/// Surfaces the player's identity and momentum at a glance (avatar,
/// level/XP, daily streak), a one-tap "Resume Playing" hero that jumps
/// straight to their next unfinished puzzle, a league-tier tracker with a
/// progress bar to the next rank, and quick links to the full level map and
/// the leaderboard.
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

/// Brightness-resolved surface colors so the Settings dark/light switch
/// keeps working. Dark is the canonical terminal noir; light swaps in paper
/// surfaces while keeping the same accents and structure.
class _Skin {
  final Color bg;
  final Color panel;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color sub;
  final Color faint;

  const _Skin({
    required this.bg,
    required this.panel,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.sub,
    required this.faint,
  });

  static const dark = _Skin(
    bg: LandingTokens.voidBlack,
    panel: LandingTokens.carbon,
    border: LandingTokens.hairline,
    borderStrong: LandingTokens.hairlineStrong,
    text: LandingTokens.textPrimary,
    sub: LandingTokens.textMuted,
    faint: LandingTokens.textFaint,
  );

  static const light = _Skin(
    bg: Color(0xFFF4F2EC),
    panel: Color(0xFFFFFFFF),
    border: Color(0x1A000000),
    borderStrong: Color(0x33000000),
    text: Color(0xFF16150F),
    sub: Color(0xFF6A6960),
    faint: Color(0xFF9A988D),
  );

  static _Skin of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
    parent: _entrance,
    curve: Interval(begin, end, curve: Curves.easeOutCubic),
  );

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final progression = Progression(widget.user.xp);

    final appBar = _FadeSlide(
      animation: _interval(0.0, 0.5),
      yOffset: -16,
      child: _TopAppBar(
        user: widget.user,
        progression: progression,
        skin: skin,
        onAvatarTap: widget.onOpenProfile,
        onLogout: widget.onLogout,
      ),
    );
    final hero = _FadeSlide(
      animation: _interval(0.12, 0.62),
      yOffset: 24,
      child: _HeroSection(
        nextModule: widget.nextModule,
        skin: skin,
        onResume: widget.onResume,
        onOpenMap: widget.onOpenMap,
      ),
    );
    final league = _FadeSlide(
      animation: _interval(0.24, 0.74),
      yOffset: 24,
      child: _LeagueTracker(progression: progression, skin: skin),
    );
    final nav = _FadeSlide(
      animation: _interval(0.36, 0.86),
      yOffset: 24,
      child: _HubNav(
        skin: skin,
        onOpenMap: widget.onOpenMap,
        onOpenCodeGolf: widget.onOpenCodeGolf,
        onOpenProfile: widget.onOpenProfile,
        onOpenSettings: widget.onOpenSettings,
      ),
    );

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (dark) const CinematicBackdrop(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1800),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      appBar,
                      const SizedBox(height: 8),
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
                                    const SizedBox(width: 8),
                                    Expanded(flex: 2, child: league),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                nav,
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              hero,
                              const SizedBox(height: 8),
                              league,
                              const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}

/// Local fade + slide entrance, driven by the screen's staggered intervals.
class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final double yOffset;
  final Widget child;

  const _FadeSlide({
    required this.animation,
    required this.yOffset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * yOffset),
            child: child,
          ),
        );
      },
    );
  }
}

/// Hairline panel shared by every dashboard card.
class _Panel extends StatelessWidget {
  final _Skin skin;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.skin,
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: skin.panel,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: skin.border),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: child,
    );
  }
}

/// Top app bar: avatar, name, derived level + XP, a daily-streak flame
/// chip, and a logout badge. Name is [Expanded] so the row never overflows
/// on narrow phones.
class _TopAppBar extends StatelessWidget {
  final UserSession user;
  final Progression progression;
  final _Skin skin;
  final VoidCallback onAvatarTap;
  final VoidCallback onLogout;

  const _TopAppBar({
    required this.user,
    required this.progression,
    required this.skin,
    required this.onAvatarTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      skin: skin,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(onTap: onAvatarTap, child: _avatar()),
          ),
          const SizedBox(width: 8),
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
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'LVL ${progression.level} // ${user.xp} XP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.label(fontSize: 9.5, color: skin.faint),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StreakChip(streak: user.streak, skin: skin),
          const SizedBox(width: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onLogout,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(color: skin.borderStrong),
                ),
                child: Icon(Icons.logout, color: skin.sub, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (user.photoUrl != null) {
      return Container(
        width: 46,
        height: 46,
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
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: LandingTokens.ember,
        borderRadius: LandingTokens.smallRadius,
      ),
      child: const Icon(Icons.person, color: Color(0xFF0A0500), size: 24),
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int streak;
  final _Skin skin;

  const _StreakChip({required this.streak, required this.skin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.ember.withValues(alpha: 0.55)),
        color: LandingTokens.ember.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 16,
            color: LandingTokens.ember,
          ),
          const SizedBox(width: 5),
          Text(
            'x$streak',
            style: LandingTokens.mono(
              fontSize: 12,
              color: LandingTokens.ember,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero "Resume Playing" card targeting the next unfinished puzzle, with
/// the theme's single iridescent strip along the top. When all levels are
/// cleared it flips to an "open the map" call-to-action instead of a
/// dead-end.
class _HeroSection extends StatelessWidget {
  final CurriculumModule? nextModule;
  final _Skin skin;
  final void Function(CurriculumModule module) onResume;
  final VoidCallback onOpenMap;

  const _HeroSection({
    required this.nextModule,
    required this.skin,
    required this.onResume,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final next = nextModule;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: skin.panel,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: skin.border),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 3,
            width: double.infinity,
            child: AnimatedIridescence(borderRadius: BorderRadius.zero),
          ),
          Padding(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 400 ? 16 : 22,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PulsingDot(color: LandingTokens.ember, size: 5),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        next == null
                            ? '// ALL CLEARED'
                            : '// UP NEXT — MISSION QUEUE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LandingTokens.label(
                          fontSize: 10,
                          color: LandingTokens.ember,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  next == null ? "You've cleared every level!" : next.title,
                  style: LandingTokens.display(fontSize: 24, color: skin.text),
                ),
                const SizedBox(height: 10),
                Text(
                  next == null
                      ? 'Replay any level from the map to push your efficiency score higher.'
                      : next.description,
                  style: LandingTokens.body(fontSize: 14, color: skin.sub),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GradientButton(
                    label: next == null ? 'Open Level Map' : 'Resume Playing',
                    icon: next == null ? Icons.map : Icons.play_arrow,
                    onPressed: next == null ? onOpenMap : () => onResume(next),
                  ),
                ),
              ],
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
  final _Skin skin;

  const _LeagueTracker({required this.progression, required this.skin});

  @override
  Widget build(BuildContext context) {
    final tier = progression.tier;
    final next = progression.nextTier;
    final toNext = progression.xpToNextTier;

    return _Panel(
      skin: skin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tier.color.withValues(alpha: 0.12),
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(color: tier.color.withValues(alpha: 0.55)),
                ),
                child: Icon(tier.icon, color: tier.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '// LEAGUE',
                      style: LandingTokens.label(
                        fontSize: 9,
                        color: skin.faint,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${tier.label.toUpperCase()} TIER',
                      style: LandingTokens.display(
                        fontSize: 18,
                        color: skin.text,
                      ),
                    ),
                  ],
                ),
              ),
              if (next != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(color: skin.borderStrong),
                  ),
                  child: Text(
                    'NEXT: ${next.label.toUpperCase()}',
                    style: LandingTokens.label(fontSize: 9, color: skin.sub),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 6,
            decoration: BoxDecoration(border: Border.all(color: skin.border)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progression.tierProgress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: tier.color,
                  boxShadow: [
                    BoxShadow(
                      color: tier.color.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            toNext == null
                ? 'TOP TIER REACHED — LEGEND STATUS'
                : '$toNext XP TO ${next!.label.toUpperCase()}',
            style: LandingTokens.label(fontSize: 9.5, color: skin.faint),
          ),
        ],
      ),
    );
  }
}

/// Quick-nav tiles below the fold: Level Map, Code Golf, Profile, Settings.
/// Laid out in a responsive grid; each tile lifts and warms its border on
/// hover, like the landing module cards.
class _HubNav extends StatelessWidget {
  final _Skin skin;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenCodeGolf;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;

  const _HubNav({
    required this.skin,
    required this.onOpenMap,
    required this.onOpenCodeGolf,
    required this.onOpenProfile,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _NavTile(
        icon: Icons.map,
        accent: LandingTokens.circuit,
        title: 'Level Map',
        subtitle: 'Pick your next challenge',
        skin: skin,
        onTap: onOpenMap,
      ),
      _NavTile(
        icon: Icons.emoji_events,
        accent: LandingTokens.ember,
        title: 'Code Golf',
        subtitle: 'Byte-count leaderboards',
        skin: skin,
        onTap: onOpenCodeGolf,
      ),
      _NavTile(
        icon: Icons.person,
        accent: LandingTokens.signal,
        title: 'Profile',
        subtitle: 'Badges & streaks',
        skin: skin,
        onTap: onOpenProfile,
      ),
      _NavTile(
        icon: Icons.settings,
        accent: Color(0xFF9E9CFF),
        title: 'Settings',
        subtitle: 'Theme, account & legal',
        skin: skin,
        onTap: onOpenSettings,
      ),
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
          children: [
            for (final t in tiles) SizedBox(width: tileWidth, child: t),
          ],
        );
      },
    );
  }
}

class _NavTile extends StatefulWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final _Skin skin;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.skin,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final skin = widget.skin;
    final motion = LandingTokens.motionFor(
      context,
      LandingTokens.motionStandard,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: motion,
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: skin.panel,
            borderRadius: LandingTokens.mediumRadius,
            border: Border.all(
              color: _hovered
                  ? widget.accent.withValues(alpha: 0.65)
                  : skin.border,
            ),
            boxShadow: LandingTokens.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.1),
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(widget.icon, color: widget.accent, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.label(
                        fontSize: 11,
                        color: skin.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.body(
                        fontSize: 12,
                        color: skin.faint,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSlide(
                duration: motion,
                offset: _hovered ? const Offset(0.2, 0) : Offset.zero,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: _hovered ? widget.accent : skin.faint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
