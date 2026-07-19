import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/session/module_performance.dart';
import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../../core/social/performance_report_pdf.dart';
import '../../data/repositories/user_repository.dart';
import '../theme/landing_tokens.dart';
import '../theme/noir_skin.dart';
import '../widgets/landing/landing_surface.dart';

/// Account-owned learning analytics. The view keeps its displayed snapshot in
/// step with account activity from another tab or device while it is open.
class PerformanceReportScreen extends StatefulWidget {
  final UserSession user;
  final String? uid;
  final UserRepository? repository;
  final VoidCallback onBack;

  const PerformanceReportScreen({
    super.key,
    required this.user,
    required this.uid,
    required this.repository,
    required this.onBack,
  });

  @override
  State<PerformanceReportScreen> createState() =>
      _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends State<PerformanceReportScreen> {
  late UserSession _reportUser;
  StreamSubscription<UserSession?>? _accountSubscription;
  bool _refreshing = false;
  bool _remoteLoaded = false;
  bool _exportingPdf = false;
  String? _syncError;

  @override
  void initState() {
    super.initState();
    _reportUser = widget.user;
    _subscribeToAccountUpdates();
    _refreshReportData();
  }

  @override
  void didUpdateWidget(covariant PerformanceReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _reportUser = widget.user;
    }
    if (oldWidget.uid != widget.uid ||
        oldWidget.repository != widget.repository) {
      _subscribeToAccountUpdates();
      _refreshReportData();
    }
  }

