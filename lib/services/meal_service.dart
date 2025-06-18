import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/meal_model.dart';

class MealService {
  final _supabase = Supabase.instance.client;

  Future<List<Meal>> getUserMeals(String userId, DateTime startDate, DateTime endDate) async {
    final response = await _supabase
        .from('meals')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lte('date', endDate.toIso8601String().split('T')[0])
        .order('date');

    return (response as List).map((meal) => Meal.fromJson(meal)).toList();
  }

  Future<Meal> toggleMeal(String userId, DateTime date, bool isActive) async {
    // Check if a meal entry exists for this date
    final existingMeal = await _supabase
        .from('meals')
        .select()
        .eq('user_id', userId)
        .eq('date', date.toIso8601String().split('T')[0])
        .maybeSingle();

    final now = DateTime.now();

    if (existingMeal != null) {
      // Update existing meal
      final response = await _supabase
          .from('meals')
          .update({
        'is_active': isActive,
        'updated_at': now.toIso8601String(),
      })
          .eq('id', existingMeal['id'])
          .select()
          .single();

      return Meal.fromJson(response);
    } else {
      // Create new meal
      final response = await _supabase
          .from('meals')
          .insert({
        'user_id': userId,
        'date': date.toIso8601String().split('T')[0],
        'is_active': isActive,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      })
          .select()
          .single();

      return Meal.fromJson(response);
    }
  }

Future<int> getTotalMealCount(DateTime startDate, DateTime endDate) async {
  final response = await _supabase
      .from('meals')
      .select()
      .eq('is_active', true)
      .gt('date', startDate.toIso8601String().split('T')[0])
      .lt('date', endDate.toIso8601String().split('T')[0]);

  // Simply count the results
  return (response as List).length;
}

  Future<Map<String, int>> getUserMealCounts(DateTime startDate, DateTime endDate) async {
    final response = await _supabase
        .from('meals')
        .select('user_id')
        .eq('is_active', true)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lte('date', endDate.toIso8601String().split('T')[0]);

    final Map<String, int> userMealCounts = {};
    for (var meal in response) {
      final userId = meal['user_id'];
      userMealCounts[userId] = (userMealCounts[userId] ?? 0) + 1;
    }

    return userMealCounts;
  }
}