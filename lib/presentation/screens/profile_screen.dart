import 'package:flutter/material.dart';
import '../../core/session/google_auth_service.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../../core/social/achievement.dart';
import '../../data/repositories/user_repository.dart';
import '../theme/landing_tokens.dart';
import '../theme/league_style.dart';
import '../theme/noir_skin.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';

/// Screen 10 — User Profile & Achievements, in the terminal noir style. A
/// player card (identity, live XP/league stats, linked GitHub), streak
/// management with a calendar of recent activity and an XP-priced "Streak
/// Freeze" purchase, and a grid of unlocked and locked achievement badges.
/// When a signed-in [uid] and [repository] are provided, the card renders
/// straight from the live Firestore profile document.
class ProfileScreen extends StatefulWidget {
  final UserSession user;
  final String? uid;
  final UserRepository? repository;

  /// Attempts to buy a Streak Freeze with XP; returns whether it succeeded
  /// (false when the player can't afford it). Implemented by the orchestrator
  /// so it can mutate the shared session.
  final bool Function() onPurchaseStreakFreeze;
  final VoidCallback? onOpenFriends;
  final VoidCallback? onOpenCertificates;
  final VoidCallback onBack;

  static const int streakFreezeCost = 200;

  const ProfileScreen({
    super.key,
    required this.user,
    this.uid,
    this.repository,
    required this.onPurchaseStreakFreeze,
    this.onOpenFriends,
    this.onOpenCertificates,
    required this.onBack,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Stream<UserSession?>? _liveUser;

  @override
  void initState() {
    super.initState();
    final uid = widget.uid;
    final repository = widget.repository;
    if (uid != null && repository != null) {
      // The real Firestore profile document, streamed live. The try/catch
      // keeps the screen alive when Firebase is unavailable (tests, offline).
      try {
        _liveUser = repository.streamUserFromFirestore(uid);
      } catch (_) {
        _liveUser = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserSession?>(
      stream: _liveUser,
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.user;
        return _ProfileBody(
          user: user,
          live: snapshot.hasData,
          onPurchaseStreakFreeze: widget.onPurchaseStreakFreeze,
          onOpenFriends: widget.onOpenFriends,
          onOpenCertificates: widget.onOpenCertificates,
          onBack: widget.onBack,
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserSession user;
  final bool live;
  final bool Function() onPurchaseStreakFreeze;
  final VoidCallback? onOpenFriends;
  final VoidCallback? onOpenCertificates;
  final VoidCallback onBack;

  const _ProfileBody({
    required this.user,
    required this.live,
    required this.onPurchaseStreakFreeze,
    this.onOpenFriends,
    this.onOpenCertificates,
    required this.onBack,
  });

  static const int streakFreezeCost = ProfileScreen.streakFreezeCost;

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);

    final profileCard = _ProfileCard(user: user, skin: skin, live: live);
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
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.sizeOf(context).width < 600 ? 12 : 20,
                    12,
                    MediaQuery.sizeOf(context).width < 600 ? 12 : 20,
                    24,
                  ),
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
                                      if (onOpenFriends != null) ...[
                                        const SizedBox(height: 20),
                                        _FriendsShortcut(
                                          user: user,
                                          skin: skin,
                                          onOpen: onOpenFriends!,
                                        ),
                                      ],
                                      if (onOpenCertificates != null) ...[
                                        const SizedBox(height: 20),
                                        _CertificateShortcut(
                                          user: user,
                                          skin: skin,
                                          onOpen: onOpenCertificates!,
                                        ),
                                      ],
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
                              if (onOpenFriends != null) ...[
                                const SizedBox(height: 16),
                                _FriendsShortcut(
                                  user: user,
                                  skin: skin,
                                  onOpen: onOpenFriends!,
                                ),
                              ],
                              if (onOpenCertificates != null) ...[
                                const SizedBox(height: 16),
                                _CertificateShortcut(
                                  user: user,
                                  skin: skin,
                                  onOpen: onOpenCertificates!,
                                ),
                              ],
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

  /// True when the card is rendering the live Firestore profile document.
  final bool live;

  const _ProfileCard({
    required this.user,
    required this.skin,
    required this.live,
  });

  @override
  Widget build(BuildContext context) {
    final progression = Progression(user.xp);
    final tier = progression.tier;
    final nextTier = progression.nextTier;
    return NoirPanel(
      skin: skin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 6),
                    Text(
                      live ? '● LIVE PROFILE' : '● LOCAL SESSION',
                      style: LandingTokens.label(
                        fontSize: 8.5,
                        color: live ? LandingTokens.signal : skin.faint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Live stats straight from the profile document. The grid collapses
          // from four tiles to two columns on narrow phones so nothing clips.
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 520
                  ? 4
                  : constraints.maxWidth > 260
                  ? 2
                  : 1;
              const gap = 10.0;
              final tileW = (constraints.maxWidth - gap * (cols - 1)) / cols;
              final tiles = [
                _StatTile(
                  icon: Icons.bolt,
                  color: LandingTokens.ember,
                  value: '${user.xp}',
                  label: 'TOTAL XP',
                  skin: skin,
                ),
                _StatTile(
                  icon: Icons.military_tech,
                  color: LandingTokens.circuit,
                  value: 'LV ${progression.level}',
                  label: 'LEVEL',
                  skin: skin,
                ),
                _StatTile(
                  icon: Icons.task_alt,
                  color: LandingTokens.signal,
                  value: '${user.completedModuleIds.length}',
                  label: 'MODULES',
                  skin: skin,
                ),
                _StatTile(
                  icon: Icons.group,
                  color: const Color(0xFF9E9CFF),
                  value: '${user.friendIds.length}',
                  label: 'FRIENDS',
                  skin: skin,
                ),
              ];
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final t in tiles) SizedBox(width: tileW, child: t),
                ],
              );
            },
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progression.tierProgress,
              minHeight: 5,
              backgroundColor: skin.panelRaised,
              valueColor: AlwaysStoppedAnimation<Color>(tier.color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            nextTier == null
                ? 'MAX LEAGUE REACHED'
                : '${progression.xpToNextTier} XP TO ${nextTier.label.toUpperCase()}',
            style: LandingTokens.label(fontSize: 8.5, color: skin.faint),
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

/// One compact metric on the player card. The value scales down with a
/// [FittedBox] instead of clipping when a tile gets narrow.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final NoirSkin skin;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: skin.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: LandingTokens.mono(
                      fontSize: 15,
                      color: skin.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.label(fontSize: 8, color: skin.faint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsShortcut extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;
  final VoidCallback onOpen;

  const _FriendsShortcut({
    required this.user,
    required this.skin,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.group, color: LandingTokens.circuit, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Friends & referrals',
                  style: TextStyle(
                    color: skin.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${user.friendIds.length} connected · Invite a coder for +50 XP each',
                  style: LandingTokens.label(fontSize: 9, color: skin.faint),
                ),
              ],
            ),
          ),
          CinematicOutlineButton(
            label: 'Open',
            icon: Icons.arrow_forward,
            compact: true,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}

class _CertificateShortcut extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;
  final VoidCallback onOpen;

  const _CertificateShortcut({
    required this.user,
    required this.skin,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final count = user.completedModuleIds.length;
    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: LandingTokens.signal,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module certificates',
                  style: TextStyle(
                    color: skin.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count completed · Issue verified credentials',
                  style: LandingTokens.label(fontSize: 9, color: skin.faint),
                ),
              ],
            ),
          ),
          CinematicOutlineButton(
            label: 'Open',
            icon: Icons.arrow_forward,
            compact: true,
            onPressed: onOpen,
          ),
        ],
      ),
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
    final labelText = Text(
      label,
      style: TextStyle(
        color: skin.sub,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // Narrow phones: the value drops under the label instead of fighting
        // it for the same row.
        if (constraints.maxWidth < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: 10),
                  Expanded(child: labelText),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: valueWidget,
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(child: labelText),
            valueWidget,
          ],
        );
      },
    );
  }
}

