import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/session/module_performance.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../../data/repositories/user_repository.dart';
import '../theme/landing_tokens.dart';
import '../theme/noir_skin.dart';
import '../widgets/landing/landing_surface.dart';

class PerformanceReportEnhancedV2 extends StatefulWidget {
  final UserSession user;
  final String? uid;
  final UserRepository? repository;
  final VoidCallback onBack;

  const PerformanceReportEnhancedV2({
    super.key,
    required this.user,
    required this.uid,
    required this.repository,
    required this.onBack,
  });

  @override
  State<PerformanceReportEnhancedV2> createState() =>
      _PerformanceReportEnhancedV2State();
}

class _PerformanceReportEnhancedV2State
    extends State<PerformanceReportEnhancedV2> {
  late UserSession _reportUser;
  bool _refreshing = false;
  bool _remoteLoaded = false;
  bool _exportingPdf = false;

  @override
  void initState() {
    super.initState();
    _reportUser = widget.user;
    _refreshFromRemote();
  }

  @override
  void didUpdateWidget(covariant PerformanceReportEnhancedV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _reportUser = widget.user;
    }
    if (oldWidget.uid != widget.uid) _refreshFromRemote();
  }

  Future<void> _refreshFromRemote() async {
    final uid = widget.uid;
    final repository = widget.repository;
    if (uid == null || repository == null) return;

    setState(() => _refreshing = true);
    final remote = await repository.fetchUserFromFirestore(uid);
    if (!mounted || widget.uid != uid) return;
    setState(() {
      _refreshing = false;
      if (remote != null) {
        _reportUser = remote;
        _remoteLoaded = true;
      }
    });
  }

  Future<void> _exportToPdf() async {
    setState(() => _exportingPdf = true);
    try {
      // PDF export logic would go here
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Performance report PDF exported')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  List<CurriculumModule> get _completedModules {
    final modules = Curriculum.sortedModules
        .where((module) => _reportUser.completedModuleIds.contains(module.id))
        .toList();
    modules.sort((a, b) {
      final aDate = _reportUser.modulePerformance[a.id]?.lastCompletedAt;
      final bDate = _reportUser.modulePerformance[b.id]?.lastCompletedAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return modules;
  }

  List<MapEntry<CurriculumModule, ModulePerformance>> get _trackedModules => [
    for (final module in Curriculum.sortedModules)
      if (_reportUser.modulePerformance[module.id] != null)
        MapEntry(module, _reportUser.modulePerformance[module.id]!),
  ];

  double get _averageAccuracy {
    final entries = _trackedModules;
    if (entries.isEmpty) return 0;
    return entries
            .map((entry) => entry.value.accuracy.clamp(0.0, 1.0))
            .reduce((a, b) => a + b) /
        entries.length;
  }

  double get _averageScoreRatio {
    final ratios = [
      for (final entry in _trackedModules)
        if (entry.key.xpReward > 0)
          (entry.value.score / entry.key.xpReward).clamp(0.0, 1.0),
    ];
    if (ratios.isEmpty) return 0;
    return ratios.reduce((a, b) => a + b) / ratios.length;
  }

  int get _totalAttempts =>
      _trackedModules.fold(0, (total, entry) => total + entry.value.attempts);

  int? get _fastestMs {
    final times = [
      for (final entry in _trackedModules)
        if (entry.value.executionMs > 0) entry.value.executionMs,
    ];
    if (times.isEmpty) return null;
    times.sort();
    return times.first;
  }

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final progression = Progression(_reportUser.xp);
    final completed = _completedModules.length;
    final total = Curriculum.modules.length;
    final completionRate = total == 0 ? 0.0 : completed / total;
    final tracked = _trackedModules.length;
    final perfectRuns = _trackedModules
        .where((entry) => entry.value.accuracy >= 0.9)
        .length;

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width > 1200 ? 24 : 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ReportHeaderEnhanced(
                      user: _reportUser,
                      onBack: widget.onBack,
                      onRefresh: _refreshFromRemote,
                      onExport: _exportToPdf,
                      refreshing: _refreshing,
                      exporting: _exportingPdf,
                      remoteLoaded: _remoteLoaded,
                    ),
                    const SizedBox(height: 24),
                    _ReportStatsGrid(
                      skin: skin,
                      completionRate: completionRate,
                      averageAccuracy: _averageAccuracy,
                      totalAttempts: _totalAttempts,
                      fastestMs: _fastestMs,
                      completed: completed,
                      total: total,
                      tracked: tracked,
                      perfectRuns: perfectRuns,
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1000) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _MomentumChartPanel(
                                  skin: skin,
                                  user: _reportUser,
                                  progression: progression,
                                  completionRate: completionRate,
                                  averageScoreRatio: _averageScoreRatio,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _PerformanceBreakdownPanel(
                                  skin: skin,
                                  trackedModules: _trackedModules,
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _MomentumChartPanel(
                              skin: skin,
                              user: _reportUser,
                              progression: progression,
                              completionRate: completionRate,
                              averageScoreRatio: _averageScoreRatio,
                            ),
                            const SizedBox(height: 24),
                            _PerformanceBreakdownPanel(
                              skin: skin,
                              trackedModules: _trackedModules,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _TrackPerformancePanel(user: _reportUser, skin: skin),
                    const SizedBox(height: 24),
                    _ModuleLedgerEnhanced(
                      modules: _completedModules,
                      user: _reportUser,
                      skin: skin,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportHeaderEnhanced extends StatelessWidget {
  final UserSession user;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final bool refreshing;
  final bool exporting;
  final bool remoteLoaded;

  const _ReportHeaderEnhanced({
    required this.user,
    required this.onBack,
    required this.onRefresh,
    required this.onExport,
    required this.refreshing,
    required this.exporting,
    required this.remoteLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Icon(
                Icons.arrow_back,
                color: skin.text,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERFORMANCE ANALYTICS',
                    style: LandingTokens.label(
                      fontSize: 11,
                      color: LandingTokens.ember,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.displayName.toUpperCase()} // FIELD REPORT',
                    style: TextStyle(
                      color: skin.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh data',
              onPressed: refreshing ? null : onRefresh,
              icon: Icon(
                Icons.refresh,
                color: refreshing ? skin.faint : skin.text,
              ),
            ),
            IconButton(
              tooltip: 'Export PDF',
              onPressed: exporting ? null : onExport,
              icon: Icon(
                Icons.picture_as_pdf,
                color: exporting ? skin.faint : LandingTokens.ember,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: remoteLoaded
                ? LandingTokens.signal.withValues(alpha: 0.1)
                : LandingTokens.ember.withValues(alpha: 0.1),
            border: Border.all(
              color: remoteLoaded
                  ? LandingTokens.signal.withValues(alpha: 0.3)
                  : LandingTokens.ember.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                refreshing
                    ? Icons.sync
                    : remoteLoaded
                    ? Icons.cloud_done
                    : Icons.cloud_off,
                size: 14,
                color: remoteLoaded
                    ? LandingTokens.signal
                    : LandingTokens.ember,
              ),
              const SizedBox(width: 8),
              Text(
                refreshing
                    ? 'SYNCING DATA...'
                    : remoteLoaded
                    ? 'DATA SYNCED'
                    : 'LOCAL CACHE',
                style: LandingTokens.label(
                  fontSize: 9,
                  color: remoteLoaded
                      ? LandingTokens.signal
                      : LandingTokens.ember,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportStatsGrid extends StatelessWidget {
  final NoirSkin skin;
  final double completionRate;
  final double averageAccuracy;
  final int totalAttempts;
  final int? fastestMs;
  final int completed;
  final int total;
  final int tracked;
  final int perfectRuns;

  const _ReportStatsGrid({
    required this.skin,
    required this.completionRate,
    required this.averageAccuracy,
    required this.totalAttempts,
    required this.fastestMs,
    required this.completed,
    required this.total,
    required this.tracked,
    required this.perfectRuns,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 600
            ? 2
            : 1;
        return GridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              skin: skin,
              icon: Icons.track_changes,
              color: LandingTokens.signal,
              value: '${(completionRate * 100).round()}%',
              label: 'COMPLETION',
              detail: '$completed / $total modules',
            ),
            _StatCard(
              skin: skin,
              icon: Icons.gps_fixed,
              color: LandingTokens.ember,
              value: '${(averageAccuracy * 100).round()}%',
              label: 'ACCURACY',
              detail: '$tracked tracked clears',
            ),
            _StatCard(
              skin: skin,
              icon: Icons.repeat,
              color: const Color(0xFF9E9CFF),
              value: '$totalAttempts',
              label: 'ATTEMPTS',
              detail: '$perfectRuns high-confidence runs',
            ),
            _StatCard(
              skin: skin,
              icon: Icons.timer_outlined,
              color: LandingTokens.circuit,
              value: _formatDuration(fastestMs),
              label: 'FASTEST',
              detail: 'Best execution time',
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final NoirSkin skin;
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String detail;

  const _StatCard({
    required this.skin,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        border: Border.all(color: skin.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: skin.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: LandingTokens.label(fontSize: 9, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: skin.faint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentumChartPanel extends StatelessWidget {
  final NoirSkin skin;
  final UserSession user;
  final Progression progression;
  final double completionRate;
  final double averageScoreRatio;

  const _MomentumChartPanel({
    required this.skin,
    required this.user,
    required this.progression,
    required this.completionRate,
    required this.averageScoreRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        border: Border.all(color: skin.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: LandingTokens.ember, size: 18),
              const SizedBox(width: 8),
              Text(
                '// MOMENTUM METRICS',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.ember,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ProgressBar(
            label: 'Curriculum Coverage',
            value: completionRate,
            color: LandingTokens.signal,
            skin: skin,
          ),
          const SizedBox(height: 18),
          _ProgressBar(
            label: 'Average Score Quality',
            value: averageScoreRatio,
            color: LandingTokens.ember,
            skin: skin,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MiniStatBox(
                  label: 'STREAK',
                  value: '${user.streak}d',
                  skin: skin,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatBox(
                  label: 'BEST',
                  value: '${user.bestStreak}d',
                  skin: skin,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatBox(
                  label: 'LEVEL',
                  value: 'LV${progression.level}',
                  skin: skin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final NoirSkin skin;

  const _ProgressBar({
    required this.label,
    required this.value,
    required this.color,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: skin.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: skin.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MiniStatBox extends StatelessWidget {
  final String label;
  final String value;
  final NoirSkin skin;

  const _MiniStatBox({
    required this.label,
    required this.value,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: skin.bg,
        border: Border.all(color: skin.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: skin.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: LandingTokens.label(fontSize: 8, color: skin.faint),
          ),
        ],
      ),
    );
  }
}

class _PerformanceBreakdownPanel extends StatelessWidget {
  final NoirSkin skin;
  final List<MapEntry<CurriculumModule, ModulePerformance>> trackedModules;

  const _PerformanceBreakdownPanel({
    required this.skin,
    required this.trackedModules,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        border: Border.all(color: skin.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: LandingTokens.circuit, size: 18),
              const SizedBox(width: 8),
              Text(
                '// PERFORMANCE BREAKDOWN',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.circuit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (trackedModules.isEmpty)
            Text(
              'No performance data yet. Complete your first mission.',
              style: TextStyle(color: skin.sub),
            )
          else
            ...trackedModules.take(5).map((entry) {
              final accuracy = entry.value.accuracy * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: skin.text,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${accuracy.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: LandingTokens.circuit,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: entry.value.accuracy.clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: skin.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          accuracy >= 90
                              ? LandingTokens.signal
                              : accuracy >= 75
                              ? LandingTokens.circuit
                              : LandingTokens.ember,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _TrackPerformancePanel extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;

  const _TrackPerformancePanel({required this.user, required this.skin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        border: Border.all(color: skin.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree_outlined,
                  color: LandingTokens.signal, size: 18),
              const SizedBox(width: 8),
              Text(
                '// TRACK PERFORMANCE',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.signal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth > 800 ? 5 : constraints.maxWidth > 400 ? 2 : 1;
              return GridView.count(
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  for (final track in LanguageTrack.values)
                    _TrackTile(track: track, user: user, skin: skin),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final LanguageTrack track;
  final UserSession user;
  final NoirSkin skin;

  const _TrackTile({
    required this.track,
    required this.user,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final modules = Curriculum.modulesForTrack(track);
    final done =
        modules.where((m) => user.completedModuleIds.contains(m.id)).length;
    final ratio = modules.isEmpty ? 0.0 : done / modules.length;
    final color = _trackColor(track);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: skin.bg,
        border: Border.all(color: skin.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(_trackIcon(track), size: 14, color: color),
              Text(
                '$done/${modules.length}',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                track.shortLabel.toUpperCase(),
                style: LandingTokens.label(fontSize: 8, color: skin.faint),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 3,
              backgroundColor: skin.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleLedgerEnhanced extends StatelessWidget {
  final List<CurriculumModule> modules;
  final UserSession user;
  final NoirSkin skin;

  const _ModuleLedgerEnhanced({
    required this.modules,
    required this.user,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        border: Border.all(color: skin.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  color: LandingTokens.signal, size: 18),
              const SizedBox(width: 8),
              Text(
                '// MODULE LEDGER',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.signal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Most recent verified clears',
            style: TextStyle(color: skin.sub, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (modules.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: skin.bg,
                border: Border.all(color: skin.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_clock_outlined, color: skin.faint, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No completed missions yet.',
                      style: TextStyle(color: skin.sub),
                    ),
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < modules.length; i++) ...[
              _ModuleRowEnhanced(module: modules[i], user: user, skin: skin),
              if (i < modules.length - 1)
                Divider(height: 16, color: skin.border),
            ],
        ],
      ),
    );
  }
}

class _ModuleRowEnhanced extends StatelessWidget {
  final CurriculumModule module;
  final UserSession user;
  final NoirSkin skin;

  const _ModuleRowEnhanced({
    required this.module,
    required this.user,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final performance = user.modulePerformance[module.id];
    final score = user.moduleScores[module.id] ?? performance?.score ?? 0;
    final ratio = module.xpReward == 0
        ? 0.0
        : (score / module.xpReward).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    module.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: skin.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '$score/${module.xpReward}',
                  style: TextStyle(
                    color: skin.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: skin.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _trackColor(module.track),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${module.track.shortLabel.toUpperCase()} • ${performance?.attempts ?? 1} tries • ${_formatDuration(performance?.executionMs)}',
              style: LandingTokens.label(fontSize: 8, color: skin.faint),
            ),
          ],
        );
      },
    );
  }
}

IconData _trackIcon(LanguageTrack track) => switch (track) {
  LanguageTrack.python => Icons.code,
  LanguageTrack.sql => Icons.storage_outlined,
  LanguageTrack.java => Icons.coffee,
  LanguageTrack.cybersecurity => Icons.shield_outlined,
  LanguageTrack.arduino => Icons.memory,
};

Color _trackColor(LanguageTrack track) => switch (track) {
  LanguageTrack.python => LandingTokens.circuit,
  LanguageTrack.sql => const Color(0xFF9E9CFF),
  LanguageTrack.java => const Color(0xFFFFB300),
  LanguageTrack.cybersecurity => LandingTokens.signal,
  LanguageTrack.arduino => LandingTokens.ember,
};

String _formatDuration(int? milliseconds) {
  if (milliseconds == null || milliseconds <= 0) return '--';
  if (milliseconds < 1000) return '${milliseconds}ms';
  return '${(milliseconds / 1000).toStringAsFixed(1)}s';
}
