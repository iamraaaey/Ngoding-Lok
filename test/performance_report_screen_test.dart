import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/session/module_performance.dart';
import 'package:ngecode_juh/core/session/user_session.dart';
import 'package:ngecode_juh/data/repositories/user_repository.dart';
import 'package:ngecode_juh/presentation/screens/performance_report_screen.dart';

class _ReportRepository extends UserRepository {
  final StreamController<UserSession?> updates =
      StreamController<UserSession?>.broadcast();

  @override
  Future<UserSession?> fetchUserFromFirestore(String uid) async => null;

  @override
  Stream<UserSession?> streamUserFromFirestore(String uid) => updates.stream;
}

void main() {
  final reportUser = UserSession(
    email: 'learner@example.com',
    name: 'Aina Learner',
    xp: 620,
    completedModuleIds: const ['m1', 'm2'],
    moduleScores: const {'m1': 100, 'm2': 220},
    modulePerformance: {
      'm1': ModulePerformance(
        score: 100,
        linesUsed: 6,
        executionMs: 1240,
        accuracy: 1,
        attempts: 2,
        lastCompletedAt: DateTime(2026, 7, 10),
      ),
      'm2': ModulePerformance(
        score: 220,
        linesUsed: 9,
        executionMs: 2110,
        accuracy: .88,
        attempts: 3,
        lastCompletedAt: DateTime(2026, 7, 18),
      ),
    },
  );

  testWidgets('report reflows without overflow on phone and desktop', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final size in const [Size(320, 640), Size(1440, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          home: PerformanceReportScreen(
            user: reportUser,
            uid: null,
            repository: null,
            onBack: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PERFORMANCE REPORT'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'layout at $size');
    }
  });

  testWidgets('report applies live account updates', (tester) async {
    final repository = _ReportRepository();
    addTearDown(repository.updates.close);

    await tester.pumpWidget(
      MaterialApp(
        home: PerformanceReportScreen(
          user: reportUser,
          uid: 'learner-1',
          repository: repository,
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    repository.updates.add(reportUser.copyWith(xp: 735));
    await tester.pump();

    expect(find.text('LIVE DATA'), findsOneWidget);
    expect(find.textContaining('735 XP banked'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
