import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://hphtaxbcnocdnbfyecoo.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwaHRheGJjbm9jZG5iZnllY29vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyMzY3MTgsImV4cCI6MjA2NTgxMjcxOH0.bVeykzsBwZAnz3y3QEdHnmUDm8lxDzrJk_TqNPVJ2sw',
    );
  }

  bool isUserLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  Future<User?> getCurrentUser() async {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) {
      return null;
    }

    final response = await _supabase
        .from('users')
        .select()
        .eq('id', supabaseUser.id)
        .single();

    return User.fromJson(response);
  }

  Future<User?> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to login');
    }

    final userData = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    return User.fromJson(userData);
  }

  Future<void> signUp(String email, String password, String name) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to sign up');
    }

    // Create user profile
    await _supabase.from('users').insert({
      'id': response.user!.id,
      'email': email,
      'name': name,
      'is_admin': false,
      'default_meal_status': true,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}