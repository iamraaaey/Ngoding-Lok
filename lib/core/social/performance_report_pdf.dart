import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../curriculum/curriculum.dart';
import '../curriculum/curriculum_module.dart';
import '../session/module_performance.dart';
import '../session/user_session.dart';

/// Creates a portable snapshot of the learner's current performance report.
///
/// The document is built from the same account data shown in the app instead
/// of from a screenshot, so it stays readable when printed or shared.
class PerformanceReportPdf {
  PerformanceReportPdf._();

  static const _ink = PdfColor.fromInt(0xFF171717);
  static const _muted = PdfColor.fromInt(0xFF6E6A62);
  static const _line = PdfColor.fromInt(0xFFD9D5CC);
  static const _paper = PdfColor.fromInt(0xFFF8F6F1);
  static const _ember = PdfColor.fromInt(0xFFFF5C01);
  static const _signal = PdfColor.fromInt(0xFF168759);
  static const _circuit = PdfColor.fromInt(0xFF087F9D);

  static String filenameFor(UserSession user, {DateTime? now}) {
    final safeName = user.displayName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final date = now ?? DateTime.now();
    final stamp =
        '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    return 'ngoding-lok-performance-${safeName.isEmpty ? 'learner' : safeName}-$stamp.pdf';
  }

  static Future<Uint8List> build(UserSession user) async {
    final completed = _completedModules(user);
    final tracked = _trackedModules(user);
    final totalModules = Curriculum.modules.length;
    final completionRate = totalModules == 0
        ? 0.0
        : completed.length / totalModules;
    final averageAccuracy = _averageAccuracy(tracked);
    final totalAttempts = tracked.fold<int>(
      0,
      (total, entry) => total + entry.value.attempts,
    );
    final fastest = _fastestMilliseconds(tracked);
    final document = pw.Document(
      title: 'Performance report - ${user.displayName}',
      author: 'Ngoding Lok',
      subject: 'Learning performance report',
      creator: 'Ngoding Lok',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Performance report  |  Page ${context.pageNumber}',
            style: const pw.TextStyle(color: _muted, fontSize: 8),
          ),
        ),
        build: (context) => [
          _header(user),
          pw.SizedBox(height: 20),
          pw.Text(
            'LEARNING SNAPSHOT',
            style: pw.TextStyle(
              color: _ember,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metric(
                label: 'CURRICULUM COMPLETE',
                value: '${(completionRate * 100).round()}%',
                detail: '${completed.length} of $totalModules modules',
                accent: _signal,
              ),
              _metric(
                label: 'AVERAGE ACCURACY',
                value: '${(averageAccuracy * 100).round()}%',
                detail: '${tracked.length} tracked clears',
                accent: _ember,
              ),
              _metric(
                label: 'TOTAL ATTEMPTS',
                value: '$totalAttempts',
                detail: '${user.streak}-day current streak',
                accent: _circuit,
              ),
              _metric(
                label: 'FASTEST CLEAR',
                value: _formatDuration(fastest),
                detail: 'Best recorded execution',
                accent: _signal,
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'MODULE PERFORMANCE',
            style: pw.TextStyle(
              color: _ember,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          pw.SizedBox(height: 8),
          if (completed.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: _paper,
                border: pw.Border.all(color: _line),
              ),
              child: pw.Text(
                'No completed modules have been recorded yet.',
                style: const pw.TextStyle(color: _muted, fontSize: 10),
              ),
            )
          else
            _moduleTable(completed, user),
          pw.SizedBox(height: 18),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _paper,
              border: pw.Border.all(color: _line),
            ),
            child: pw.Text(
              'Generated ${_formatDate(DateTime.now())}. Scores and timing reflect the latest saved results at the time this report was created.',
              style: const pw.TextStyle(color: _muted, fontSize: 8.5),
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  static Future<bool> download(UserSession user) async {
    final bytes = await build(user);
    return Printing.sharePdf(bytes: bytes, filename: filenameFor(user));
  }

  static pw.Widget _header(UserSession user) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(18),
    decoration: pw.BoxDecoration(
      color: _ink,
      border: pw.Border.all(color: _ember, width: 1.2),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'NGODING LOK  /  PERFORMANCE REPORT',
          style: pw.TextStyle(
            color: _ember,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          user.displayName,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 25,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'XP BANKED: ${user.xp}   |   BEST STREAK: ${user.bestStreak} DAYS   |   LAST ACTIVITY: ${_formatDateString(user.lastActivityDate)}',
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 8.5),
        ),
      ],
    ),
  );

  static pw.Widget _metric({
    required String label,
    required String value,
    required String detail,
    required PdfColor accent,
  }) => pw.Container(
    width: 123,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: _paper,
      border: pw.Border.all(color: _line),
      borderRadius: pw.BorderRadius.circular(2),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            color: accent,
            fontSize: 6.5,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.7,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          detail,
          style: const pw.TextStyle(color: _muted, fontSize: 7.5),
        ),
      ],
    ),
  );

  static pw.Widget _moduleTable(
    List<CurriculumModule> modules,
    UserSession user,
  ) => pw.Table(
    border: pw.TableBorder.all(color: _line, width: 0.5),
    columnWidths: const {
      0: pw.FlexColumnWidth(3.6),
      1: pw.FlexColumnWidth(1.15),
      2: pw.FlexColumnWidth(1.25),
      3: pw.FlexColumnWidth(0.85),
      4: pw.FlexColumnWidth(1.0),
    },
    children: [
      _tableRow(const [
        'Module',
        'Track',
        'Score',
        'Tries',
        'Best time',
      ], header: true),
      for (final module in modules)
        _tableRow([
          module.title,
          module.track.shortLabel.toUpperCase(),
          '${user.moduleScores[module.id] ?? user.modulePerformance[module.id]?.score ?? 0}/${module.xpReward}',
          '${user.modulePerformance[module.id]?.attempts ?? 1}',
          _formatDuration(user.modulePerformance[module.id]?.executionMs),
        ]),
    ],
  );

  static pw.TableRow _tableRow(
    List<String> cells, {
    bool header = false,
  }) => pw.TableRow(
    decoration: header ? const pw.BoxDecoration(color: _ink) : null,
    children: [
      for (final cell in cells)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          child: pw.Text(
            cell,
            maxLines: 2,
            style: pw.TextStyle(
              color: header ? PdfColors.white : _ink,
              fontSize: header ? 7.5 : 8,
              fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
    ],
  );

  static List<CurriculumModule> _completedModules(UserSession user) {
    final modules = Curriculum.sortedModules
        .where((module) => user.completedModuleIds.contains(module.id))
        .toList();
    modules.sort((a, b) {
      final aDate = user.modulePerformance[a.id]?.lastCompletedAt;
      final bDate = user.modulePerformance[b.id]?.lastCompletedAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return modules;
  }

  static List<MapEntry<CurriculumModule, ModulePerformance>> _trackedModules(
    UserSession user,
  ) => [
    for (final module in Curriculum.sortedModules)
      if (user.modulePerformance[module.id] != null)
        MapEntry(module, user.modulePerformance[module.id]!),
  ];

  static double _averageAccuracy(
    List<MapEntry<CurriculumModule, ModulePerformance>> entries,
  ) {
    if (entries.isEmpty) return 0;
    return entries
            .map((entry) => entry.value.accuracy.clamp(0.0, 1.0))
            .reduce((a, b) => a + b) /
        entries.length;
  }

  static int? _fastestMilliseconds(
    List<MapEntry<CurriculumModule, ModulePerformance>> entries,
  ) {
    final times = [
      for (final entry in entries)
        if (entry.value.executionMs > 0) entry.value.executionMs,
    ]..sort();
    return times.isEmpty ? null : times.first;
  }

  static String _formatDuration(int? milliseconds) {
    if (milliseconds == null || milliseconds <= 0) return '--';
    if (milliseconds < 1000) return '${milliseconds}ms';
    return '${(milliseconds / 1000).toStringAsFixed(1)}s';
  }

  static String _formatDateString(String? raw) {
    final date = raw == null ? null : DateTime.tryParse(raw);
    return date == null ? 'NO DATA' : _formatDate(date);
  }

  static String _formatDate(DateTime date) {
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
}
