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

  bool _disposed = false;

  List<Meal> get userMeals => _userMeals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<DateTime, bool> get mealStatusMap => _mealStatusMap;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadUserMeals(String userId, DateTime month) async {
    _isLoading = true;
    _errorMessage = null;
    safeNotifyListeners();

    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      _userMeals = await _mealService.getUserMeals(userId, firstDay, lastDay);

      _mealStatusMap = {};
      for (var meal in _userMeals) {
        _mealStatusMap[DateUtils.dateOnly(meal.date)] = meal.isActive;
      }
    } catch (e) {
      _errorMessage = 'Failed to load meals: ${e.toString()}';
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<bool> toggleMealStatus(String userId, DateTime date, bool isActive) async {
    _isLoading = true;
    _errorMessage = null;
    safeNotifyListeners();

    try {
      final meal = await _mealService.toggleMeal(userId, date, isActive);

      final index = _userMeals.indexWhere(
              (m) => DateUtils.isSameDay(m.date, date)
      );

      if (index >= 0) {
        _userMeals[index] = meal;
      } else {
        _userMeals.add(meal);
      }

      _mealStatusMap[DateUtils.dateOnly(date)] = isActive;

      safeNotifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update meal status: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  bool getMealStatus(DateTime date) {
    final dateOnly = DateUtils.dateOnly(date);
    return _mealStatusMap[dateOnly] ?? true;
  }

  void clearError() {
    _errorMessage = null;
    safeNotifyListeners();
  }
}