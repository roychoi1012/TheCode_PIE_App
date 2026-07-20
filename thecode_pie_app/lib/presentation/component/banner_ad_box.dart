import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:thecode_pie_app/core/config/ad_config.g.dart';

class BannerAdBox extends StatefulWidget {
  const BannerAdBox({super.key, required this.width});

  static const double height = 50;

  final double width;

  @override
  State<BannerAdBox> createState() => _BannerAdBoxState();
}

class _BannerAdBoxState extends State<BannerAdBox> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  int? _loadedWidth;

  static String get _bannerUnitId {
    if (Platform.isAndroid) {
      final configured = admobAndroidBannerUnitId.isNotEmpty
          ? admobAndroidBannerUnitId
          : (dotenv.env['ADMOB_ANDROID_BANNER_UNIT_ID'] ?? '');
      return configured.isNotEmpty
          ? configured
          : 'ca-app-pub-3940256099942544/6300978111';
    }

    if (Platform.isIOS) {
      return dotenv.env['ADMOB_IOS_BANNER_UNIT_ID'] ??
          'ca-app-pub-3940256099942544/2934735716';
    }

    return '';
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant BannerAdBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextWidth = widget.width.truncate();
    if (_loadedWidth != null && _loadedWidth != nextWidth) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      _loadAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    final adUnitId = _bannerUnitId;
    if (adUnitId.isEmpty) return;

    final requestWidth = widget.width.truncate();
    if (requestWidth <= 0) return;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      requestWidth,
    );
    if (!mounted || size == null || widget.width.truncate() != requestWidth) {
      return;
    }

    _loadedWidth = requestWidth;

    final ad = BannerAd(
      size: size,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || widget.width.truncate() != requestWidth) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[BannerAdBox] failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );

    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return SizedBox(width: widget.width, height: BannerAdBox.height);
    }

    return SizedBox(
      width: widget.width,
      height: _bannerAd!.size.height.toDouble(),
      child: Center(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