  void _subscribeToAccountUpdates() {
    _accountSubscription?.cancel();
    _accountSubscription = null;

    final uid = widget.uid;
    final repository = widget.repository;
    if (uid == null || repository == null) return;

    _accountSubscription = repository
        .streamUserFromFirestore(uid)
        .listen(
          (account) {
            if (!mounted || widget.uid != uid || account == null) return;
            setState(() {
              _reportUser = account;
              _remoteLoaded = true;
              _syncError = null;
            });
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!mounted || widget.uid != uid) return;
            setState(
              () => _syncError = 'Live updates are temporarily unavailable.',
            );
          },
        );
  }

  Future<void> _refreshReportData() async {
    final uid = widget.uid;
    final repository = widget.repository;
    if (uid == null || repository == null) return;

    if (mounted) {
      setState(() {
        _refreshing = true;
        _syncError = null;
      });
    }

    try {
      final account = await repository.fetchUserFromFirestore(uid);
      if (!mounted || widget.uid != uid || account == null) return;
      setState(() {
        _reportUser = account;
        _remoteLoaded = true;
      });
    } catch (_) {
      if (mounted && widget.uid == uid) {
        setState(() => _syncError = 'Could not refresh the latest activity.');
      }
    } finally {
      if (mounted && widget.uid == uid) {
        setState(() => _refreshing = false);
      }
    }
  }

  Future<void> _exportToPdf() async {
    if (_exportingPdf) return;
    setState(() => _exportingPdf = true);
    try {
      final shared = await PerformanceReportPdf.download(_reportUser);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shared
                ? 'Performance report is ready to save.'
                : 'Performance report export was canceled.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not export the performance report. Try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  @override
  void dispose() {
    _accountSubscription?.cancel();
    super.dispose();
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

  List<_TrendPoint> get _trendPoints {
    final entries = [..._trackedModules]
      ..sort((a, b) {
        final aDate = a.value.lastCompletedAt ?? a.value.firstCompletedAt;
        final bDate = b.value.lastCompletedAt ?? b.value.firstCompletedAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return -1;
        if (bDate == null) return 1;
        return aDate.compareTo(bDate);
      });
    final visibleEntries = entries.length > 12
        ? entries.sublist(entries.length - 12)
        : entries;
    return [
      for (final entry in visibleEntries)
        _TrendPoint(
          title: entry.key.title,
          accuracy: entry.value.accuracy.clamp(0.0, 1.0).toDouble(),
          scoreRatio: entry.key.xpReward == 0
              ? 0.0
              : (entry.value.score / entry.key.xpReward)
                    .clamp(0.0, 1.0)
                    .toDouble(),
        ),
    ];
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

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReportHeader(
                    skin: skin,
                    onBack: widget.onBack,
                    onRefresh: _refreshReportData,
                    onExport: _exportToPdf,
                    refreshing: _refreshing,
                    exporting: _exportingPdf,
                    remoteLoaded: _remoteLoaded,
                    syncError: _syncError,
                  ),
                  const SizedBox(height: 1),
                  _ReportIntro(
                    user: _reportUser,
                    progression: progression,
                    completed: completed,
                    total: total,
                    skin: skin,
                  ),
                  const SizedBox(height: 1),
                  _MetricsGrid(
                    skin: skin,
                    metrics: [
                      _MetricData(
                        icon: Icons.track_changes,
                        color: LandingTokens.signal,
                        value: '${(completionRate * 100).round()}%',
                        label: 'CURRICULUM COMPLETE',
                        detail: '$completed / $total modules',
                      ),
                      _MetricData(
                        icon: Icons.gps_fixed,
                        color: LandingTokens.ember,
                        value: '${(_averageAccuracy * 100).round()}%',
                        label: 'AVERAGE ACCURACY',
                        detail: '$tracked tracked clears',
                      ),
                      _MetricData(
                        icon: Icons.repeat,
                        color: const Color(0xFF9E9CFF),
                        value: '$_totalAttempts',
                        label: 'TOTAL ATTEMPTS',
                        detail: '$perfectRuns high-confidence runs',
                      ),
                      _MetricData(
                        icon: Icons.timer_outlined,
                        color: LandingTokens.circuit,
                        value: _formatDuration(_fastestMs),
                        label: 'FASTEST CLEAR',
                        detail: 'Best recorded execution',
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  _PerformanceTrendPanel(points: _trendPoints, skin: skin),
                  const SizedBox(height: 1),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 840;
                      final momentum = _MomentumPanel(
                        skin: skin,
                        user: _reportUser,
                        progression: progression,
                        completionRate: completionRate,
                        averageScoreRatio: _averageScoreRatio,
                      );
                      final signal = _SignalPanel(
                        skin: skin,
                        user: _reportUser,
                        fastestMs: _fastestMs,
                        tracked: tracked,
                      );
                      return wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: momentum),
                                const SizedBox(width: 1),
                                Expanded(child: signal),
                              ],
                            )
                          : Column(
                              children: [
                                momentum,
                                const SizedBox(height: 1),
                                signal,
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 1),
                  _TrackPerformancePanel(user: _reportUser, skin: skin),
                  const SizedBox(height: 1),
                  _ModuleLedger(
                    modules: _completedModules,
                    user: _reportUser,
                    skin: skin,
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

class _ReportHeader extends StatelessWidget {
  final NoirSkin skin;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final bool refreshing;
  final bool exporting;
  final bool remoteLoaded;
  final String? syncError;

  const _ReportHeader({
    required this.skin,
    required this.onBack,
    required this.onRefresh,
    required this.onExport,
    required this.refreshing,
    required this.exporting,
    required this.remoteLoaded,
    required this.syncError,
  });

  @override
  Widget build(BuildContext context) => NoirPanel(
    skin: skin,
    padding: const EdgeInsets.all(16),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 660;
        final identity = Row(
          children: [
            IconButton(
              tooltip: 'Back to home',
              onPressed: onBack,
              color: skin.text,
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// ACCOUNT ANALYTICS',
                    style: LandingTokens.label(
                      fontSize: 9,
                      color: LandingTokens.ember,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'PERFORMANCE REPORT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LandingTokens.display(
                      fontSize: 22,
                      color: skin.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ReportActionButton(
              icon: Icons.refresh,
              label: 'SYNC LATEST',
              tooltip: 'Sync latest activity',
              busy: refreshing,
              onPressed: refreshing ? null : onRefresh,
              skin: skin,
            ),
            _ReportActionButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'SAVE PDF',
              tooltip: 'Save performance report as PDF',
              busy: exporting,
              onPressed: exporting ? null : onExport,
              skin: skin,
            ),
            _SyncStatus(
              loading: refreshing,
              live: remoteLoaded,
              error: syncError,
              skin: skin,
            ),
          ],
        );
        return compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [identity, const SizedBox(height: 12), actions],
              )
            : Row(
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 16),
                  actions,
                ],
              );
      },
    ),
  );
}

class _ReportActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool busy;
  final VoidCallback? onPressed;
  final NoirSkin skin;

  const _ReportActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.busy,
    required this.onPressed,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: busy
          ? SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: skin.text,
              ),
            )
          : Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: skin.text,
        side: BorderSide(color: skin.borderStrong),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        textStyle: LandingTokens.label(fontSize: 8.5, color: skin.text),
      ),
    ),
  );
}

