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

/// Enhanced performance report with:
/// - Fully responsive design (mobile, tablet, desktop)
/// - PDF export functionality
/// - Interactive charts and graphs
/// - Full-width layouts with minimal spacing
/// - Live account updates
class PerformanceReportEnhanced extends StatefulWidget {
  final UserSession user;
  final String? uid;
  final UserRepository? repository;
  final VoidCallback onBack;

  const PerformanceReportEnhanced({
    super.key,
    required this.user,
    required this.uid,
    required this.repository,
    required this.onBack,
  });

  @override
  State<PerformanceReportEnhanced> createState() =>
      _PerformanceReportEnhancedState();
}

class _PerformanceReportEnhancedState extends State<PerformanceReportEnhanced> {
  late UserSession _reportUser;
  bool _refreshing = false;
  bool _remoteLoaded = false;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _reportUser = widget.user;
    _refreshFromFirestore();
  }

  @override
  void didUpdateWidget(covariant PerformanceReportEnhanced oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _reportUser = widget.user;
    }
    if (oldWidget.uid != widget.uid) _refreshFromFirestore();
  }

  Future<void> _refreshFromFirestore() async {
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
    setState(() => _exporting = true);
    try {
      // TODO: Implement PDF export using pdf package
      // For now, show a snackbar indicating the feature
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF export feature coming soon'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
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
    final progression = Progression(_reportUser.xp);
    final completed = _completedModules.length;
    final total = Curriculum.modules.length;
    final completionRate = total == 0 ? 0.0 : completed / total;
    final tracked = _trackedModules.length;
    final perfectRuns = _trackedModules
        .where((entry) => entry.value.accuracy >= 0.9)
        .length;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const _CinematicBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 0 : 16,
                  vertical: isMobile ? 0 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with actions
                    _ReportHeader(
                      user: _reportUser,
                      refreshing: _refreshing,
                      exporting: _exporting,
                      remoteLoaded: _remoteLoaded,
                      onRefresh: _refreshFromFirestore,
                      onExport: _exportToPdf,
                      onBack: widget.onBack,
                      skin: skin,
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 0 : 16),

                    // Quick metrics grid - full width on mobile
                    _ResponsiveMetricsGrid(
                      skin: skin,
                      metrics: [
                        _MetricData(
                          icon: Icons.track_changes,
                          color: LandingTokens.signal,
                          value: '${(completionRate * 100).round()}%',
                          label: 'CURRICULUM',
                          detail: '$completed / $total',
                        ),
                        _MetricData(
                          icon: Icons.gps_fixed,
                          color: LandingTokens.ember,
                          value: '${(_averageAccuracy * 100).round()}%',
                          label: 'ACCURACY',
                          detail: '$tracked modules',
                        ),
                        _MetricData(
                          icon: Icons.repeat,
                          color: const Color(0xFF9E9CFF),
                          value: '$_totalAttempts',
                          label: 'ATTEMPTS',
                          detail: '$perfectRuns 90%+',
                        ),
                        _MetricData(
                          icon: Icons.timer_outlined,
                          color: LandingTokens.circuit,
                          value: _formatDuration(_fastestMs),
                          label: 'FASTEST',
                          detail: 'Best clear',
                        ),
                      ],
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 0 : 16),

                    // Charts section - full width
                    _ChartsSection(
                      user: _reportUser,
                      trackedModules: _trackedModules,
                      completionRate: completionRate,
                      averageAccuracy: _averageAccuracy,
                      skin: skin,
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 0 : 16),

                    // Momentum & Signal panels
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 800;
                        return wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _MomentumPanel(
                                      skin: skin,
                                      user: _reportUser,
                                      progression: progression,
                                      completionRate: completionRate,
                                      averageScoreRatio: _averageScoreRatio,
                                    ),
                                  ),
                                  SizedBox(width: isMobile ? 0 : 16),
                                  Expanded(
                                    child: _SignalPanel(
                                      skin: skin,
                                      user: _reportUser,
                                      fastestMs: _fastestMs,
                                      tracked: tracked,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _MomentumPanel(
                                    skin: skin,
                                    user: _reportUser,
                                    progression: progression,
                                    completionRate: completionRate,
                                    averageScoreRatio: _averageScoreRatio,
                                  ),
                                  SizedBox(height: isMobile ? 0 : 16),
                                  _SignalPanel(
                                    skin: skin,
                                    user: _reportUser,
                                    fastestMs: _fastestMs,
                                    tracked: tracked,
                                  ),
                                ],
                              );
                      },
                    ),
                    SizedBox(height: isMobile ? 0 : 16),

                    // Track performance
                    _TrackPerformancePanel(
                      user: _reportUser,
                      skin: skin,
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 0 : 16),

                    // Module ledger
                    _ModuleLedger(
                      modules: _completedModules,
                      user: _reportUser,
                      skin: skin,
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 0 : 12),
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

