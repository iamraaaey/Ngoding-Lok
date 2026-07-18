import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/social/referral_link.dart';

void main() {
  group('ReferralLink', () {
    tearDown(() => ReferralLink.pendingCode = null);

    test('builds the live hosted invite URL for a code', () {
      expect(
        ReferralLink.inviteUrl('NGABCD1234'),
        'https://ngoding-lok.web.app/?ref=NGABCD1234',
      );
    });

    test('normalize accepts only real NG codes and uppercases them', () {
      expect(ReferralLink.normalize('ngabcd1234'), 'NGABCD1234');
      expect(ReferralLink.normalize('  NGABCD1234  '), 'NGABCD1234');
      expect(ReferralLink.normalize('NGABC'), isNull); // too short
      expect(ReferralLink.normalize('XXABCD1234'), isNull); // wrong prefix
      expect(ReferralLink.normalize('NGABCD12345'), isNull); // too long
      expect(ReferralLink.normalize(''), isNull);
      expect(ReferralLink.normalize(null), isNull);
    });

    test('pending code is consumed exactly once', () {
      ReferralLink.pendingCode = 'ngabcd1234';
      expect(ReferralLink.pendingCode, 'NGABCD1234');
      expect(ReferralLink.consumePendingCode(), 'NGABCD1234');
      expect(ReferralLink.pendingCode, isNull);
      expect(ReferralLink.consumePendingCode(), isNull);
    });

    test('setting an invalid pending code stores nothing', () {
      ReferralLink.pendingCode = 'not-a-code';
      expect(ReferralLink.pendingCode, isNull);
    });
  });
}
