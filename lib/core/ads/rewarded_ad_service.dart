import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

/// Loads and presents one-shot AdMob rewarded ads for the hint flow.
///
/// Rewarded ads are Android/iOS overlays, so this service intentionally does
/// nothing on web and desktop. Callers can provide a preview fallback there.
class RewardedAdService {
  RewardedAd? _rewardedAd;
  Future<RewardedAd?>? _loadFuture;
  Future<void>? _initialization;

  static bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (!isSupported) return;
    try {
      await MobileAds.instance.initialize();
      await _loadRewardedAd();
    } catch (error) {
      debugPrint('AdMob initialization failed: $error');
    }
  }

  /// Shows a loaded ad, or loads one before showing it when the user taps.
  /// [onRewarded] is called only from AdMob's earned-reward callback.
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onLoading,
    ValueChanged<String>? onUnavailable,
  }) async {
    if (!isSupported) {
      onUnavailable?.call('Rewarded ads are available on Android and iOS.');
      return;
    }

    onLoading?.call();
    await initialize();
    final ad = _rewardedAd ?? await _loadRewardedAd();
    if (ad == null) {
      onUnavailable?.call('No rewarded ad is available right now.');
      return;
    }

    _rewardedAd = null;
    var earned = false;
    var finished = false;

    void finishUnavailable(String message) {
      if (finished || earned) return;
      finished = true;
      onUnavailable?.call(message);
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        finishUnavailable('The rewarded ad could not be shown.');
        unawaited(_loadRewardedAd());
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        finishUnavailable('Watch the full ad to unlock the hint.');
        unawaited(_loadRewardedAd());
      },
    );

    try {
      ad.show(
        onUserEarnedReward: (ad, reward) {
          if (earned) return;
          earned = true;
          onRewarded();
        },
      );
    } catch (error) {
      ad.dispose();
      finishUnavailable('The rewarded ad could not be started.');
      unawaited(_loadRewardedAd());
    }
  }

  Future<RewardedAd?> _loadRewardedAd() {
    final existing = _rewardedAd;
    if (existing != null) return Future.value(existing);
    final activeLoad = _loadFuture;
    if (activeLoad != null) return activeLoad;

    final completer = Completer<RewardedAd?>();
    _loadFuture = completer.future;
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          completer.complete(ad);
          _loadFuture = null;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          completer.complete(null);
          _loadFuture = null;
        },
      ),
    );
    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
