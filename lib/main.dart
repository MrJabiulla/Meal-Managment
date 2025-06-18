import 'package:flutter/material.dart';
import 'package:meal_managment/services/service_locator.dart';
import 'package:meal_managment/ui/viewmodels/auth_viewmodel.dart';
import 'package:meal_managment/ui/viewmodels/meal_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hphtaxbcnocdnbfyecoo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwaHRheGJjbm9jZG5iZnllY29vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyMzY3MTgsImV4cCI6MjA2NTgxMjcxOH0.bVeykzsBwZAnz3y3QEdHnmUDm8lxDzrJk_TqNPVJ2sw',
  );

  // Initialize services
  await setupServiceLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MealViewModel()),

      ],
      child: const MealManagementApp(),
    ),
  );
}