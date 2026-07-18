import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/session/user_session.dart';
import 'package:ngecode_juh/data/repositories/user_repository.dart';
import 'package:ngecode_juh/presentation/screens/certificates_screen.dart';

void main() {
  testWidgets('shows only completed modules and blocks demo issuance', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CertificatesScreen(
          user: const UserSession(
            email: 'coder@example.com',
            completedModuleIds: ['m1'],
          ),
          uid: null,
          repository: UserRepository(),
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Module 1: Sequential Steps'), findsOneWidget);
    expect(
      find.text(
        'Demo sessions can preview completed modules. Sign in to issue a public credential.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