class _ReportHeader extends StatelessWidget {
  final UserSession user;
  final bool refreshing;
  final bool exporting;
  final bool remoteLoaded;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final VoidCallback onBack;
  final NoirSkin skin;
  final bool isMobile;

  const _ReportHeader({
    required this.user,
    required this.refreshing,
    required this.exporting,
    required this.remoteLoaded,
    required this.onRefresh,
    required this.onExport,
    required this.onBack,
    required this.skin,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: skin.panelRaised,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 12 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.displayName.toUpperCase()} // PERFORMANCE REPORT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.label(
                        fontSize: isMobile ? 8 : 10,
                        color: LandingTokens.ember,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      'Your learning analytics, visualized',
                      style: LandingTokens.display(
                        fontSize: isMobile ? 18 : 24,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onBack,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 14),

          // Action buttons row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.refresh,
                  label: 'SYNC',
                  onPressed: refreshing ? null : onRefresh,
                  busy: refreshing,
                  isMobile: isMobile,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                _ActionButton(
                  icon: Icons.file_download,
                  label: 'PDF',
                  onPressed: exporting ? null : onExport,
                  busy: exporting,
                  isMobile: isMobile,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: remoteLoaded
                        ? LandingTokens.signal.withValues(alpha: 0.1)
                        : LandingTokens.ember.withValues(alpha: 0.1),
                    border: Border.all(
                      color: remoteLoaded
                          ? LandingTokens.signal.withValues(alpha: 0.5)
                          : LandingTokens.ember.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    refreshing
                        ? 'SYNCING'
                        : remoteLoaded
                        ? 'LIVE DATA'
                        : 'ACCOUNT CACHE',
                    style: LandingTokens.label(
                      fontSize: isMobile ? 7 : 8,
                      color: remoteLoaded
                          ? LandingTokens.signal
                          : LandingTokens.ember,
                    ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool isMobile;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.busy,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    return OutlinedButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy ? SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(skin.text),
        ),
      ) : Icon(icon, size: 16),
      label: Text(label, style: TextStyle(fontSize: isMobile ? 11 : 12)),
    );
  }
}

class _ResponsiveMetricsGrid extends StatelessWidget {
  final NoirSkin skin;
  final List<_MetricData> metrics;
  final bool isMobile;

  const _ResponsiveMetricsGrid({
    required this.skin,
    required this.metrics,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final metric in metrics)
              Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: _MetricCardCompact(data: metric, skin: skin),
              ),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        for (final metric in metrics)
          _MetricCard(data: metric, skin: skin),
      ],
    );
  }
}

class _MetricData {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String detail;

