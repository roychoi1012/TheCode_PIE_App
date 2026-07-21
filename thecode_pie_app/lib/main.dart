import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/background_music_service.dart';
import 'providers/app_providers.dart';
import 'presentation/screen/auth/auth_screen_root.dart';

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

class _TheCodePieAppState extends State<TheCodePieApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackgroundMusicService().play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: DependencyInjection.providers,
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.darkTheme,
        home: const AuthScreenRoot(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
