import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

/// Real rewarded ads on Flutter web via the AdSense "Ad Placement API"
/// (H5 Games Ads). Requires the publisher snippet in web/index.html:
///
///   <script async
///     src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXX"
///     crossorigin="anonymous" data-ad-frequency-hint="30s"></script>
///
/// plus the `adBreak`/`adConfig` shim (already present in index.html). When
/// the snippet is missing or the account has no fill, [isAvailable] is false
/// or [showRewardedAd] reports unavailable, and callers fall back to the
/// local preview screen — the hint flow never dead-ends.
class AdSenseRewarded {
  AdSenseRewarded._();

  /// True only when the adBreak shim exists AND the real adsbygoogle.js
  /// loader has finished loading (it stamps `adsbygoogle.loaded = true`).
  /// Without the publisher script the shim would queue calls forever, so a
  /// bare shim is treated as unavailable.
  static bool get isAvailable {
    if (!kIsWeb) return false;
    if (!globalContext.has('adBreak')) return false;
    final ads = globalContext.getProperty<JSAny?>('adsbygoogle'.toJS);
    if (ads == null || !ads.isA<JSObject>()) return false;
    final loaded = (ads as JSObject).getProperty<JSAny?>('loaded'.toJS);
    return loaded != null &&
        loaded.isA<JSBoolean>() &&
        (loaded as JSBoolean).toDart;
  }

  /// Requests a rewarded ad break. [onRewarded] fires only when AdSense
  /// reports the ad was fully viewed; [onDismissed] when the player closed
  /// it early; [onUnavailable] when there is no fill (callers should fall
  /// back to the preview flow). Exactly one of the three is invoked.
  static void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    ValueChanged<String>? onUnavailable,
  }) {
    if (!isAvailable) {
      onUnavailable?.call('AdSense is not configured on this page.');
      return;
    }

    var settled = false;
    Timer? timeout;
    void settle(void Function() action) {
      if (settled) return;
      settled = true;
      timeout?.cancel();
      action();
    }

    // Belt-and-braces: if AdSense never resolves the placement (adBreakDone
    // not firing), release the caller instead of hanging the hint flow.
    timeout = Timer(const Duration(seconds: 12), () {
      settle(
        () => onUnavailable?.call('No sponsor ad is available right now.'),
      );
    });

    final options = JSObject()
      ..setProperty('type'.toJS, 'reward'.toJS)
      ..setProperty('name'.toJS, 'hint_unlock'.toJS)
      // The player already opted in by tapping "Get Hint (Ad)", so show the
      // ad as soon as AdSense says one is ready.
      ..setProperty(
        'beforeReward'.toJS,
        ((JSFunction showAdFn) {
          showAdFn.callAsFunction();
        }).toJS,
      )
      ..setProperty('adViewed'.toJS, (() => settle(onRewarded)).toJS)
      ..setProperty(
        'adDismissed'.toJS,
        (() => settle(() => onDismissed?.call())).toJS,
      )
      ..setProperty(
        'adBreakDone'.toJS,
        ((JSObject placementInfo) {
          final status = placementInfo.getProperty<JSAny?>('breakStatus'.toJS);
          final statusText = status != null && status.isA<JSString>()
              ? (status as JSString).toDart
              : 'unknown';
          switch (statusText) {
            case 'viewed':
              settle(onRewarded);
            case 'dismissed':
              settle(() => onDismissed?.call());
            default:
              settle(
                () => onUnavailable?.call(
                  'No sponsor ad is available right now ($statusText).',
                ),
              );
          }
        }).toJS,
      );

    globalContext.callMethod('adBreak'.toJS, options);
  }
}
