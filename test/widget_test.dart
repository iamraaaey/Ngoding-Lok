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

/// The RootOrchestrator wraps route changes in a 420ms AnimatedSwitcher
/// transition, during which the incoming screen can't be hit-tested —
/// so every navigation step pumps past the transition before tapping.
Future<void> settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1000));
}

Future<void> goToSignUp(WidgetTester tester) async {
  await tester.pumpWidget(const NgeCodeJuhApp());
  await _skipSplash(tester);

  await tester.tap(find.text('PLAY NOW'));
  await settleRoute(tester);

  final createLink = find.byKey(const Key('create-account-link'));
  await tester.ensureVisible(createLink);
  await tester.pump();
  await tester.tap(createLink);
  await settleRoute(tester);
  expect(find.text('CREATE MY ACCOUNT'), findsOneWidget);
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
    await settleRoute(tester);
    final letsGoButton = find.text("LET'S GO!");
    expect(letsGoButton, findsOneWidget);

    await tester.ensureVisible(letsGoButton);
    await tester.pump();
    await tester.tap(letsGoButton);
    await settleRoute(tester);
    expect(find.text('Module 1: Sequential Steps'), findsOneWidget);

    final launchButton = find.text('RESUME PLAYING');
    await tester.ensureVisible(launchButton);
    await tester.pump();
    await tester.tap(launchButton);
    await settleRoute(tester);

    expect(find.text('COMPILE & RUN'), findsOneWidget);
    expect(find.byIcon(Icons.flag), findsOneWidget);
    expect(find.byIcon(Icons.smart_button), findsOneWidget);
  });



  testWidgets('sign-up rejects invalid input with inline errors and stays put',
      (WidgetTester tester) async {
    await goToSignUp(tester);

    // Submit the empty form: every field should flag its own error.
    final submit = find.text('CREATE MY ACCOUNT');
    await tester.ensureVisible(submit);
    await tester.pump();
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Please tell us your name.'), findsOneWidget);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters.'), findsOneWidget);

    // Mismatched passwords keep the user on the sign-up page.
    await tester.enterText(find.descendant(of: find.byKey(const Key('signup-name')), matching: find.byType(TextField)), 'Vera');
    await tester.enterText(find.descendant(of: find.byKey(const Key('signup-email')), matching: find.byType(TextField)), 'vera@unimas.my');
    await tester.enterText(find.descendant(of: find.byKey(const Key('signup-password')), matching: find.byType(TextField)), 'secret123');
    await tester.enterText(find.descendant(of: find.byKey(const Key('signup-confirm')), matching: find.byType(TextField)), 'different');
    
    final consentCheckbox = find.descendant(
        of: find.byKey(const Key('signup-consent-checkbox')),
        matching: find.byType(Checkbox));
    await tester.ensureVisible(consentCheckbox);
    await tester.pump();
    await tester.tap(consentCheckbox);
    await tester.pump();

    await tester.ensureVisible(submit);
    await tester.pump();
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(find.text('CREATE MY ACCOUNT'), findsOneWidget);
  });

  testWidgets('sign-up with valid input registers and lands on the dashboard with the chosen name',
      (WidgetTester tester) async {
    await goToSignUp(tester);

    await tester.enterText(find.descendant(of: find.byKey(const Key('signup-name')), matching: find.byType(TextField)), 'Vera Audrey');
    await tester.enterText(find.descendant(of: find.byKey(const Key('signup-email')), matching: find.byType(TextField)), 'vera@unimas.my');
    await tester.enterText(find.descendant(of: find.byKey(const Key('signup-password')), matching: find.byType(TextField)), 'secret123');
    await tester.enterText(find.descendant(of: find.byKey(const Key('signup-confirm')), matching: find.byType(TextField)), 'secret123');

    final consentCheckbox = find.descendant(
        of: find.byKey(const Key('signup-consent-checkbox')),
        matching: find.byType(Checkbox));
    await tester.ensureVisible(consentCheckbox);
    await tester.pump();
    await tester.tap(consentCheckbox);
    await tester.pump();

    final submit = find.text('CREATE MY ACCOUNT');
    await tester.ensureVisible(submit);
    await tester.pump();
    await tester.tap(submit);
    // Settle so the outgoing sign-up form (whose name field would also
    // match the text finder) is fully unmounted.
    await settleRoute(tester);

    // Dashboard shows the registered profile name (on both the profile
    // card and the leaderboard), not the email prefix.
    expect(find.text('Module 1: Sequential Steps'), findsOneWidget);
    expect(find.text('Vera Audrey'), findsWidgets);
  });

  testWidgets('sign-up page links back to the login page', (WidgetTester tester) async {
    await goToSignUp(tester);

    final backLink = find.byKey(const Key('back-to-login-link'));
    await tester.ensureVisible(backLink);
    await tester.pump();
    await tester.tap(backLink);
    await tester.pump();

    expect(find.text("LET'S GO!"), findsOneWidget);
  });
}
