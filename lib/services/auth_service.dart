import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  bool isUserLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  Future<User?> getCurrentUser() async {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) {
      return null;
    }

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return User.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Login attempt with email: $email');
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        if (kDebugMode) {
          print('Login failed: User is null');
        }
        throw Exception('Invalid email or password');
      }

      // Check if user exists in users table, if not create it
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        // Create user entry
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'name': email.split('@')[0], // Use part of email as name
          'is_admin': false,
          'default_meal_status': true,
        });

        // Fetch again after creating
        final newUserData = await _supabase
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        if (kDebugMode) {
          print('Login success: true');
        }
        return User.fromJson(newUserData);
      }

      if (kDebugMode) {
        print('Login success: true');
      }
      return User.fromJson(userData);
    } catch (e) {
      if (kDebugMode) {
        print('Login failed: $e');
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
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
      });
    } catch (e) {
      if (kDebugMode) {
        print('Signup failed: $e');
      }
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}