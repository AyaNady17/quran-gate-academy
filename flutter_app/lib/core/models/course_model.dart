import 'package:equatable/equatable.dart';

/// Course model
class CourseModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String? coverImage;
  final String? level; // 'beginner', 'intermediate', 'advanced'
  final int estimatedHours;
  final String status; // 'active', 'inactive', 'archived'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.coverImage,
    this.level,
    this.estimatedHours = 0,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['\$id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'],
      coverImage: json['coverImage'],
      level: json['level'],
      estimatedHours: json['estimatedHours'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'coverImage': coverImage,
      'level': level,
      'estimatedHours': estimatedHours,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? coverImage,
    String? level,
    int? estimatedHours,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      coverImage: coverImage ?? this.coverImage,
      level: level ?? this.level,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        coverImage,
        level,
        estimatedHours,
        status,
        createdAt,
        updatedAt,
      ];
}
