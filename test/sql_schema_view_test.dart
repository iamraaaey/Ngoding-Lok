import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/curriculum/curriculum.dart';
import 'package:ngecode_juh/presentation/screens/sql_game_screen.dart';

/// Drives the SQL case screen's Schema tab: opens it, toggles a table
/// dropdown, and switches to Graph (ERD) view — verifying both render without
/// overflow across widths.
void main() {
  Widget harness() => MaterialApp(
    home: SqlGameScreen(
      module: Curriculum.byId('m2'),
      onRequestHintAd: ({required onGranted, onCancelled}) {},
      onWin: ({required linesUsed, required executionMs, sourceCode}) async {},
      onBack: () {},
    ),
  );

  testWidgets('schema tab toggles table dropdowns and a graph view', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    await tester.pumpWidget(harness());
    // Case study seeds a 280ms "loading database" delay; get past it.
    await tester.pump(const Duration(milliseconds: 400));

    // Open the Schema tab.
    await tester.ensureVisible(find.text('Schema'));
    await tester.tap(find.text('Schema'));
    await tester.pump(const Duration(milliseconds: 300));

    // Table view shows the collapsible table dropdowns and the toggle.
    expect(find.text('Database Schema'), findsOneWidget);
    expect(find.text('Table'), findsWidgets);
    expect(find.text('Graph'), findsWidgets);
    expect(find.text('crime_scene'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Collapse a table dropdown, then re-expand it.
    await tester.tap(find.text('suspects').first);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('suspects').first);
    await tester.pump(const Duration(milliseconds: 250));

    // Switch to the ERD graph view.
    await tester.tap(find.text('Graph').first);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
    // The graph nodes still render the tables.
    expect(find.text('interviews'), findsWidgets);
  });

  testWidgets('schema graph view survives a narrow phone width', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(360, 720));
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 400));

    await tester.ensureVisible(find.text('Schema'));
    await tester.tap(find.text('Schema'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Graph').first);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
  });
}
