import 'package:equatable/equatable.dart';

/// Task model
class TaskModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? assignedTo;
  final String createdBy;
  final String status; // 'pending', 'in_progress', 'completed', 'overdue'
  final String priority; // 'low', 'medium', 'high'
  final DateTime? dueDate;
  final String? relatedEntity; // 'student', 'session', 'course'
  final String? relatedEntityId;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.assignedTo,
    required this.createdBy,
    this.status = 'pending',
    this.priority = 'medium',
    this.dueDate,
    this.relatedEntity,
    this.relatedEntityId,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['\$id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      assignedTo: json['assignedTo'],
      createdBy: json['createdBy'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      relatedEntity: json['relatedEntity'],
      relatedEntityId: json['relatedEntityId'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'relatedEntity': relatedEntity,
      'relatedEntityId': relatedEntityId,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? createdBy,
    String? status,
    String? priority,
    DateTime? dueDate,
    String? relatedEntity,
    String? relatedEntityId,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      relatedEntity: relatedEntity ?? this.relatedEntity,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        assignedTo,
        createdBy,
        status,
        priority,
        dueDate,
        relatedEntity,
        relatedEntityId,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
