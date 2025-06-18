import 'package:get_it/get_it.dart';
import 'package:meal_managment/services/subsidy_service.dart';
import 'package:meal_managment/services/user_service.dart';

import 'auth_service.dart';
import 'deposit_service.dart';
import 'expense_service.dart';
import 'meal_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register services
  serviceLocator.registerLazySingleton<AuthService>(() => AuthService());
  serviceLocator.registerLazySingleton<MealService>(() => MealService());
  serviceLocator.registerLazySingleton<UserService>(() => UserService());
  serviceLocator.registerLazySingleton<DepositService>(() => DepositService());
  serviceLocator.registerLazySingleton<ExpenseService>(() => ExpenseService());
  serviceLocator.registerLazySingleton<SubsidyService>(() => SubsidyService());
}