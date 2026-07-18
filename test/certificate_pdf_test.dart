import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/social/certificate_pdf.dart';
import 'package:ngecode_juh/data/models/module_certificate.dart';

void main() {
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

  test('builds a portable PDF from the verified certificate record', () async {
    final bytes = await CertificatePdf.build(certificate);

    expect(bytes.length, greaterThan(800));
    expect(utf8.decode(bytes.take(5).toList()), '%PDF-');
    expect(
      CertificatePdf.filenameFor(certificate),
      'ngoding-lok-m1-20260718-certificate.pdf',
    );
  });
}
