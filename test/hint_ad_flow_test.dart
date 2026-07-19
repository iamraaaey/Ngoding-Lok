import 'package:flutter_test/flutter_test.dart';

import 'package:ngecode_juh/core/ads/adsense_rewarded.dart';

void main() {
  test('hint-ad flow: unavailable ads never grant a hint', () async {
    var rewarded = false;
    String? unavailableMessage;

    // Widget tests run on the non-web implementation. It must report an
    // unavailable placement instead of simulating a sponsor card or reward.
    expect(AdSenseRewarded.isConfigured, isFalse);
    expect(await AdSenseRewarded.waitUntilAvailable(), isFalse);

    AdSenseRewarded.showRewardedAd(
      onRewarded: () => rewarded = true,
      onUnavailable: (message) => unavailableMessage = message,
    );

    expect(rewarded, isFalse);
    expect(unavailableMessage, isNotNull);
    expect(unavailableMessage, contains('only available on the web'));
  });
}
