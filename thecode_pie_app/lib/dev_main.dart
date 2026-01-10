// 테스트 광고 ID (android)

// 배너 (Banner)	ca-app-pub-3940256099942544/6300978111

// 전면 (Interstitial)	ca-app-pub-3940256099942544/1033173712

// 리워드 (Rewarded)	ca-app-pub-3940256099942544/5224354917

import 'package:flutter/material.dart';
import 'package:thecode_pie_app/home_screen.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}
