import 'package:flutter/foundation.dart';

/// Non-web stand-in for the AdSense Ad Placement API integration. Rewarded
/// H5 ads only exist in a browser, so this build target reports unavailable.
class AdSenseRewarded {
  AdSenseRewarded._();

  static bool get isConfigured => false;
  static bool get isAvailable => false;

  static Future<bool> waitUntilAvailable({
    Duration timeout = const Duration(seconds: 8),
  }) async => false;

  static void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    ValueChanged<String>? onUnavailable,
  }) {
    onUnavailable?.call('AdSense rewarded ads are only available on the web.');
  }
}
