import 'package:flutter/foundation.dart';

/// AdMob values are supplied at build time so production identifiers never
/// need to be hard-coded into the Dart source.
abstract final class AdMobConfig {
  AdMobConfig._();

  static const bool _liveAds = bool.fromEnvironment(
    'ADMOB_LIVE_ADS',
    defaultValue: false,
  );

  static const String _androidRewardedId = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_AD_UNIT_ID',
  );
  static const String _iosRewardedId = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_AD_UNIT_ID',
  );

  // Google-provided rewarded test units. These are safe to use during
  // development and must be replaced with your own units for production.
  static const String androidTestRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String iosTestRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  static bool get usingTestAds => !_liveAds;

  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return usingTestAds || _iosRewardedId.isEmpty
          ? iosTestRewardedId
          : _iosRewardedId;
    }
    return usingTestAds || _androidRewardedId.isEmpty
        ? androidTestRewardedId
        : _androidRewardedId;
  }
}
