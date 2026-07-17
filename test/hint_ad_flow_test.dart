import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngecode_juh/main.dart';

/// Splash chains Future.delayed into an AnimationController, so pump in steps.
Future<void> _skipSplash(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 1000));
  }
}

Future<void> _settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1000));
}

void main() {
  testWidgets('hint-ad flow: unavailable ads do not show a fake sponsor card', (
    WidgetTester tester,
  ) async {
    // Force an unsupported platform. The app must not grant a hint through
    // a fake sponsor card when no real ad SDK is available.
    addTearDown(() => tester.binding.setSurfaceSize(null));
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      await tester.binding.setSurfaceSize(const Size(1100, 800));

      await tester.pumpWidget(const NgeCodeJuhApp());
      await _skipSplash(tester);

      // PLAY NOW -> auth -> log in -> home hub.
      await tester.tap(find.text('PLAY NOW'));
      await _settleRoute(tester);
      final letsGo = find.text("LET'S GO!");
      await tester.ensureVisible(letsGo);
      await tester.pump();
      await tester.tap(letsGo);
      await _settleRoute(tester);

      // Launch Module 1 (grid game).
      final resume = find.text('RESUME PLAYING');
      await tester.ensureVisible(resume);
      await tester.pump();
      await tester.tap(resume);
      await _settleRoute(tester);
      expect(find.text('COMPILE & RUN'), findsOneWidget);

      // Tap the "Get Hint (Ad)" button in the game header.
      await tester.tap(find.byIcon(Icons.lightbulb).first);
      await _settleRoute(tester);

      expect(
        find.text('Live rewarded ads are not configured for this build.'),
        findsOneWidget,
      );
      expect(find.text('UNLOCKING YOUR HINT'), findsNothing);

      // No setState-after-dispose crash, no fake ad, and we remain on the
      // same mounted game screen.
      expect(tester.takeException(), isNull);
      expect(find.text('COMPILE & RUN'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
