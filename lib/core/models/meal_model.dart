class Meal {
  final String id;
  final String userId;
  final DateTime date;
  final bool isActive;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Meal({
    required this.id,
    required this.userId,
    required this.date,
    this.isActive = true,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      isActive: json['is_active'] ?? true,
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'is_active': isActive,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Meal copyWith({
    String? id,
    String? userId,
    DateTime? date,
    bool? isActive,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      isActive: isActive ?? this.isActive,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}