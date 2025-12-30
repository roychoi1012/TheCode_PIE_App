import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/background_music_service.dart';
import 'providers/app_providers.dart';
import 'presentation/screen/auth/auth_screen_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드 (파일이 없어도 기본값 사용)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env 파일을 로드할 수 없습니다. 기본값을 사용합니다.');
  }

  // 백그라운드 음악 재생 시작
  try {
    await BackgroundMusicService().play();
  } catch (e) {
    debugPrint('백그라운드 음악 초기화 실패: $e');
  }

  runApp(const TheCodePieApp());
}

class TheCodePieApp extends StatelessWidget {
  const TheCodePieApp({super.key});

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
