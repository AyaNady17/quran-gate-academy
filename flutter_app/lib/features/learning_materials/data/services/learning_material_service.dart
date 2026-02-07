import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Learning Material Service - Handles all Appwrite operations for learning materials
class LearningMaterialService {
  final Databases databases;
  final Storage storage;

  LearningMaterialService({
    required this.databases,
    required this.storage,
  });

  /// Fetch all learning materials with optional filters
  Future<List<Map<String, dynamic>>> getAllMaterials({
    String? category,
    String? type,
    String? courseId,
    int limit = 100,
  }) async {
    try {
      final queries = <String>[
        Query.equal('status', AppConfig.materialStatusPublished),
        Query.orderDesc('createdAt'),
        Query.limit(limit),
      ];

      // Add optional filters
      if (category != null && category.isNotEmpty) {
        queries.add(Query.equal('category', category));
      }

      if (type != null && type.isNotEmpty) {
        queries.add(Query.equal('type', type));
      }

      if (courseId != null && courseId.isNotEmpty) {
        queries.add(Query.equal('courseId', courseId));
      }

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        queries: queries,
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch learning materials: ${e.message}');
    }
  }

  /// Fetch materials by multiple course IDs (for student's enrolled courses)
  Future<List<Map<String, dynamic>>> getMaterialsByCourses({
    required List<String> courseIds,
    String? type,
    int limit = 100,
  }) async {
    try {
      if (courseIds.isEmpty) {
        return [];
      }

      final queries = <String>[
        Query.equal('status', AppConfig.materialStatusPublished),
        Query.orderDesc('createdAt'),
        Query.limit(limit),
      ];

      // Filter by course IDs - use OR query if supported, otherwise fetch all and filter
      // Note: Appwrite Query.or might not be available in all versions
      // For now, we'll fetch all published materials and filter by courseIds in code

      if (type != null && type.isNotEmpty) {
        queries.add(Query.equal('type', type));
      }

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        queries: queries,
      );

      // Filter by courseIds in code
      final allMaterials = response.documents.map((doc) => doc.data).toList();
      return allMaterials.where((material) {
        final materialCourseId = material['courseId'] as String?;
        return materialCourseId != null && courseIds.contains(materialCourseId);
      }).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch materials by courses: ${e.message}');
    }
  }

  /// Fetch a single learning material by ID
  Future<Map<String, dynamic>> getMaterial(String materialId) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        documentId: materialId,
      );

      return response.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        throw Exception('Learning material not found');
      }
      throw Exception('Failed to fetch learning material: ${e.message}');
    }
  }

  /// Increment view count for a material
  Future<void> incrementViewCount(String materialId, int currentCount) async {
    try {
      await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        documentId: materialId,
        data: {
          'viewCount': currentCount + 1,
        },
      );
    } on AppwriteException catch (e) {
      // Don't throw error for view count increment failure
      print('Failed to increment view count: ${e.message}');
    }
  }

  /// Search materials by title (fulltext search)
  Future<List<Map<String, dynamic>>> searchMaterials({
    required String query,
    int limit = 50,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        queries: [
          Query.search('title', query),
          Query.equal('status', AppConfig.materialStatusPublished),
          Query.limit(limit),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to search learning materials: ${e.message}');
    }
  }

  /// Get unique categories from all materials
  Future<List<String>> getCategories() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        queries: [
          Query.equal('status', AppConfig.materialStatusPublished),
          Query.limit(500), // Get many to extract unique categories
        ],
      );

      final categories = <String>{};
      for (final doc in response.documents) {
        final category = doc.data['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch categories: ${e.message}');
    }
  }

  /// Get file download/view URL from storage
  Future<String> getFileViewUrl(String fileId) async {
    try {
      // For Appwrite, we can use getFileView which returns a URL
      return '${AppConfig.appwriteEndpoint}/storage/buckets/learning_materials/files/$fileId/view?project=${AppConfig.appwriteProjectId}';
    } catch (e) {
      throw Exception('Failed to generate file URL: ${e.toString()}');
    }
  }

  /// Get file download URL from storage
  Future<String> getFileDownloadUrl(String fileId) async {
    try {
      return '${AppConfig.appwriteEndpoint}/storage/buckets/learning_materials/files/$fileId/download?project=${AppConfig.appwriteProjectId}';
    } catch (e) {
      throw Exception('Failed to generate download URL: ${e.toString()}');
    }
  }

  /// Upload file bytes to storage and create material document
  Future<Map<String, dynamic>> createMaterial({
    required String title,
    required String type,
    required List<int> fileBytes,
    required String fileName,
    required String uploadedBy,
    String? description,
    String? category,
    String? courseId,
  }) async {
    try {
      // 1. Upload file to Appwrite Storage
      final file = await storage.createFile(
        bucketId: AppConfig.storageBucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: fileBytes, filename: fileName),
      );

      final fileId = file.$id;
      final fileSize = file.sizeOriginal;

      // 2. Create learning material document
      final response = await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'description': description,
          'category': category,
          'type': type,
          'fileId': fileId,
          'fileSize': fileSize,
          'courseId': courseId,
          'uploadedBy': uploadedBy,
          'status': AppConfig.materialStatusPublished,
          'viewCount': 0,
          'publishedAt': DateTime.now().toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to create material: ${e.message}');
    }
  }

  /// Update a learning material
  Future<Map<String, dynamic>> updateMaterial({
    required String materialId,
    String? title,
    String? description,
    String? category,
    String? courseId,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (courseId != null) updateData['courseId'] = courseId;
      if (status != null) updateData['status'] = status;

      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        documentId: materialId,
        data: updateData,
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to update material: ${e.message}');
    }
  }

  /// Delete a learning material (and its file)
  Future<void> deleteMaterial(String materialId, String fileId) async {
    try {
      // 1. Delete the file from storage first
      try {
        await storage.deleteFile(
          bucketId: AppConfig.storageBucketId,
          fileId: fileId,
        );
      } catch (e) {
        // Continue even if file deletion fails
        print('Warning: Failed to delete file from storage: $e');
      }

      // 2. Delete the document
      await databases.deleteDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        documentId: materialId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to delete material: ${e.message}');
    }
  }

  /// Get all courses (for dropdown selection)
  Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.coursesCollectionId,
        queries: [
          Query.equal('status', 'active'),
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch courses: ${e.message}');
    }
  }
}
