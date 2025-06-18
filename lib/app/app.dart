import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';
import '../ui/views/auth/login_view.dart';
import '../ui/views/home/home_view.dart';

class MealManagementApp extends StatelessWidget {
  const MealManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.greenAccent,
        ),
      ),
      themeMode: ThemeMode.system, // Will follow system setting
      home: _handleStartup(),
    );
  }

  Widget _handleStartup() {
    final authService = serviceLocator.get<AuthService>();
    return authService.isUserLoggedIn() ? const HomeView() : const LoginView();
  }
}