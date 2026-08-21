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
      return configured;
    }

    if (Platform.isIOS) {
      return dotenv.env['ADMOB_IOS_BANNER_UNIT_ID'] ?? '';
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
    debugPrint('[BannerAdBox] adUnitId=$adUnitId'); // 추가
    if (adUnitId.isEmpty) {
      debugPrint('[BannerAdBox] adUnitId is empty, aborting'); // 추가
      return;
    }

    final requestWidth = widget.width.truncate();
    debugPrint('[BannerAdBox] requestWidth=$requestWidth'); // 추가
    if (requestWidth <= 0) {
      debugPrint('[BannerAdBox] requestWidth <= 0, aborting'); // 추가
      return;
    }

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      requestWidth,
    );
    debugPrint('[BannerAdBox] size=$size'); // 추가
    if (!mounted || size == null || widget.width.truncate() != requestWidth) {
      debugPrint('[BannerAdBox] size null or width mismatch, aborting'); // 추가
      return;
    }

    _loadedWidth = requestWidth;

    final ad = BannerAd(
      size: size,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[BannerAdBox] onAdLoaded fired'); // 추가
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
          debugPrint(
            '[BannerAdBox] failed to load: '
            'code=${error.code} domain=${error.domain} '
            'message=${error.message}',
          );
          ad.dispose();
        },
      ),
    );

    debugPrint('[BannerAdBox] calling ad.load()'); // 추가
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
