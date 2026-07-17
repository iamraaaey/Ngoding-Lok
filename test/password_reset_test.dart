import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngecode_juh/core/session/email_auth_service.dart';
import 'package:ngecode_juh/presentation/screens/forgot_password_screen.dart';

void main() {
  testWidgets('valid email sends a reset request and shows confirmation', (
    tester,
  ) async {
    String? requestedEmail;

    await tester.pumpWidget(
      MaterialApp(
        home: ForgotPasswordScreen(
          onBackToLogin: () {},
          onSendResetLink: (email) async => requestedEmail = email,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('forgot-password-email')),
        matching: find.byType(TextField),
      ),
      'coder@unimas.my',
    );
    await tester.tap(find.text('SEND RESET LINK'));
    await tester.pump();

    expect(requestedEmail, 'coder@unimas.my');
    expect(find.text('CHECK YOUR EMAIL'), findsOneWidget);
  });

  testWidgets('Firebase failure stays on the form with an actionable error', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ForgotPasswordScreen(
          onBackToLogin: () {},
          onSendResetLink: (_) async {
            throw const PasswordResetException(
              'Email delivery is unavailable.',
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('forgot-password-email')),
        matching: find.byType(TextField),
      ),
      'coder@unimas.my',
    );
    await tester.tap(find.text('SEND RESET LINK'));
    await tester.pump();

    expect(find.text('Email delivery is unavailable.'), findsOneWidget);
    expect(find.text('CHECK YOUR EMAIL'), findsNothing);
  });
}
