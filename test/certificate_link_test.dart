import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/social/certificate_link.dart';

void main() {
  test('creates a stable public certificate URL', () {
    const certificateId = 'uid123_m1';

    expect(CertificateLink.certificateIdFor('uid123', 'm1'), certificateId);
    expect(
      CertificateLink.certificateUrl(certificateId),
      'https://ngoding-lok.web.app/?certificate=uid123_m1',
    );
  });

  test('builds the real LinkedIn share-offsite URL', () {
    final shareUrl = CertificateLink.linkedinShareUrl('uid123_m1');

    expect(shareUrl.host, 'www.linkedin.com');
    expect(shareUrl.path, '/sharing/share-offsite/');
    expect(
      shareUrl.queryParameters['url'],
      'https://ngoding-lok.web.app/?certificate=uid123_m1',
    );
  });
}
