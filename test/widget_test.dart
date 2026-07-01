import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngecode_juh/main.dart';

/// The splash screen chains a `Future.delayed` into an `AnimationController`
/// (see `SplashScreen._SplashScreenState.initState`), so a single long
/// `pump(duration)` can jump past the delay before the ticker it starts gets
/// a chance to run. Pumping in smaller steps gives each stage of that chain
/// its own frame to resolve.
Future<void> _skipSplash(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 1000));
  }
}

void main() {
  testWidgets('cold start shows the landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const NgeCodeJuhApp());
    await _skipSplash(tester);

    expect(find.text('PLAY NOW'), findsOneWidget);
    expect(find.text("LET'S GO!"), findsNothing);
  });

  testWidgets(
      'play now leads to auth, login navigates to dashboard, launching Grid module reaches game screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NgeCodeJuhApp());
    await _skipSplash(tester);

    await tester.tap(find.text('PLAY NOW'));
    await tester.pump();
    final letsGoButton = find.text("LET'S GO!");
    expect(letsGoButton, findsOneWidget);

    await tester.ensureVisible(letsGoButton);
    await tester.pump();
    await tester.tap(letsGoButton);
    await tester.pump();
    expect(find.text('Module 1: Sequential Steps'), findsOneWidget);

    final launchButton = find.byKey(const Key('launch-m1'));
    await tester.ensureVisible(launchButton);
    await tester.pump();
    await tester.tap(launchButton);
    await tester.pump();

    expect(find.text('COMPILE & RUN'), findsOneWidget);
    expect(find.byIcon(Icons.flag), findsOneWidget);
    expect(find.byIcon(Icons.smart_button), findsOneWidget);
  });
}
