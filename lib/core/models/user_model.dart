class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final bool isAdmin;
  final bool defaultMealStatus;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.isAdmin = false,
    this.defaultMealStatus = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photo_url'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      defaultMealStatus: json['default_meal_status'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'is_admin': isAdmin,
      'default_meal_status': defaultMealStatus,
    };
  }
}