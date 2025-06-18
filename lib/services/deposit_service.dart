import 'package:supabase_flutter/supabase_flutter.dart';

class Deposit {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Deposit({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      id: json['id'],
      userId: json['user_id'],
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
      'user_id': userId,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DepositService {
  final _supabase = Supabase.instance.client;

  Future<List<Deposit>> getUserDeposits(String userId, {DateTime? startDate, DateTime? endDate}) async {
    var query = _supabase
        .from('deposits')
        .select();

    // Apply filters
    query = query.eq('user_id', userId);

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    // Apply ordering
    final response = await query.order('date', ascending: false);

    return (response as List).map((data) => Deposit.fromJson(data)).toList();
  }

  Future<double> getTotalUserDeposits(String userId, {DateTime? startDate, DateTime? endDate}) async {
    var query = _supabase
        .from('deposits')
        .select('amount')
        .eq('user_id', userId);

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

  Future<Deposit> addDeposit(String userId, double amount, DateTime date, {String? notes}) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('deposits')
        .insert({
      'user_id': userId,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    })
        .select()
        .single();

    return Deposit.fromJson(response);
  }

  Future<Deposit> updateDeposit(String id, double amount, DateTime date, {String? notes}) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('deposits')
        .update({
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'notes': notes,
      'updated_at': now.toIso8601String(),
    })
        .eq('id', id)
        .select()
        .single();

    return Deposit.fromJson(response);
  }

  Future<void> deleteDeposit(String id) async {
    await _supabase
        .from('deposits')
        .delete()
        .eq('id', id);
  }

  Future<Map<String, double>> getAllUsersDepositSummary({DateTime? startDate, DateTime? endDate}) async {
    var query = _supabase
        .from('deposits')
        .select('user_id, amount');

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query;

    Map<String, double> depositMap = {};

    for (var item in response) {
      final userId = item['user_id'];
      final amount = (item['amount'] as num).toDouble();

      depositMap[userId] = (depositMap[userId] ?? 0) + amount;
    }

    return depositMap;
  }
}