class _LinkGitHubButton extends StatefulWidget {
  final NoirSkin skin;

  const _LinkGitHubButton({required this.skin});

  @override
  State<_LinkGitHubButton> createState() => _LinkGitHubButtonState();
}

class _LinkGitHubButtonState extends State<_LinkGitHubButton> {
  bool _linking = false;
  late bool _linked;

  NoirSkin get skin => widget.skin;

  @override
  void initState() {
    super.initState();
    _linked = GitHubAuthService.isLinked;
  }

  Future<void> _connect() async {
    if (_linking || _linked) return;
    setState(() => _linking = true);
    try {
      await GitHubAuthService.linkCurrentUser();
      if (!mounted) return;
      final linked = GitHubAuthService.isLinked;
      setState(() {
        _linking = false;
        _linked = linked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            linked
                ? 'GitHub is now connected to your player account.'
                : 'GitHub connection was cancelled.',
          ),
        ),
      );
    } on SocialAuthException catch (error) {
      if (!mounted) return;
      setState(() => _linking = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _linking
        ? 'CONNECTING...'
        : _linked
        ? 'LINKED'
        : 'NOT LINKED · LINK';
    final accent = _linked ? LandingTokens.signal : skin.sub;
    return MouseRegion(
      cursor: _linked ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _connect,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: LandingTokens.smallRadius,
            border: Border.all(
              color: _linked
                  ? LandingTokens.signal.withValues(alpha: 0.65)
                  : skin.borderStrong,
            ),
            color: _linked
                ? LandingTokens.signal.withValues(alpha: 0.08)
                : null,
          ),
          child: Text(
            label,
            style: LandingTokens.label(fontSize: 9, color: accent),
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
    'sequential_steps' => Icons.alt_route,
    'grid_master' => Icons.grid_view,
    'sql_sleuth' => Icons.storage,
    'rocket_scientist' => Icons.rocket_launch,
    'cyber_defender' => Icons.shield,
    'java_starter' => Icons.coffee,
    'module_runner' => Icons.route,
    'halfway_there' => Icons.flag_circle,
    'curriculum_complete' => Icons.school,
    'graduation_flight' => Icons.flight_takeoff,
    'persistence' => Icons.local_fire_department,
    'week_warrior' => Icons.calendar_month,
    'streak_legend' => Icons.whatshot,
    'polyglot' => Icons.translate,
    'high_roller' => Icons.savings,
    'efficiency_expert' => Icons.bolt,
    'speedrunner' => Icons.speed,
    'code_golfer' => Icons.code,
    'golf_enthusiast' => Icons.golf_course,
    'golf_master' => Icons.sports_golf,
    _ => Icons.emoji_events,
  };

  Color _colorFor(String id) => switch (id) {
    'first_steps' => LandingTokens.signal,
    'sequential_steps' => LandingTokens.circuit,
    'grid_master' => LandingTokens.circuit,
    'sql_sleuth' => const Color(0xFF9E9CFF),
    'rocket_scientist' => LandingTokens.ember,
    'cyber_defender' => LandingTokens.signal,
    'java_starter' => const Color(0xFFFFB300),
    'module_runner' => LandingTokens.circuit,
    'halfway_there' => const Color(0xFF9E9CFF),
    'curriculum_complete' => LandingTokens.signal,
    'graduation_flight' => LandingTokens.ember,
    'persistence' => LandingTokens.ember,
    'week_warrior' => LandingTokens.ember,
    'streak_legend' => const Color(0xFFFFB300),
    'polyglot' => const Color(0xFFFFB300),
    'high_roller' => LandingTokens.signal,
    'efficiency_expert' => const Color(0xFFFFB300),
    'speedrunner' => LandingTokens.circuit,
    'code_golfer' => LandingTokens.signal,
    'golf_enthusiast' => const Color(0xFF00D98E),
    'golf_master' => const Color(0xFFFFD700),
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
              final progress = badges.isEmpty
                  ? 0.0
                  : unlockedCount / badges.length;
              final meter = ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: skin.panelRaised,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    LandingTokens.ember,
                  ),
                ),
              );
              final copy = Text(
                unlockedCount == badges.length
                    ? 'ALL ACHIEVEMENTS UNLOCKED'
                    : '${badges.length - unlockedCount} challenges remain',
                style: LandingTokens.label(fontSize: 9, color: skin.faint),
              );
              if (constraints.maxWidth < 430) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [copy, const SizedBox(height: 8), meter],
                );
              }
              return Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 18),
                  SizedBox(width: 150, child: meter),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 620
                  ? 4
                  : constraints.maxWidth > 360
                  ? 3
                  : constraints.maxWidth > 320
                  ? 2
                  : 1;
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
                        progress: b.progress,
                        target: b.target,
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
  final int progress;
  final int target;
  final NoirSkin skin;

  const _BadgeTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.unlocked,
    required this.progress,
    required this.target,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      // Locked achievements should still be legible enough to explain what
      // the player is working toward.
      opacity: unlocked ? 1 : 0.78,
      child: Container(
        constraints: const BoxConstraints(minHeight: 154),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.body(fontSize: 10, color: skin.faint),
            ),
            if (target > 1) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (progress / target).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: skin.panelRaised,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    unlocked ? color : color.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${progress.clamp(0, target)} / $target',
                style: LandingTokens.mono(fontSize: 9, color: skin.faint),
              ),
            ] else ...[
              const SizedBox(height: 6),
              Text(
                unlocked ? 'UNLOCKED' : 'LOCKED',
                style: LandingTokens.label(
                  fontSize: 8,
                  color: unlocked ? color : skin.faint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
