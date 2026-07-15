import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngecode_juh/presentation/screens/landing_screen.dart';

void main() {
  testWidgets(
    'landing page stays usable across mobile, tablet, and desktop widths',
    (WidgetTester tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final size in <Size>[
        const Size(360, 800),
        const Size(800, 900),
        const Size(1440, 1000),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          MaterialApp(
            home: LandingScreen(onGetStarted: () {}, onSignUp: () {}),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Explore. Debug.\nMaster the Code.'), findsOneWidget);
        expect(find.text('Start Playing'), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
