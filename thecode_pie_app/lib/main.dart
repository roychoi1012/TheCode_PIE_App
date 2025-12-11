import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'constants/app_constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login/login_screen.dart';

void main() {
  runApp(const TheCodePieApp());
}

class TheCodePieApp extends StatelessWidget {
  const TheCodePieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // 다른 ViewModel들을 여기에 추가
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
