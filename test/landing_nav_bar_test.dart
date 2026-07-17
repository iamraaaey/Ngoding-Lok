import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngecode_juh/presentation/screens/landing_screen.dart';

void main() {
  testWidgets('brand mark follows the mouse and hover widens the wordmark', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1440, 1000));

    await tester.pumpWidget(
      MaterialApp(home: LandingScreen(onGetStarted: () {}, onSignUp: () {})),
    );
    // Looping ambient animations never settle; pump a bounded amount.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    // Hover far from the logo: the global route sees it without crashing.
    await gesture.moveTo(const Offset(900, 700));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    // Hover the wordmark: tracking expands toward its hover letter spacing.
    // (Another "NGODING LOK" exists on the page, so match the nav one by its
    // ellipsis overflow.)
    final navWordmark = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          w.data == 'NGODING LOK' &&
          w.overflow == TextOverflow.ellipsis,
    );
    await gesture.moveTo(tester.getCenter(navWordmark));
    await tester.pump(const Duration(milliseconds: 300));
    // Nearest AnimatedDefaultTextStyle ancestor (Material adds one higher up).
    final wordmarkStyle = tester
        .firstWidget<AnimatedDefaultTextStyle>(
          find.ancestor(
            of: navWordmark,
            matching: find.byType(AnimatedDefaultTextStyle),
          ),
        )
        .style;
    expect(wordmarkStyle.letterSpacing, greaterThan(2.2));

    // Hover directly on the mark, then leave: pull ramps up and back down
    // across frames without throwing.
    await gesture.moveTo(tester.getCenter(find.byIcon(Icons.terminal_rounded)));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.moveTo(const Offset(1200, 900));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
