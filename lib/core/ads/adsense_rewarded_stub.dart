import 'package:flutter/foundation.dart';

/// Non-web stand-in for the AdSense Ad Placement API integration. Rewarded
/// H5 ads only exist in a browser, so this build target reports unavailable
/// and callers fall back to AdMob (mobile) or the local preview screen.
class AdSenseRewarded {
  AdSenseRewarded._();

  static bool get isAvailable => false;

  static void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    ValueChanged<String>? onUnavailable,
  }) {
    onUnavailable?.call('AdSense rewarded ads are only available on the web.');
  }
}
