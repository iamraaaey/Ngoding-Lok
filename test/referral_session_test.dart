import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/session/user_session.dart';

void main() {
  test('persists referral and friend state with the local session', () {
    const original = UserSession(
      email: 'coder@example.com',
      name: 'Coder',
      xp: 120,
      referralCode: 'NGABC1234',
      referredBy: 'referrer-uid',
      referralRewardClaimed: true,
      friendIds: ['friend-uid'],
    );

    final restored = UserSession.fromJson(original.toJson());

    expect(restored.referralCode, 'NGABC1234');
    expect(restored.referredBy, 'referrer-uid');
    expect(restored.referralRewardClaimed, isTrue);
    expect(restored.friendIds, ['friend-uid']);
    expect(restored.xp, 120);
  });

  test('copyWith keeps referral state while updating XP', () {
    const user = UserSession(
      email: 'coder@example.com',
      referralCode: 'NGABC1234',
      friendIds: ['friend-uid'],
    );

    final rewarded = user.copyWith(xp: user.xp + 50);

    expect(rewarded.xp, 50);
    expect(rewarded.referralCode, 'NGABC1234');
    expect(rewarded.friendIds, ['friend-uid']);
    expect(rewarded.referralRewardClaimed, isFalse);
  });
}
