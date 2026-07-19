import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/social/performance_report_pdf.dart';
import 'package:ngecode_juh/core/session/module_performance.dart';
import 'package:ngecode_juh/core/session/user_session.dart';

void main() {
  final user = UserSession(
    email: 'learner@example.com',
    name: 'Aina Learner',
    xp: 180,
    completedModuleIds: ['m1'],
    moduleScores: {'m1': 100},
    modulePerformance: {
      'm1': ModulePerformance(
        score: 100,
        linesUsed: 6,
        executionMs: 1234,
        accuracy: 1,
        attempts: 2,
        firstCompletedAt: DateTime(2026, 7, 10),
        lastCompletedAt: DateTime(2026, 7, 18),
      ),
    },
  );

  test('builds a portable PDF from the current report data', () async {
    final bytes = await PerformanceReportPdf.build(user);

    expect(bytes.length, greaterThan(800));
    expect(utf8.decode(bytes.take(5).toList()), '%PDF-');
    expect(
      PerformanceReportPdf.filenameFor(user, now: DateTime(2026, 7, 19)),
      'ngoding-lok-performance-aina-learner-20260719.pdf',
    );
  });
}
