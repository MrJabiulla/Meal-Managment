import 'package:meal_managment/services/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Subsidy {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subsidy({
    required this.id,
    required this.amount,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subsidy.fromJson(Map<String, dynamic> json) {
    return Subsidy(
      id: json['id'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SubsidyService {
  final _supabase = Supabase.instance.client;

  // Add to service_locator
  static void register() {
    serviceLocator.registerLazySingleton<SubsidyService>(() => SubsidyService());
  }

  Future<List<Subsidy>> getSubsidies({DateTime? startDate, DateTime? endDate}) async {
    var query = _supabase
        .from('subsidies')
        .select();

    if (startDate != null) {
      query = query.gt('date', startDate.toIso8601String().split('T')[0] + ' 00:00:00');
    }

    if (endDate != null) {
      query = query.lt('date', endDate.toIso8601String().split('T')[0] + ' 23:59:59');
    }

    // Apply ordering after all filters
    final response = await query.order('date', ascending: false);
    return (response as List).map((data) => Subsidy.fromJson(data)).toList();
  }

  Future<double> getTotalSubsidies({DateTime? startDate, DateTime? endDate}) async {
    var query = _supabase
        .from('subsidies')
        .select('amount');

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query;
    double total = 0;

    for (var item in response) {
      total += (item['amount'] as num).toDouble();
    }

    return total;
  }

  Future<Subsidy> addSubsidy(double amount, DateTime date, {String? notes}) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('subsidies')
        .insert({
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    })
        .select()
        .single();

    return Subsidy.fromJson(response);
  }

  Future<Subsidy> updateSubsidy(String id, double amount, DateTime date, {String? notes}) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('subsidies')
        .update({
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'notes': notes,
      'updated_at': now.toIso8601String(),
    })
        .eq('id', id)
        .select()
        .single();

    return Subsidy.fromJson(response);
  }

  Future<void> deleteSubsidy(String id) async {
    await _supabase
        .from('subsidies')
        .delete()
        .eq('id', id);
  }
}