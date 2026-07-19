import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/social/referral_reconciliation.dart';

void main() {
  const inviteeUid = 'invitee-uid';
  const referrerUid = 'referrer-uid';

  Map<String, dynamic> redemption() => const {
    'inviteeUid': inviteeUid,
    'referrerUid': referrerUid,
    'rewardXp': 50,
  };

  test('repairs a legacy invitee profile from a valid redemption record', () {
    final plan = ReferralReconciliationPlan.fromDocuments(
      inviteeUid: inviteeUid,
      redemption: redemption(),
      invitee: const {
        'xp': 0,
        'friendIds': <String>[],
        'referralRewardClaimed': false,
      },
      referrer: const {
        'xp': 60,
        'friendIds': [inviteeUid],
      },
    );

    expect(plan, isNotNull);
    expect(plan!.inviteeFriendIds, [referrerUid]);
    expect(plan.referrerFriendIds, [inviteeUid]);
    expect(plan.restoresReferralMetadata, isTrue);
    expect(plan.awardsInvitee, isTrue);
    expect(plan.repairedInviteeXp, 50);
    expect(plan.needsReferrerUpdate, isFalse);
  });

  test('is idempotent after the reciprocal referral data is restored', () {
    final plan = ReferralReconciliationPlan.fromDocuments(
      inviteeUid: inviteeUid,
      redemption: redemption(),
      invitee: const {
        'xp': 50,
        'friendIds': [referrerUid],
        'referredBy': referrerUid,
        'referralRewardClaimed': true,
      },
      referrer: const {
        'xp': 60,
        'friendIds': [inviteeUid],
      },
    );

    expect(plan, isNotNull);
    expect(plan!.restoresReferralMetadata, isFalse);
    expect(plan.awardsInvitee, isFalse);
    expect(
      plan.needsInviteeUpdate(const {
        'xp': 50,
        'friendIds': [referrerUid],
        'referredBy': referrerUid,
        'referralRewardClaimed': true,
      }),
      isFalse,
    );
    expect(plan.needsReferrerUpdate, isFalse);
    expect(plan.repairedInviteeXp, 50);
  });

  test('preserves existing crew members while restoring the missing edge', () {
    final plan = ReferralReconciliationPlan.fromDocuments(
      inviteeUid: inviteeUid,
      redemption: redemption(),
      invitee: const {
        'xp': 200,
        'friendIds': ['existing-friend'],
        'referredBy': referrerUid,
        'referralRewardClaimed': true,
      },
      referrer: const {'xp': 60, 'friendIds': <String>[]},
    );

    expect(plan, isNotNull);
    expect(plan!.inviteeFriendIds, ['existing-friend', referrerUid]);
    expect(plan.referrerFriendIds, [inviteeUid]);
    expect(plan.needsReferrerUpdate, isTrue);
    expect(plan.repairedInviteeXp, 200);
  });

  test('rejects redemption records that do not belong to the invitee', () {
    final plan = ReferralReconciliationPlan.fromDocuments(
      inviteeUid: inviteeUid,
      redemption: const {
        'inviteeUid': 'another-user',
        'referrerUid': referrerUid,
        'rewardXp': 50,
      },
      invitee: const {},
      referrer: const {},
    );

    expect(plan, isNull);
  });
}
