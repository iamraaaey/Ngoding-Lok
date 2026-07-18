/// Builds and parses the real, shareable Ngoding Lok invite links.
///
/// An invite link is the deployed web app's URL with the friend's referral
/// code attached: `https://ngoding-lok.web.app/?ref=NGXXXXXXXX`. Firebase
/// Hosting rewrites every path to `index.html`, so the query string reaches
/// the app intact and the code can be redeemed automatically after sign-up.
class ReferralLink {
  ReferralLink._();

  /// Live Firebase Hosting origin for the deployed web app.
  static const String appOrigin = 'https://ngoding-lok.web.app';

  /// Deterministic code shape produced by `UserRepository.referralCodeForUid`.
  static final RegExp _codePattern = RegExp(r'^NG[A-Z0-9]{8}$');

  static String? _pendingCode = _readCodeFromLaunchUrl();

  /// Invite URL a friend can open to join with [code] pre-applied.
  static String inviteUrl(String code) => '$appOrigin/?ref=$code';

  /// Referral code carried by the URL the app was launched with
  /// (`?ref=NGXXXXXXXX` on web), waiting to be redeemed after sign-in.
  static String? get pendingCode => _pendingCode;

  static set pendingCode(String? code) => _pendingCode = normalize(code);

  /// Returns the pending code and clears it, so the one-time reward is only
  /// ever attempted once per launch.
  static String? consumePendingCode() {
    final code = _pendingCode;
    _pendingCode = null;
    return code;
  }

  /// Uppercases and validates a raw code; null when it can't be a real code.
  static String? normalize(String? raw) {
    final code = raw?.trim().toUpperCase();
    if (code == null || !_codePattern.hasMatch(code)) return null;
    return code;
  }

  static String? _readCodeFromLaunchUrl() {
    try {
      // On web this is the browser address bar; on native/VM it's a file
      // path with no query, so this safely resolves to null.
      return normalize(Uri.base.queryParameters['ref']);
    } catch (_) {
      return null;
    }
  }
}
