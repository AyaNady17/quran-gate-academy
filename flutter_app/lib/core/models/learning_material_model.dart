import 'package:equatable/equatable.dart';

/// Learning Material model
class LearningMaterialModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String type; // 'pdf', 'video', 'audio', 'document'
  final String? fileUrl;
  final String? fileId;
  final int? fileSize;
  final String? thumbnailUrl;
  final String? courseId; // Link to course for course-based access
  final String uploadedBy; // userId of uploader
  final String status; // 'published', 'draft', 'archived'
  final String? tags; // JSON array as string
  final int viewCount;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LearningMaterialModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.type,
    this.fileUrl,
    this.fileId,
    this.fileSize,
    this.thumbnailUrl,
    this.courseId,
    required this.uploadedBy,
    required this.status,
    this.tags,
    this.viewCount = 0,
    this.publishedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory LearningMaterialModel.fromJson(Map<String, dynamic> json) {
    return LearningMaterialModel(
      id: json['\$id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'],
      type: json['type'] ?? 'document',
      fileUrl: json['fileUrl'],
      fileId: json['fileId'],
      fileSize: json['fileSize'],
      thumbnailUrl: json['thumbnailUrl'],
      courseId: json['courseId'],
      uploadedBy: json['uploadedBy'] ?? '',
      status: json['status'] ?? 'published',
      tags: json['tags'],
      viewCount: json['viewCount'] ?? 0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'fileUrl': fileUrl,
      'fileId': fileId,
      'fileSize': fileSize,
      'thumbnailUrl': thumbnailUrl,
      'courseId': courseId,
      'uploadedBy': uploadedBy,
      'status': status,
      'tags': tags,
      'viewCount': viewCount,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  LearningMaterialModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? fileUrl,
    String? fileId,
    int? fileSize,
    String? thumbnailUrl,
    String? courseId,
    String? uploadedBy,
    String? status,
    String? tags,
    int? viewCount,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearningMaterialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileId: fileId ?? this.fileId,
      fileSize: fileSize ?? this.fileSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      courseId: courseId ?? this.courseId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      publishedAt: publishedAt ?? this.publishedAt,
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
        type,
        fileUrl,
        fileId,
        fileSize,
        thumbnailUrl,
        courseId,
        uploadedBy,
        status,
        tags,
        viewCount,
        publishedAt,
        createdAt,
        updatedAt,
      ];
}
