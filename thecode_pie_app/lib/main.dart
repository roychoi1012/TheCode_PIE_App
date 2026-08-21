import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:thecode_pie_app/presentation/screen/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/background_music_service.dart';
import 'providers/app_providers.dart';
import 'presentation/screen/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env could not be loaded. Defaults will be used.');
  }

  runApp(const TheCodePieApp());
}

class TheCodePieApp extends StatefulWidget {
  const TheCodePieApp({super.key});

  @override
  State<TheCodePieApp> createState() => _TheCodePieAppState();
}

class _TheCodePieAppState extends State<TheCodePieApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackgroundMusicService().play();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        BackgroundMusicService().pause();
        break;
      case AppLifecycleState.resumed:
        BackgroundMusicService().play();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: DependencyInjection.providers,
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
