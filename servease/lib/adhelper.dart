import 'dart:io';

class AdHelper {
  // Banner Ad Unit IDs
  static String get bannerUnitID {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test banner ad unit ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test banner ad unit ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Interstitial Ad Unit IDs
  static String get interstitialUnitID {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test interstitial ad unit ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test interstitial ad unit ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}