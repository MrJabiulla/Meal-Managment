import 'package:flutter/material.dart';
import '../../core/models/meal_model.dart';
import '../../services/meal_service.dart';
import '../../services/service_locator.dart';

class MealViewModel extends ChangeNotifier {
  final _mealService = serviceLocator<MealService>();

  List<Meal> _userMeals = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<DateTime, bool> _mealStatusMap = {};

  List<Meal> get userMeals => _userMeals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<DateTime, bool> get mealStatusMap => _mealStatusMap;

  Future<void> loadUserMeals(String userId, DateTime month) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get first and last day of month
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      _userMeals = await _mealService.getUserMeals(userId, firstDay, lastDay);

      // Build meal status map for quick lookup
      _mealStatusMap = {};
      for (var meal in _userMeals) {
        _mealStatusMap[DateUtils.dateOnly(meal.date)] = meal.isActive;
      }
    } catch (e) {
      _errorMessage = 'Failed to load meals: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleMealStatus(String userId, DateTime date, bool isActive) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final meal = await _mealService.toggleMeal(userId, date, isActive);

      // Update local data
      final index = _userMeals.indexWhere(
              (m) => DateUtils.isSameDay(m.date, date)
      );

      if (index >= 0) {
        _userMeals[index] = meal;
      } else {
        _userMeals.add(meal);
      }

      // Update map for quick lookup
      _mealStatusMap[DateUtils.dateOnly(date)] = isActive;

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update meal status: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool getMealStatus(DateTime date) {
    final dateOnly = DateUtils.dateOnly(date);
    // Return the status if exists, otherwise return user's default setting
    return _mealStatusMap[dateOnly] ?? true; // Assuming default is true
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}