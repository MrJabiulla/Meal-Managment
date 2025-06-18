import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class Expense {
  final String id;
  final double amount;
  final DateTime date;
  final String category;
  final String? notes;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      category: json['category'],
      notes: json['notes'],
      receiptUrl: json['receipt_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'category': category,
      'notes': notes,
      'receipt_url': receiptUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ExpenseService {
  final _supabase = Supabase.instance.client;

  // Predefined expense categories
  static List<String> categories = [
    'Food',
    'Gas',
    'Water',
    'Cook Salary',
    'Kitchen Supplies',
    'Other',
  ];

  Future<List<Expense>> getExpenses({DateTime? startDate, DateTime? endDate}) async {
    var query = _supabase
        .from('expenses')
        .select();

    if (startDate != null) {
      query = query.gt('date', startDate.toIso8601String().split('T')[0] + ' 00:00:00');
    }

    if (endDate != null) {
      query = query.lt('date', endDate.toIso8601String().split('T')[0] + ' 23:59:59');
    }

    // Apply ordering after all filters
    final response = await query.order('date', ascending: false);
    return (response as List).map((data) => Expense.fromJson(data)).toList();
  }

  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    var query = _supabase
        .from('expenses')
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

  Future<Map<String, double>> getExpensesByCategory({DateTime? startDate, DateTime? endDate}) async {
    var query = _supabase
        .from('expenses')
        .select('category, amount');

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query;

    Map<String, double> categoryMap = {};

    for (var item in response) {
      final category = item['category'];
      final amount = (item['amount'] as num).toDouble();

      categoryMap[category] = (categoryMap[category] ?? 0) + amount;
    }

    return categoryMap;
  }

  Future<Expense> addExpense(
      double amount,
      DateTime date,
      String category,
      {String? notes, String? receiptUrl}
      ) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('expenses')
        .insert({
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'category': category,
      'notes': notes,
      'receipt_url': receiptUrl,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    })
        .select()
        .single();

    return Expense.fromJson(response);
  }

  Future<Expense> updateExpense(
      String id,
      double amount,
      DateTime date,
      String category,
      {String? notes, String? receiptUrl}
      ) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('expenses')
        .update({
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'category': category,
      'notes': notes,
      'receipt_url': receiptUrl,
      'updated_at': now.toIso8601String(),
    })
        .eq('id', id)
        .select()
        .single();

    return Expense.fromJson(response);
  }

  Future<void> deleteExpense(String id) async {
    await _supabase
        .from('expenses')
        .delete()
        .eq('id', id);
  }

  Future<String> uploadReceiptImage(String filePath, String fileName) async {
    final fileObj = File(filePath);

    final file = await _supabase.storage
        .from('receipts')
        .upload('receipts/$fileName', fileObj);

    return _supabase.storage.from('receipts').getPublicUrl('receipts/$fileName');
  }
}