class _SyncStatus extends StatelessWidget {
  final bool loading;
  final bool live;
  final String? error;
  final NoirSkin skin;

  const _SyncStatus({
    required this.loading,
    required this.live,
    required this.error,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    final label = loading
        ? 'UPDATING'
        : hasError
        ? 'CHECK CONNECTION'
        : live
        ? 'LIVE DATA'
        : 'SAVED DATA';
    final color = hasError
        ? LandingTokens.ember
        : live
        ? LandingTokens.signal
        : skin.faint;
    return Semantics(
      liveRegion: true,
      label: error ?? label,
      child: Tooltip(
        message: error ?? 'Your report updates as activity is saved.',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: LandingTokens.smallRadius,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            label,
            style: LandingTokens.label(fontSize: 8, color: color),
          ),
        ),
      ),
    );
  }
}

class _ReportIntro extends StatelessWidget {
  final UserSession user;
  final Progression progression;
  final int completed;
  final int total;
  final NoirSkin skin;

  const _ReportIntro({
    required this.user,
    required this.progression,
    required this.completed,
    required this.total,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => NoirPanel(
    skin: skin,
    padding: const EdgeInsets.all(20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: LandingTokens.ember.withValues(alpha: 0.12),
            borderRadius: LandingTokens.smallRadius,
            border: Border.all(
              color: LandingTokens.ember.withValues(alpha: 0.5),
            ),
          ),
          child: const Icon(
            Icons.analytics_outlined,
            color: LandingTokens.ember,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.displayName.toUpperCase()} // FIELD REPORT',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LandingTokens.label(
                  fontSize: 10,
                  color: LandingTokens.ember,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Your learning loop, measured.',
                style: LandingTokens.display(fontSize: 24, color: skin.text),
              ),
              const SizedBox(height: 6),
              Text(
                '$completed of $total missions complete • level ${progression.level} • ${user.xp} XP banked',
                style: LandingTokens.body(fontSize: 13, color: skin.sub),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MetricsGrid extends StatelessWidget {
  final NoirSkin skin;
  final List<_MetricData> metrics;

  const _MetricsGrid({required this.skin, required this.metrics});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth > 980
          ? 4
          : constraints.maxWidth > 540
          ? 2
          : 1;
      const gap = 1.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final metric in metrics)
            SizedBox(
              width: width,
              child: _MetricCard(data: metric, skin: skin),
            ),
        ],
      );
    },
  );
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
  Widget build(BuildContext context) => NoirPanel(
    skin: skin,
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.1),
            borderRadius: LandingTokens.smallRadius,
            border: Border.all(color: data.color.withValues(alpha: 0.45)),
          ),
          child: Icon(data.icon, color: data.color, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  data.value,
                  style: LandingTokens.mono(
                    fontSize: 22,
                    color: skin.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.label,
                style: LandingTokens.label(fontSize: 8.5, color: data.color),
              ),
              const SizedBox(height: 3),
              Text(
                data.detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LandingTokens.body(fontSize: 11, color: skin.faint),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TrendPoint {
  final String title;
  final double accuracy;
  final double scoreRatio;

  const _TrendPoint({
    required this.title,
    required this.accuracy,
    required this.scoreRatio,
  });
}

class _PerformanceTrendPanel extends StatelessWidget {
  final List<_TrendPoint> points;
  final NoirSkin skin;

  const _PerformanceTrendPanel({required this.points, required this.skin});

  @override
  Widget build(BuildContext context) => NoirPanel(
    skin: skin,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelTitle(
          icon: Icons.show_chart_outlined,
          title: 'PERFORMANCE TREND',
          skin: skin,
        ),
        const SizedBox(height: 6),
        Text(
          points.isEmpty
              ? 'Complete a mission to start building your trend line.'
              : 'Accuracy and score quality across your latest ${points.length} recorded clears.',
          style: LandingTokens.body(fontSize: 12, color: skin.sub),
        ),
        const SizedBox(height: 16),
        if (points.isEmpty)
          _EmptyTrendState(skin: skin)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              final latest = points.last;
              final accessibility = points
                  .map(
                    (point) =>
                        '${point.title}: '
                        '${(point.accuracy * 100).round()} percent accuracy, '
                        '${(point.scoreRatio * 100).round()} percent score quality',
                  )
                  .join('. ');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 14,
                    runSpacing: 7,
                    children: [
                      _TrendLegend(
                        color: LandingTokens.ember,
                        label: 'ACCURACY',
                        skin: skin,
                      ),
                      _TrendLegend(
                        color: LandingTokens.circuit,
                        label: 'SCORE QUALITY',
                        skin: skin,
                        isBar: true,
                      ),
                      Text(
                        'LATEST ${(latest.accuracy * 100).round()}%',
                        style: LandingTokens.label(
                          fontSize: 8,
                          color: skin.faint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    container: true,
                    label: 'Performance trend chart. $accessibility',
                    child: RepaintBoundary(
                      child: SizedBox(
                        width: double.infinity,
                        height: compact ? 190 : 240,
                        child: CustomPaint(
                          painter: _TrendGraphPainter(
                            points: points,
                            gridColor: skin.borderStrong,
                            labelColor: skin.faint,
                            accuracyColor: LandingTokens.ember,
                            scoreColor: LandingTokens.circuit,
                            textColor: skin.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TrendEndpoints(
                    first: points.first.title,
                    last: latest.title,
                    skin: skin,
                    compact: compact,
                  ),
                ],
              );
            },
          ),
      ],
    ),
  );
}

class _EmptyTrendState extends StatelessWidget {
  final NoirSkin skin;

  const _EmptyTrendState({required this.skin});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 160,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: skin.panelRaised,
      border: Border.all(color: skin.border),
      borderRadius: LandingTokens.smallRadius,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.insights_outlined, color: skin.faint, size: 28),
        const SizedBox(height: 8),
        Text(
          'NO TREND DATA YET',
          style: LandingTokens.label(fontSize: 9, color: skin.faint),
        ),
      ],
    ),
  );
}

