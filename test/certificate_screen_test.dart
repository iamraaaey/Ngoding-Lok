import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/session/user_session.dart';
import 'package:ngecode_juh/data/models/module_certificate.dart';
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

  testWidgets('certificate detail is full width and exposes PDF download', (
    tester,
  ) async {
    final certificate = ModuleCertificate(
      certificateId: 'learner_m1',
      uid: 'learner',
      moduleId: 'm1',
      moduleTitle: 'Module 1: Sequential Steps',
      moduleDescription: 'Learn basic movement commands to navigate the grid.',
      trackLabel: 'Python Track',
      learnerName: 'Raynold Kabai',
      score: 100,
      issuedAt: DateTime(2026, 7, 18),
    );
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final size in const [Size(360, 800), Size(1440, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CertificateArtwork(
                certificate: certificate,
                onBack: () {},
                onDownload: () {},
                onShare: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('Download PDF'), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(const Key('certificate-artwork-canvas')))
            .width,
        size.width,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
