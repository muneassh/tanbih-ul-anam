import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdSpace extends StatefulWidget {
  final double height;
  final bool useTestAd;

  const AdSpace({
    super.key, 
    this.height = 60,
    this.useTestAd = true,
  });

  @override
  State<AdSpace> createState() => _AdSpaceState();
}

class _AdSpaceState extends State<AdSpace> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.useTestAd 
          ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
          : 'YOUR_REAL_AD_UNIT_ID', // Replace with real ID
      size: AdSize(height: widget.height.toInt(), width: 320),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
          setState(() => _isAdLoaded = false);
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        width: double.infinity,
        height: widget.height,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      // Empty container when ad not loaded - no "AD SPACE" text
      return Container(
        height: widget.height,
        margin: const EdgeInsets.symmetric(vertical: 4),
      );
    }
  }
}