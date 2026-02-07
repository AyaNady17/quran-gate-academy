import 'package:quran_gate_academy/core/models/learning_material_model.dart';
import 'package:quran_gate_academy/features/learning_materials/data/services/learning_material_service.dart';
import 'package:quran_gate_academy/features/learning_materials/domain/repositories/learning_material_repository.dart';

/// Learning Material repository implementation
class LearningMaterialRepositoryImpl implements LearningMaterialRepository {
  final LearningMaterialService learningMaterialService;

  LearningMaterialRepositoryImpl({required this.learningMaterialService});

  @override
  Future<List<LearningMaterialModel>> getAllMaterials({
    String? category,
    String? type,
    List<String>? courseIds,
  }) async {
    try {
      List<Map<String, dynamic>> materialsData;

      // If courseIds are provided, filter by courses
      if (courseIds != null && courseIds.isNotEmpty) {
        materialsData = await learningMaterialService.getMaterialsByCourses(
          courseIds: courseIds,
          type: type,
        );
      } else {
        // Otherwise, get all materials with optional filters
        materialsData = await learningMaterialService.getAllMaterials(
          category: category,
          type: type,
        );
      }

      return materialsData
          .map((data) => LearningMaterialModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get learning materials: $e');
    }
  }

  @override
  Future<LearningMaterialModel> getMaterial(String materialId) async {
    try {
      final materialData = await learningMaterialService.getMaterial(materialId);
      final material = LearningMaterialModel.fromJson(materialData);

      // Increment view count asynchronously (don't wait for it)
      incrementViewCount(materialId);

      return material;
    } catch (e) {
      throw Exception('Failed to get learning material: $e');
    }
  }

  @override
  Future<void> incrementViewCount(String materialId) async {
    try {
      // Get current material to get current view count
      final materialData = await learningMaterialService.getMaterial(materialId);
      final currentCount = materialData['viewCount'] as int? ?? 0;

      await learningMaterialService.incrementViewCount(
        materialId,
        currentCount,
      );
    } catch (e) {
      // Silently fail for view count increment
      print('Failed to increment view count: $e');
    }
  }

  @override
  Future<List<LearningMaterialModel>> searchMaterials(String query) async {
    try {
      final materialsData = await learningMaterialService.searchMaterials(
        query: query,
      );
      return materialsData
          .map((data) => LearningMaterialModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search learning materials: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await learningMaterialService.getCategories();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<String> getFileViewUrl(String fileId) async {
    try {
      return await learningMaterialService.getFileViewUrl(fileId);
    } catch (e) {
      throw Exception('Failed to get file view URL: $e');
    }
  }

  @override
  Future<String> getFileDownloadUrl(String fileId) async {
    try {
      return await learningMaterialService.getFileDownloadUrl(fileId);
    } catch (e) {
      throw Exception('Failed to get file download URL: $e');
    }
  }
}
