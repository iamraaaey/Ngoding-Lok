/// A validated, idempotent repair plan for a completed referral.
///
/// The redemption record is the source of truth. This lets a newer client
/// recover an invitee profile that was saved by an older client before the
/// referral fields were made race-safe.
class ReferralReconciliationPlan {
  static const int rewardXp = 50;

  final String referrerUid;
  final List<String> inviteeFriendIds;
  final List<String> referrerFriendIds;
  final bool restoresReferralMetadata;
  final bool awardsInvitee;
  final int inviteeXp;
  final bool needsReferrerUpdate;

  const ReferralReconciliationPlan._({
    required this.referrerUid,
    required this.inviteeFriendIds,
    required this.referrerFriendIds,
    required this.restoresReferralMetadata,
    required this.awardsInvitee,
    required this.inviteeXp,
    required this.needsReferrerUpdate,
  });

  /// Returns null when [redemption] is not a valid, completed referral for
  /// [inviteeUid]. The record is deliberately validated before it is allowed
  /// to restore any account state.
  static ReferralReconciliationPlan? fromDocuments({
    required String inviteeUid,
    required Map<String, dynamic> redemption,
    required Map<String, dynamic> invitee,
    required Map<String, dynamic> referrer,
  }) {
    final redemptionInviteeUid = redemption['inviteeUid'] as String?;
    final referrerUid = redemption['referrerUid'] as String?;
    final redeemedReward = (redemption['rewardXp'] as num?)?.toInt();
    if (redemptionInviteeUid != inviteeUid ||
        referrerUid == null ||
        referrerUid.isEmpty ||
        referrerUid == inviteeUid ||
        redeemedReward != rewardXp) {
      return null;
    }

    final inviteeFriendIds = _union(_strings(invitee['friendIds']), [
      referrerUid,
    ]);
    final referrerFriendIds = _union(_strings(referrer['friendIds']), [
      inviteeUid,
    ]);
    final hasReward = invitee['referralRewardClaimed'] == true;
    final restoresMetadata = invitee['referredBy'] != referrerUid || !hasReward;

    return ReferralReconciliationPlan._(
      referrerUid: referrerUid,
      inviteeFriendIds: inviteeFriendIds,
      referrerFriendIds: referrerFriendIds,
      restoresReferralMetadata: restoresMetadata,
      awardsInvitee: !hasReward,
      inviteeXp: (invitee['xp'] as num?)?.toInt() ?? 0,
      needsReferrerUpdate: !_sameStrings(
        referrerFriendIds,
        _strings(referrer['friendIds']),
      ),
    );
  }

  bool needsInviteeUpdate(Map<String, dynamic> invitee) =>
      restoresReferralMetadata ||
      !_sameStrings(inviteeFriendIds, _strings(invitee['friendIds']));

  int get repairedInviteeXp => inviteeXp + (awardsInvitee ? rewardXp : 0);

  static List<String> _strings(Object? value) =>
      (value as List?)?.whereType<String>().toList() ?? const <String>[];

  static List<String> _union(Iterable<String> first, Iterable<String> second) {
    return {...first, ...second}.toList(growable: false);
  }

  static bool _sameStrings(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