  const _MetricData({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.detail,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  final NoirSkin skin;

  const _MetricCard({required this.data, required this.skin});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: skin.panelRaised,
      border: Border.all(color: skin.border),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(data.icon, color: data.color, size: 18),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.value,
              style: LandingTokens.mono(
                fontSize: 16,
                color: skin.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              style: LandingTokens.label(fontSize: 7, color: data.color),
            ),
            const SizedBox(height: 2),
            Text(
              data.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.body(fontSize: 9),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MetricCardCompact extends StatelessWidget {
  final _MetricData data;
  final NoirSkin skin;

  const _MetricCardCompact({required this.data, required this.skin});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: skin.panelRaised,
      border: Border.all(color: skin.border),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(data.icon, color: data.color, size: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.mono(
                fontSize: 12,
                color: skin.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.label(fontSize: 6, color: data.color),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ChartsSection extends StatelessWidget {
  final UserSession user;
  final List<MapEntry<CurriculumModule, ModulePerformance>>
      trackedModules;
  final double completionRate;
  final double averageAccuracy;
  final NoirSkin skin;
  final bool isMobile;

  const _ChartsSection({
    required this.user,
    required this.trackedModules,
    required this.completionRate,
    required this.averageAccuracy,
    required this.skin,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (trackedModules.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
        color: skin.panelRaised,
        child: Text(
          'Complete modules to see performance charts',
          style: LandingTokens.body(fontSize: 12),
        ),
      );
    }

    return Column(
      children: [
        if (!isMobile)
          Row(
            children: [
              Expanded(
                child: _AccuracyChart(
                  averageAccuracy: averageAccuracy,
                  skin: skin,
                ),
              ),
              SizedBox(width: isMobile ? 0 : 16),
              Expanded(
                child: _CompletionChart(
                  completionRate: completionRate,
                  skin: skin,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _AccuracyChart(
                averageAccuracy: averageAccuracy,
                skin: skin,
              ),
              SizedBox(height: isMobile ? 0 : 16),
              _CompletionChart(
                completionRate: completionRate,
                skin: skin,
              ),
            ],
          ),
      ],
    );
  }
}

class _AccuracyChart extends StatelessWidget {
  final double averageAccuracy;
  final NoirSkin skin;

  const _AccuracyChart({
    required this.averageAccuracy,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (averageAccuracy * 100).round();
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
          Row(
            children: [
              Icon(Icons.gps_fixed, color: LandingTokens.ember, size: 18),
              const SizedBox(width: 8),
              Text(
                '// ACCURACY',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.ember,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: averageAccuracy.clamp(0, 1),
                    strokeWidth: 8,
                    backgroundColor: skin.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(
                        const Color(0xFFFF4D5E),
                        LandingTokens.signal,
                        averageAccuracy,
                      ) ??
                          LandingTokens.signal,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: LandingTokens.display(fontSize: 28),
                    ),
                    Text(
                      'AVERAGE',
                      style: LandingTokens.label(
                        fontSize: 8,
                        color: LandingTokens.ember,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Based on ${averageAccuracy > 0.9 ? 'consistent' : averageAccuracy > 0.7 ? 'solid' : 'developing'} performance across your completed modules.',
            style: LandingTokens.body(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CompletionChart extends StatelessWidget {
  final double completionRate;
  final NoirSkin skin;

  const _CompletionChart({
    required this.completionRate,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (completionRate * 100).round();
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
          Row(
            children: [
              Icon(Icons.track_changes, color: LandingTokens.signal, size: 18),
              const SizedBox(width: 8),
              Text(
                '// COMPLETION',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.signal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: completionRate.clamp(0, 1),
                    strokeWidth: 8,
                    backgroundColor: skin.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      LandingTokens.signal,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: LandingTokens.display(fontSize: 28),
                    ),
                    Text(
                      'COMPLETE',
                      style: LandingTokens.label(
                        fontSize: 8,
                        color: LandingTokens.signal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You are $percentage% through the full curriculum. Keep going!',
            style: LandingTokens.body(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MomentumPanel extends StatelessWidget {
  final NoirSkin skin;
  final UserSession user;
  final Progression progression;
  final double completionRate;
  final double averageScoreRatio;

  const _MomentumPanel({
    required this.skin,
    required this.user,
    required this.progression,
    required this.completionRate,
    required this.averageScoreRatio,
  });

  @override
  Widget build(BuildContext context) {
    final next = progression.nextTier;
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
          Row(
            children: [
              Icon(Icons.speed, color: LandingTokens.ember, size: 18),
              const SizedBox(width: 8),
              Text(
                '// MOMENTUM',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.ember,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressLine(
            label: 'CURRICULUM COVERAGE',
            value: completionRate,
            valueLabel: '${(completionRate * 100).round()}%',
            color: LandingTokens.signal,
            skin: skin,
          ),
          const SizedBox(height: 16),
          _ProgressLine(
            label: 'SCORE QUALITY',
            value: averageScoreRatio,
            valueLabel: '${(averageScoreRatio * 100).round()}%',
            color: LandingTokens.ember,
            skin: skin,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MiniStat(
                label: 'STREAK',
                value: '${user.streak}d',
                skin: skin,
              ),
              _MiniStat(
                label: 'BEST',
                value: '${user.bestStreak}d',
                skin: skin,
              ),
              _MiniStat(
                label: 'LV',
                value: '${progression.level}',
                skin: skin,
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 12),
            Text(
              '${progression.xpToNextTier} XP until ${next.label.toUpperCase()}',
              style: LandingTokens.label(fontSize: 9, color: skin.faint),
            ),
          ],
        ],
      ),
    );
  }
}

class _SignalPanel extends StatelessWidget {
  final NoirSkin skin;
  final UserSession user;
  final int? fastestMs;
  final int tracked;

  const _SignalPanel({
    required this.skin,
    required this.user,
    required this.fastestMs,
    required this.tracked,
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
          Row(
            children: [
              Icon(Icons.radar, color: LandingTokens.circuit, size: 18),
              const SizedBox(width: 8),
              Text(
                '// SIGNAL',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.circuit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ReadoutRow(label: 'XP BANKED', value: '${user.xp}', skin: skin),
          _ReadoutRow(label: 'CLEARS', value: '$tracked', skin: skin),
          _ReadoutRow(
            label: 'FASTEST',
            value: _formatDuration(fastestMs),
            skin: skin,
          ),
          _ReadoutRow(label: 'BADGES', value: '${user.badges.length}', skin: skin),
          _ReadoutRow(
            label: 'LAST ACTIVE',
            value: _formatDate(user.lastActivityDate),
            skin: skin,
          ),
        ],
      ),
    );
  }
}

class _TrackPerformancePanel extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;
  final bool isMobile;

  const _TrackPerformancePanel({
    required this.user,
    required this.skin,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
              Icon(Icons.account_tree_outlined, color: LandingTokens.circuit, size: 18),
              const SizedBox(width: 8),
              Text(
                '// TRACK PERFORMANCE',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.circuit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: isMobile ? 2 : 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: isMobile ? 8 : 10,
            crossAxisSpacing: isMobile ? 8 : 10,
            childAspectRatio: isMobile ? 1.5 : 1.2,
            children: [
              for (final track in LanguageTrack.values)
                _TrackTile(track: track, user: user, skin: skin),
            ],
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
    final done = modules
        .where((module) => user.completedModuleIds.contains(module.id))
        .length;
    final ratio = modules.isEmpty ? 0.0 : done / modules.length;
    final scores = [
      for (final module in modules)
        if (user.moduleScores[module.id] != null)
          (user.moduleScores[module.id]! / module.xpReward).clamp(0.0, 1.0),
    ];
    final quality = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a + b) / scores.length;
    final color = _trackColor(track);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        border: Border.all(color: skin.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(_trackIcon(track), size: 14, color: color),
              Text(
                '$done/${modules.length}',
                style: LandingTokens.mono(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: skin.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(height: 4),
          Text(
            track.shortLabel.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LandingTokens.label(fontSize: 8, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            'QUALITY ${(quality * 100).round()}%  //  ${modules.length} MISSIONS',
            style: LandingTokens.label(fontSize: 8, color: skin.faint),
          ),
        ],
      ),
    );
  }
}

class _ModuleLedger extends StatelessWidget {
  final List<CurriculumModule> modules;
  final UserSession user;
  final NoirSkin skin;
  final bool isMobile;

  const _ModuleLedger({
    required this.modules,
    required this.user,
    required this.skin,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
              Icon(Icons.receipt_long_outlined, color: LandingTokens.circuit, size: 18),
              const SizedBox(width: 8),
              Text(
                '// MODULE LEDGER',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.circuit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (modules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Complete your first module to see the ledger',
                style: LandingTokens.body(fontSize: 12),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 12, color: skin.border),
              itemBuilder: (context, index) {
                final module = modules[index];
                final performance = user.modulePerformance[module.id];
                final score = user.moduleScores[module.id] ?? performance?.score ?? 0;
                return _ModuleRowCompact(
                  module: module,
                  score: score,
                  performance: performance,
                  skin: skin,
                  isMobile: isMobile,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ModuleRowCompact extends StatelessWidget {
  final CurriculumModule module;
  final int score;
  final ModulePerformance? performance;
  final NoirSkin skin;
  final bool isMobile;

  const _ModuleRowCompact({
    required this.module,
    required this.score,
    required this.performance,
    required this.skin,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile || constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                module.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: skin.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${module.track.shortLabel.toUpperCase()} • ${_formatDate(performance?.lastCompletedAt)}',
                style: LandingTokens.label(fontSize: 8, color: skin.faint),
              ),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LedgerStat(label: 'SCORE', value: '$score/${module.xpReward}', skin: skin),
                  _LedgerStat(label: 'TRIES', value: '${performance?.attempts ?? 1}', skin: skin),
                  _LedgerStat(label: 'TIME', value: _formatDuration(performance?.executionMs), skin: skin),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: skin.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${module.track.shortLabel.toUpperCase()} • ${_formatDate(performance?.lastCompletedAt)}',
                    style: LandingTokens.label(fontSize: 8, color: skin.faint),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LedgerStat(label: 'SCORE', value: '$score/${module.xpReward}', skin: skin),
                SizedBox(width: 16),
                _LedgerStat(label: 'TRIES', value: '${performance?.attempts ?? 1}', skin: skin),
                SizedBox(width: 16),
                _LedgerStat(label: 'TIME', value: _formatDuration(performance?.executionMs), skin: skin),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final double value;
  final String valueLabel;
  final Color color;
  final NoirSkin skin;

  const _ProgressLine({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: LandingTokens.label(fontSize: 8, color: skin.faint)),
          Text(
            valueLabel,
            style: LandingTokens.mono(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: 6,
          backgroundColor: skin.border,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ],
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final NoirSkin skin;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: LandingTokens.mono(
          fontSize: 12,
          color: skin.text,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: LandingTokens.label(fontSize: 7, color: skin.faint)),
    ],
  );
}

class _ReadoutRow extends StatelessWidget {
  final String label;
  final String value;
  final NoirSkin skin;

  const _ReadoutRow({
    required this.label,
    required this.value,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: LandingTokens.label(fontSize: 8, color: skin.faint)),
        Text(
          value,
          style: LandingTokens.mono(
            fontSize: 11,
            color: skin.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _LedgerStat extends StatelessWidget {
  final String label;
  final String value;
  final NoirSkin skin;

  const _LedgerStat({
    required this.label,
    required this.value,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: LandingTokens.mono(
          fontSize: 10,
          color: skin.text,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 2),
      Text(label, style: LandingTokens.label(fontSize: 7, color: skin.faint)),
    ],
  );
}

class _CinematicBackdrop extends StatelessWidget {
  const _CinematicBackdrop();

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

String _formatDate(Object? raw) {
  DateTime? date;
  if (raw is DateTime) date = raw;
  if (raw is String) date = DateTime.tryParse(raw);
  if (date == null) return 'NO DATA';
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
}
