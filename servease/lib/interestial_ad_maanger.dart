import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'adhelper.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  // Getter for checking if ad is loaded
  bool get isAdLoaded => _isAdLoaded;

  // Load interstitial ad
  void loadInterstitialAd() {
    if (_isAdLoaded || _isAdLoading) return; // Don't load if already loaded or loading

    _isAdLoading = true;

    print('Starting to load interstitial ad');
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialUnitID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isAdLoading = false;

          // Set full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              print('Interstitial ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('Interstitial ad dismissed');
              ad.dispose();
              _isAdLoaded = false;
              // Preload next ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('Interstitial ad failed to show: ${error.message}');
              ad.dispose();
              _isAdLoaded = false;
              // Preload next ad
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load interstitial ad: ${error.message}');
          print('Error code: ${error.code}');
          print('Error domain: ${error.domain}');
          _isAdLoaded = false;
          _isAdLoading = false;

          // Retry loading after delay
          Future.delayed(const Duration(seconds: 10), () {
            loadInterstitialAd();
          });
        },
      ),
    );
  }

  // Show interstitial ad
  void showInterstitialAd({VoidCallback? onAdClosed}) {
    print('Attempting to show interstitial ad. Is ad loaded? $_isAdLoaded');

    if (_isAdLoaded && _interstitialAd != null) {
      print('Ad is loaded, showing now...');

      // Set callback for when ad is closed
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print('Interstitial ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('Interstitial ad dismissed');
          ad.dispose();
          _isAdLoaded = false;
          // Call the callback function
          if (onAdClosed != null) {
            onAdClosed();
          }
          // Preload next ad
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('Interstitial ad failed to show: ${error.message}');
          ad.dispose();
          _isAdLoaded = false;
          // Call the callback function even if ad failed
          if (onAdClosed != null) {
            onAdClosed();
          }
          // Preload next ad
          loadInterstitialAd();
        },
      );

      _interstitialAd!.show();
    } else {
      print('Interstitial ad not ready yet');
      // If ad is not ready, call the callback immediately
      if (onAdClosed != null) {
        onAdClosed();
      }

      // Try to load a new ad for next time
      if (!_isAdLoading) {
        loadInterstitialAd();
      }
    }
  }

  // Dispose ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}