class _TrendLegend extends StatelessWidget {
  final Color color;
  final String label;
  final NoirSkin skin;
  final bool isBar;

  const _TrendLegend({
    required this.color,
    required this.label,
    required this.skin,
    this.isBar = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: isBar ? 11 : 18,
        height: isBar ? 10 : 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: LandingTokens.label(fontSize: 8, color: skin.faint)),
    ],
  );
}

class _TrendEndpoints extends StatelessWidget {
  final String first;
  final String last;
  final NoirSkin skin;
  final bool compact;

  const _TrendEndpoints({
    required this.first,
    required this.last,
    required this.skin,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final start = _EndpointText(label: 'EARLIEST', value: first, skin: skin);
    final end = _EndpointText(label: 'LATEST', value: last, skin: skin);
    return compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [start, const SizedBox(height: 6), end],
          )
        : Row(
            children: [
              Expanded(child: start),
              const SizedBox(width: 20),
              Expanded(child: end),
            ],
          );
  }
}

class _EndpointText extends StatelessWidget {
  final String label;
  final String value;
  final NoirSkin skin;

  const _EndpointText({
    required this.label,
    required this.value,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => RichText(
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    text: TextSpan(
      children: [
        TextSpan(
          text: '$label  ',
          style: LandingTokens.label(fontSize: 7.5, color: skin.faint),
        ),
        TextSpan(
          text: value,
          style: LandingTokens.body(fontSize: 11, color: skin.sub),
        ),
      ],
    ),
  );
}

class _TrendGraphPainter extends CustomPainter {
  final List<_TrendPoint> points;
  final Color gridColor;
  final Color labelColor;
  final Color accuracyColor;
  final Color scoreColor;
  final Color textColor;

  const _TrendGraphPainter({
    required this.points,
    required this.gridColor,
    required this.labelColor,
    required this.accuracyColor,
    required this.scoreColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 37.0;
    const top = 10.0;
    const right = 10.0;
    const bottom = 27.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    if (plot.width <= 0 || plot.height <= 0 || points.isEmpty) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var index = 0; index <= 4; index++) {
      final value = index / 4;
      final y = plot.bottom - plot.height * value;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _paintLabel(
        canvas,
        '${(value * 100).round()}%',
        Offset(plot.left - 6, y - 5),
        align: TextAlign.right,
      );
    }

    final step = points.length == 1 ? 0.0 : plot.width / (points.length - 1);
    final barWidth = math.max(
      4.0,
      math.min(18.0, plot.width / (points.length * 2.4)),
    );
    final pointOffsets = <Offset>[];
    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1 ? plot.center.dx : plot.left + step * index;
      final scoreY = plot.bottom - plot.height * points[index].scoreRatio;
      final bar = RRect.fromRectAndRadius(
        Rect.fromLTRB(x - barWidth / 2, scoreY, x + barWidth / 2, plot.bottom),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        bar,
        Paint()..color = scoreColor.withValues(alpha: 0.42),
      );
      pointOffsets.add(
        Offset(x, plot.bottom - plot.height * points[index].accuracy),
      );
    }

    final line = Path()..moveTo(pointOffsets.first.dx, pointOffsets.first.dy);
    for (final offset in pointOffsets.skip(1)) {
      line.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = accuracyColor
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final offset in pointOffsets) {
      canvas.drawCircle(offset, 4, Paint()..color = textColor);
      canvas.drawCircle(offset, 2.3, Paint()..color = accuracyColor);
    }

    _paintLabel(canvas, 'FIRST', Offset(plot.left, plot.bottom + 8));
    _paintLabel(
      canvas,
      'LATEST',
      Offset(plot.right, plot.bottom + 8),
      align: TextAlign.right,
    );
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: labelColor,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          fontFamily: LandingTokens.monoFontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = switch (align) {
      TextAlign.right => offset.dx - painter.width,
      TextAlign.center => offset.dx - painter.width / 2,
      _ => offset.dx,
    };
    painter.paint(canvas, Offset(x, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _TrendGraphPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.accuracyColor != accuracyColor ||
      oldDelegate.scoreColor != scoreColor ||
      oldDelegate.textColor != textColor;
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
    return NoirPanel(
      skin: skin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(icon: Icons.speed, title: 'MOMENTUM', skin: skin),
          const SizedBox(height: 18),
          _ProgressLine(
            label: 'CURRICULUM COVERAGE',
            value: completionRate,
            valueLabel: '${(completionRate * 100).round()}%',
            color: LandingTokens.signal,
            skin: skin,
          ),
          const SizedBox(height: 15),
          _ProgressLine(
            label: 'AVERAGE SCORE QUALITY',
            value: averageScoreRatio,
            valueLabel: '${(averageScoreRatio * 100).round()}%',
            color: LandingTokens.ember,
            skin: skin,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 480 ? 1 : 3;
              const gap = 8.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: width,
                    child: _MiniStat(
                      label: 'CURRENT STREAK',
                      value: '${user.streak} days',
                      skin: skin,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _MiniStat(
                      label: 'BEST STREAK',
                      value: '${user.bestStreak} days',
                      skin: skin,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _MiniStat(
                      label: 'LEVEL',
                      value: 'LV ${progression.level}',
                      skin: skin,
                    ),
                  ),
                ],
              );
            },
          ),
          if (next != null) ...[
            const SizedBox(height: 14),
            Text(
              '${progression.xpToNextTier} XP until ${next.label.toUpperCase()} tier',
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
  Widget build(BuildContext context) => NoirPanel(
    skin: skin,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelTitle(icon: Icons.radar, title: 'SIGNAL READOUT', skin: skin),
        const SizedBox(height: 16),
        _ReadoutRow(label: 'XP BANKED', value: '${user.xp} XP', skin: skin),
        _ReadoutRow(
          label: 'RECORDED CLEARS',
          value: '$tracked modules',
          skin: skin,
        ),
        _ReadoutRow(
          label: 'FASTEST EXECUTION',
          value: _formatDuration(fastestMs),
          skin: skin,
        ),
        _ReadoutRow(
          label: 'BADGES UNLOCKED',
          value: '${user.badges.length}',
          skin: skin,
        ),
        _ReadoutRow(
          label: 'LAST ACTIVITY',
          value: _formatDate(user.lastActivityDate),
          skin: skin,
        ),
        const SizedBox(height: 14),
        Text(
          tracked == 0
              ? 'Complete your first mission to populate the report.'
              : 'Keep replaying cleared missions to improve score quality and pace.',
          style: LandingTokens.body(fontSize: 12, color: skin.sub),
        ),
      ],
    ),
  );
}

class _TrackPerformancePanel extends StatelessWidget {
  final UserSession user;
  final NoirSkin skin;

  const _TrackPerformancePanel({required this.user, required this.skin});

  @override
  Widget build(BuildContext context) => NoirPanel(
    skin: skin,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelTitle(
          icon: Icons.account_tree_outlined,
          title: 'TRACK PERFORMANCE',
          skin: skin,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 940
                ? 5
                : constraints.maxWidth > 560
                ? 2
                : 1;
            const gap = 10.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final track in LanguageTrack.values)
                  SizedBox(
                    width: width,
                    child: _TrackTile(track: track, user: user, skin: skin),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: skin.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_trackIcon(track), size: 16, color: color),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  track.shortLabel.toUpperCase(),
                  style: LandingTokens.label(fontSize: 9, color: skin.text),
                ),
              ),
              Text(
                '$done/${modules.length}',
                style: LandingTokens.mono(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: skin.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
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

  const _ModuleLedger({
    required this.modules,
    required this.user,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => NoirPanel(
    skin: skin,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelTitle(
          icon: Icons.receipt_long_outlined,
          title: 'MODULE LEDGER',
          skin: skin,
        ),
        const SizedBox(height: 7),
        Text(
          'Most recent verified clears, with best score and execution data.',
          style: LandingTokens.body(fontSize: 12, color: skin.sub),
        ),
        const SizedBox(height: 14),
        if (modules.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: skin.panelRaised,
              borderRadius: LandingTokens.smallRadius,
              border: Border.all(color: skin.border),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_clock_outlined, color: skin.faint),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No completed missions yet. Your first clear will appear here.',
                    style: LandingTokens.body(fontSize: 12, color: skin.sub),
                  ),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < modules.length; i++) ...[
            _ModuleRow(module: modules[i], user: user, skin: skin),
            if (i < modules.length - 1) Divider(height: 18, color: skin.border),
          ],
      ],
    ),
  );
}

class _ModuleRow extends StatelessWidget {
  final CurriculumModule module;
  final UserSession user;
  final NoirSkin skin;

  const _ModuleRow({
    required this.module,
    required this.user,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final performance = user.modulePerformance[module.id];
    final score = user.moduleScores[module.id] ?? performance?.score ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 560;
        final identity = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: skin.text,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${module.track.shortLabel.toUpperCase()}  //  ${_formatDate(performance?.lastCompletedAt)}',
              style: LandingTokens.label(fontSize: 8, color: skin.faint),
            ),
          ],
        );
        final statItems = [
          _LedgerStat(
            label: 'SCORE',
            value: '$score/${module.xpReward}',
            skin: skin,
          ),
          _LedgerStat(
            label: 'TRIES',
            value: '${performance?.attempts ?? 1}',
            skin: skin,
          ),
          _LedgerStat(
            label: 'TIME',
            value: _formatDuration(performance?.executionMs),
            skin: skin,
          ),
        ];
        final wideStats = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            statItems[0],
            const SizedBox(width: 16),
            statItems[1],
            const SizedBox(width: 16),
            statItems[2],
          ],
        );
        return narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  identity,
                  const SizedBox(height: 10),
                  Wrap(spacing: 20, runSpacing: 8, children: statItems),
                ],
              )
            : Row(
                children: [
                  Expanded(child: identity),
                  wideStats,
                ],
              );
      },
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final NoirSkin skin;

  const _PanelTitle({
    required this.icon,
    required this.title,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: LandingTokens.ember, size: 18),
      const SizedBox(width: 8),
      Text(
        '// $title',
        style: LandingTokens.label(fontSize: 10, color: LandingTokens.ember),
      ),
    ],
  );
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
        children: [
          Expanded(
            child: Text(
              label,
              style: LandingTokens.label(fontSize: 8.5, color: skin.faint),
            ),
          ),
          Text(
            valueLabel,
            style: LandingTokens.mono(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 6,
          backgroundColor: skin.panelRaised,
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
    children: [
      Text(
        value,
        style: LandingTokens.mono(
          fontSize: 14,
          color: skin.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 3),
      Text(label, style: LandingTokens.label(fontSize: 7.5, color: skin.faint)),
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
      children: [
        Expanded(
          child: Text(
            label,
            style: LandingTokens.label(fontSize: 8.5, color: skin.faint),
          ),
        ),
        Text(
          value,
          style: LandingTokens.mono(
            fontSize: 12,
            color: skin.text,
            fontWeight: FontWeight.w700,
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
        style: LandingTokens.mono(
          fontSize: 11,
          color: skin.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: LandingTokens.label(fontSize: 7.5, color: skin.faint)),
    ],
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
