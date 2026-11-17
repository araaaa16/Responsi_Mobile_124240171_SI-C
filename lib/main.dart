import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'services/hive_helper.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  final isLoggedIn = await AuthService().isLoggedIn();
  runApp(ShoppingHubApp(isLoggedIn: isLoggedIn));
}

class ShoppingHubApp extends StatelessWidget {
  final bool isLoggedIn;

  const ShoppingHubApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
