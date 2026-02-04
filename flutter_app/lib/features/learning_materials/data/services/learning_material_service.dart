import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Service for fetching learning materials
class LearningMaterialService {
  final Databases databases;
  final Storage storage;

  LearningMaterialService({
    required this.databases,
    required this.storage,
  });

  /// Get all published learning materials with optional filters
  Future<List<Map<String, dynamic>>> getAllMaterials({
    String? category,
    String? type,
    String? courseId,
    int limit = 100,
  }) async {
    try {
      final queries = <String>[
        Query.equal('status', AppConfig.materialStatusPublished),
        Query.orderDesc('publishedAt'),
        Query.limit(limit),
      ];

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

  /// Get materials for multiple courses (for students enrolled in multiple courses)
  Future<List<Map<String, dynamic>>> getMaterialsForCourses({
    required List<String> courseIds,
    String? category,
    String? type,
  }) async {
    try {
      if (courseIds.isEmpty) {
        return [];
      }

      // Fetch materials for each course and combine results
      final allMaterials = <Map<String, dynamic>>[];

      for (final courseId in courseIds) {
        final materials = await getAllMaterials(
          courseId: courseId,
          category: category,
          type: type,
        );
        allMaterials.addAll(materials);
      }

      // Remove duplicates by material ID
      final uniqueMaterials = <String, Map<String, dynamic>>{};
      for (final material in allMaterials) {
        final id = material['\$id'] as String?;
        if (id != null) {
          uniqueMaterials[id] = material;
        }
      }

      // Sort by publishedAt descending
      final sortedMaterials = uniqueMaterials.values.toList();
      sortedMaterials.sort((a, b) {
        final aDate = a['publishedAt'] as String?;
        final bDate = b['publishedAt'] as String?;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return sortedMaterials;
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch materials for courses: ${e.message}');
    }
  }

  /// Get material by ID
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
        throw Exception('Material not found');
      }
      throw Exception('Failed to fetch material: ${e.message}');
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String materialId, int currentCount) async {
    try {
      await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        documentId: materialId,
        data: {'viewCount': currentCount + 1},
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to update view count: ${e.message}');
    }
  }

  /// Search materials by title (fulltext search)
  Future<List<Map<String, dynamic>>> searchMaterials(String query) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        queries: [
          Query.equal('status', AppConfig.materialStatusPublished),
          Query.search('title', query),
          Query.limit(50),
        ],
      );
      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to search materials: ${e.message}');
    }
  }
}
