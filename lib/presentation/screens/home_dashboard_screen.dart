import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/session/email_auth_service.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../theme/landing_tokens.dart';
import '../theme/league_style.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';
import '../widgets/email_verification_banner.dart';

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
  final VoidCallback? onOpenFriends;
  final VoidCallback? onOpenCertificates;
  final VoidCallback? onOpenReport;
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
    this.onOpenFriends,
    this.onOpenCertificates,
    this.onOpenReport,
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
    final compactLayout = MediaQuery.sizeOf(context).width < 480;
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
    // Only nag about verification when a real Firebase account is signed in;
    // simulated/offline sessions have no email to verify.
    final firebaseEmail = EmailAuthService.currentEmail;
    final verifyBanner =
        (firebaseEmail != null && !EmailAuthService.emailVerified)
        ? _FadeSlide(
            animation: _interval(0.06, 0.56),
            yOffset: -12,
            child: EmailVerificationBanner(
              userEmail: firebaseEmail,
              onVerified: () => setState(() {}),
            ),
          )
        : null;
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
        onOpenFriends: widget.onOpenFriends,
        onOpenCertificates: widget.onOpenCertificates,
        onOpenReport: widget.onOpenReport,
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
                constraints: const BoxConstraints(maxWidth: 1920),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.sizeOf(context).width < 480 ? 6 : 8,
                    MediaQuery.sizeOf(context).width < 480 ? 6 : 8,
                    MediaQuery.sizeOf(context).width < 480 ? 6 : 8,
                    MediaQuery.sizeOf(context).width < 480 ? 12 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      appBar,
                      SizedBox(height: compactLayout ? 6 : 8),
                      if (verifyBanner != null) ...[
                        verifyBanner,
                        SizedBox(height: compactLayout ? 6 : 8),
                      ],
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Wide screens: hero + league share the top row, nav
                          // fills a full-width grid below — no dead side margins.
                          if (constraints.maxWidth >= 720) {
                            final panelHeight = constraints.maxWidth < 1280
                                ? 230.0
                                : 184.0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: SizedBox(
                                        height: panelHeight,
                                        child: hero,
                                      ),
                                    ),
                                    SizedBox(width: compactLayout ? 6 : 8),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        height: panelHeight,
                                        child: league,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: compactLayout ? 6 : 8),
                                nav,
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              hero,
                              SizedBox(height: compactLayout ? 6 : 8),
                              league,
                              SizedBox(height: compactLayout ? 6 : 8),
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
    final compact = MediaQuery.sizeOf(context).width < 390;
    return _Panel(
      skin: skin,
      padding: EdgeInsets.all(compact ? 6 : 8),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onAvatarTap,
              child: _avatar(size: compact ? 38 : 42),
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
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
          SizedBox(width: compact ? 6 : 8),
          _StreakChip(streak: user.streak, skin: skin, compact: compact),
          SizedBox(width: compact ? 6 : 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onLogout,
              child: Container(
                width: compact ? 36 : 40,
                height: compact ? 36 : 40,
                decoration: BoxDecoration(
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(color: skin.borderStrong),
                ),
                child: Icon(
                  Icons.logout,
                  color: skin.sub,
                  size: compact ? 17 : 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar({required double size}) {
    if (user.photoUrl != null) {
      return Container(
        width: size,
        height: size,
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
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: LandingTokens.ember,
        borderRadius: LandingTokens.smallRadius,
      ),
      child: Icon(
        Icons.person,
        color: const Color(0xFF0A0500),
        size: size * 0.52,
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int streak;
  final _Skin skin;
  final bool compact;

  const _StreakChip({
    required this.streak,
    required this.skin,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 8 : 9,
      ),
      decoration: BoxDecoration(
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.ember.withValues(alpha: 0.55)),
        color: LandingTokens.ember.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: compact ? 15 : 16,
            color: LandingTokens.ember,
          ),
          SizedBox(width: compact ? 4 : 5),
          Text(
            'x$streak',
            style: LandingTokens.mono(
              fontSize: compact ? 11 : 12,
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
    final compact = MediaQuery.sizeOf(context).width < 480;
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
            padding: EdgeInsets.all(compact ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PulsingDot(color: LandingTokens.ember, size: 5),
                    const SizedBox(width: 7),
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
                SizedBox(height: compact ? 10 : 12),
                Text(
                  next == null ? "You've cleared every level!" : next.title,
                  style: LandingTokens.display(
                    fontSize: compact ? 21 : 23,
                    color: skin.text,
                  ),
                ),
                SizedBox(height: compact ? 7 : 8),
                Text(
                  next == null
                      ? 'Replay any level from the map to push your efficiency score higher.'
                      : next.description,
                  maxLines: compact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.body(
                    fontSize: compact ? 13 : 14,
                    color: skin.sub,
                  ),
                ),
                SizedBox(height: compact ? 14 : 16),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: next == null ? 'Open Level Map' : 'Resume Playing',
                    icon: next == null ? Icons.map : Icons.play_arrow,
                    compact: true,
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
    final compact = MediaQuery.sizeOf(context).width < 480;

    return _Panel(
      skin: skin,
      padding: EdgeInsets.all(compact ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 40 : 44,
                height: compact ? 40 : 44,
                decoration: BoxDecoration(
                  color: tier.color.withValues(alpha: 0.12),
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(color: tier.color.withValues(alpha: 0.55)),
                ),
                child: Icon(
                  tier.icon,
                  color: tier.color,
                  size: compact ? 20 : 22,
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
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
                    const SizedBox(height: 2),
                    Text(
                      '${tier.label.toUpperCase()} TIER',
                      style: LandingTokens.display(
                        fontSize: compact ? 16 : 18,
                        color: skin.text,
                      ),
                    ),
                  ],
                ),
              ),
              if (next != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 6 : 8,
                    vertical: compact ? 4 : 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(color: skin.borderStrong),
                  ),
                  child: Text(
                    'NEXT: ${next.label.toUpperCase()}',
                    style: LandingTokens.label(
                      fontSize: compact ? 8 : 9,
                      color: skin.sub,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: compact ? 14 : 16),
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
          SizedBox(height: compact ? 8 : 10),
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
  final VoidCallback? onOpenFriends;
  final VoidCallback? onOpenCertificates;
  final VoidCallback? onOpenReport;
  final VoidCallback onOpenSettings;

  const _HubNav({
    required this.skin,
    required this.onOpenMap,
    required this.onOpenCodeGolf,
    required this.onOpenProfile,
    this.onOpenFriends,
    this.onOpenCertificates,
    this.onOpenReport,
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
      if (onOpenFriends != null)
        _NavTile(
          icon: Icons.group,
          accent: LandingTokens.circuit,
          title: 'Friends',
          subtitle: 'Invite +50 XP each',
          skin: skin,
          onTap: onOpenFriends!,
        ),
      if (onOpenCertificates != null)
        _NavTile(
          icon: Icons.workspace_premium,
          accent: LandingTokens.signal,
          title: 'Certificates',
          subtitle: 'Verified module credentials',
          skin: skin,
          onTap: onOpenCertificates!,
        ),
      if (onOpenReport != null)
        _NavTile(
          icon: Icons.insights,
          accent: const Color(0xFF9E9CFF),
          title: 'Performance Report',
          subtitle: 'Accuracy, pace & progress',
          skin: skin,
          onTap: onOpenReport!,
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
        const gap = 8.0;
        final maxColumns = constraints.maxWidth >= 1280
            ? 4
            : constraints.maxWidth >= 960
            ? 3
            : constraints.maxWidth >= 480
            ? 2
            : 1;
        final columns = _preferredColumns(tiles.length, maxColumns);
        final rows = <List<_NavTile>>[];
        for (var start = 0; start < tiles.length; start += columns) {
          final end = start + columns < tiles.length
              ? start + columns
              : tiles.length;
          rows.add(tiles.sublist(start, end));
        }

        return Column(
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
              Row(
                children: [
                  for (
                    var tileIndex = 0;
                    tileIndex < rows[rowIndex].length;
                    tileIndex++
                  ) ...[
                    Expanded(
                      flex:
                          rowIndex == rows.length - 1 &&
                              tileIndex == rows[rowIndex].length - 1
                          ? columns - rows[rowIndex].length + 1
                          : 1,
                      child: rows[rowIndex][tileIndex],
                    ),
                    if (tileIndex < rows[rowIndex].length - 1)
                      const SizedBox(width: gap),
                  ],
                ],
              ),
              if (rowIndex < rows.length - 1) const SizedBox(height: gap),
            ],
          ],
        );
      },
    );
  }

  int _preferredColumns(int itemCount, int maxColumns) {
    final capped = itemCount < maxColumns ? itemCount : maxColumns;
    if (capped <= 2) return capped;

    for (var candidate = capped; candidate >= 2; candidate--) {
      final finalRowCount = itemCount % candidate;
      if (finalRowCount == 0 || finalRowCount > 1) return candidate;
    }
    return capped;
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
    final compact = MediaQuery.sizeOf(context).width < 390;
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
          padding: EdgeInsets.all(compact ? 7 : 8),
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
                width: compact ? 36 : 40,
                height: compact ? 36 : 40,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.1),
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.accent,
                  size: compact ? 19 : 20,
                ),
              ),
              SizedBox(width: compact ? 9 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.label(
                        fontSize: compact ? 10 : 10.5,
                        color: skin.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.body(
                        fontSize: compact ? 11 : 11.5,
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
                  size: compact ? 15 : 16,
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
