import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../../data/repositories/user_repository.dart';
import '../theme/landing_tokens.dart';
import '../theme/noir_skin.dart';

/// Real-time user analytics dashboard showing:
/// - XP progression and league status
/// - Module completion by track
/// - Accuracy and consistency metrics
/// - Time investment breakdown
/// - Achievement progress
/// - Firestore-backed data with live sync
class UserAnalyticsDashboard extends StatefulWidget {
  final UserSession user;
  final String? uid;
  final UserRepository? repository;
  final VoidCallback onBack;
  final void Function(String routeName) onNavigate;

  const UserAnalyticsDashboard({
    super.key,
    required this.user,
    required this.uid,
    required this.repository,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<UserAnalyticsDashboard> createState() => _UserAnalyticsDashboardState();
}

class _UserAnalyticsDashboardState extends State<UserAnalyticsDashboard> {
  late UserSession _user;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _refreshData();
  }

  Future<void> _refreshData() async {
    final uid = widget.uid;
    final repo = widget.repository;
    if (uid == null || repo == null) return;

    setState(() => _loading = true);
    try {
      final fresh = await repo.fetchUserFromFirestore(uid);
      if (mounted && fresh != null) {
        setState(() => _user = fresh);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    final progression = Progression(_user.xp);
    final total = Curriculum.modules.length;
    final completed = _user.completedModuleIds.length;
    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ANALYTICS DASHBOARD',
                              style: LandingTokens.label(
                                fontSize: 9,
                                color: LandingTokens.ember,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Learning Intelligence',
                              style: LandingTokens.display(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onBack,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Stats
                  _QuickStatsRow(
                    user: _user,
                    progression: progression,
                    completed: completed,
                    total: total,
                  ),
                  const SizedBox(height: 16),

                  // XP Progress Card
                  _XpProgressCard(
                    progression: progression,
                    skin: skin,
                  ),
                  const SizedBox(height: 16),

                  // Track Breakdown
                  _TrackBreakdownCard(
                    user: _user,
                    skin: skin,
                  ),
                  const SizedBox(height: 16),

                  // Performance Metrics Grid
                  _PerformanceMetricsGrid(
                    user: _user,
                    skin: skin,
                  ),
                  const SizedBox(height: 16),

                  // Achievements Summary
                  _AchievementsSummaryCard(
                    user: _user,
                    skin: skin,
                    onTap: () => widget.onNavigate('profile'),
                  ),
                  const SizedBox(height: 16),

                  // Refresh Button
                  FilledButton.tonal(
                    onPressed: _loading ? null : _refreshData,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _loading ? 'SYNCING...' : 'SYNC WITH FIRESTORE',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // View Full Report Button
                  FilledButton(
                    onPressed: () => widget.onNavigate('performance_report'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('VIEW FULL PERFORMANCE REPORT'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final UserSession user;
  final Progression progression;
  final int completed;
  final int total;

  const _QuickStatsRow({
    required this.user,
    required this.progression,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'XP',
            value: user.xp.toString(),
            subtitle: progression.tier.label,
            icon: Icons.star,
            color: LandingTokens.ember,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'PROGRESS',
            value: '$completed/$total',
            subtitle: '${(completed / total * 100).round()}% complete',
            icon: Icons.trending_up,
            color: const Color(0xFF00D98E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'STREAK',
            value: '${user.streak}d',
            subtitle: 'Best: ${user.bestStreak}d',
            icon: Icons.local_fire_department,
            color: LandingTokens.circuit,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: LandingTokens.mono(
              fontSize: 18,
              color: skin.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: LandingTokens.label(fontSize: 8, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LandingTokens.body(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _XpProgressCard extends StatelessWidget {
  final Progression progression;
  final NoirSkin skin;

  const _XpProgressCard({
    required this.progression,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final currentXp = progression.xp;
    final currentTierFloor = progression.tier.floor;
    final nextTier = progression.nextTier;
    final nextXp = nextTier?.floor;
    final progress = nextXp == null
        ? 1.0
        : ((currentXp - currentTierFloor) /
                  (nextXp - currentTierFloor))
              .clamp(0.0, 1.0);

    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TIER PROGRESS',
                style: LandingTokens.label(
                  fontSize: 9,
                  color: LandingTokens.ember,
                ),
              ),
              Text(
                progression.tier.label.toUpperCase(),
                style: LandingTokens.label(
                  fontSize: 9,
                  color: LandingTokens.circuit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(LandingTokens.ember),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextXp == null
                ? '$currentXp XP // MAX TIER'
                : '$currentXp / $nextXp XP until next tier',
            style: LandingTokens.body(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TrackBreakdownCard extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;

  const _TrackBreakdownCard({
    required this.user,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final tracks = [
      LanguageTrack.python,
      LanguageTrack.sql,
      LanguageTrack.java,
      LanguageTrack.cybersecurity,
    ];

    final trackStats = <LanguageTrack, int>{};
    for (final track in tracks) {
      trackStats[track] = Curriculum.modules
          .where(
              (m) => m.track == track && user.completedModuleIds.contains(m.id))
          .length;
    }

    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRACK MASTERY',
            style: LandingTokens.label(
              fontSize: 9,
              color: LandingTokens.circuit,
            ),
          ),
          const SizedBox(height: 12),
          ...tracks.map((track) {
            final completed = trackStats[track] ?? 0;
            final total = Curriculum.modules
                .where((m) => m.track == track)
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TrackProgressRow(
                track: track.label,
                completed: completed,
                total: total,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TrackProgressRow extends StatelessWidget {
  final String track;
  final int completed;
  final int total;

  const _TrackProgressRow({
    required this.track,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              track.toUpperCase(),
              style: LandingTokens.label(fontSize: 9),
            ),
            Text(
              '$completed/$total',
              style: LandingTokens.mono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(const Color(0xFF9E9CFF), const Color(0xFF00D98E),
                  progress) ??
                  const Color(0xFF00D98E),
            ),
          ),
        ),
      ],
    );
  }
}

class _PerformanceMetricsGrid extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;

  const _PerformanceMetricsGrid({
    required this.user,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final perf = user.modulePerformance;
    if (perf.isEmpty) {
      return NoirPanel(
        skin: skin,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Complete modules to see performance metrics',
            style: LandingTokens.body(fontSize: 12),
          ),
        ),
      );
    }

    final avgAccuracy =
        perf.values.isEmpty ? 0.0 : perf.values.fold(0.0, (a, b) => a + b.accuracy) / perf.length;
    final avgTime = perf.values.isEmpty ? 0 : perf.values.fold(0, (a, b) => a + b.executionMs) ~/ perf.length;
    final totalAttempts =
        perf.values.fold(0, (total, p) => total + p.attempts);

    return Row(
      children: [
        Expanded(
          child: _MetricPanel(
            label: 'AVG ACCURACY',
            value: '${(avgAccuracy * 100).round()}%',
            icon: Icons.gps_fixed,
            color: LandingTokens.signal,
            skin: skin,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricPanel(
            label: 'AVG TIME',
            value: '${avgTime}ms',
            icon: Icons.timer,
            color: LandingTokens.circuit,
            skin: skin,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricPanel(
            label: 'TOTAL ATTEMPTS',
            value: totalAttempts.toString(),
            icon: Icons.repeat,
            color: const Color(0xFF9E9CFF),
            skin: skin,
          ),
        ),
      ],
    );
  }
}

class _MetricPanel extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final NoirSkin skin;

  const _MetricPanel({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: LandingTokens.mono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: skin.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: LandingTokens.label(fontSize: 7, color: color),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSummaryCard extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;
  final VoidCallback onTap;

  const _AchievementsSummaryCard({
    required this.user,
    required this.skin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = user.achievementIds.length;
    return GestureDetector(
      onTap: onTap,
      child: NoirPanel(
        skin: skin,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: const Color(0xFFFFD700), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACHIEVEMENTS UNLOCKED',
                    style: LandingTokens.label(
                      fontSize: 9,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total badges earned',
                    style: LandingTokens.display(fontSize: 18),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: skin.faint, size: 18),
          ],
        ),
      ),
    );
  }
}

class CinematicBackdrop extends StatelessWidget {
  const CinematicBackdrop({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0A0500),
          const Color(0xFF1A1015),
          const Color(0xFF0A0500),
        ],
      ),
    ),
  );
}
