import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<User?> getUserById(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<User?>> getAllUsers() async {
    final response = await _supabase
        .from('users')
        .select()
        .order('name');

    return (response as List).map((data) => User.fromJson(data)).toList();
  }

  Future<User?> updateUser(String id, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('users')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return User.fromJson(response);
  }

  Future<void> updateDefaultMealStatus(String id, bool defaultStatus) async {
    await _supabase
        .from('users')
        .update({
      'default_meal_status': defaultStatus,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', id);
  }

  Future<String?> getUserProfileImageUrl(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select('photo_url')
          .eq('id', id)
          .single();

      return response['photo_url'];
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfileImage(String id, String imageUrl) async {
    await _supabase
        .from('users')
        .update({
      'photo_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', id);
  }

  Future<bool> isAdmin(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select('is_admin')
          .eq('id', id)
          .single();

      return response['is_admin'] ?? false;
    } catch (e) {
      return false;
    }
  }
}