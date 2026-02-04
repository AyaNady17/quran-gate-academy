import 'package:quran_gate_academy/core/models/learning_material_model.dart';
import 'package:quran_gate_academy/features/learning_materials/data/services/learning_material_service.dart';
import 'package:quran_gate_academy/features/learning_materials/domain/repositories/learning_material_repository.dart';

/// Implementation of LearningMaterialRepository
class LearningMaterialRepositoryImpl implements LearningMaterialRepository {
  final LearningMaterialService learningMaterialService;

  LearningMaterialRepositoryImpl({
    required this.learningMaterialService,
  });

  @override
  Future<List<LearningMaterialModel>> getAllMaterials({
    String? category,
    String? type,
  }) async {
    try {
      final materialsData = await learningMaterialService.getAllMaterials(
        category: category,
        type: type,
      );
      return materialsData
          .map((data) => LearningMaterialModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get materials: $e');
    }
  }

  @override
  Future<List<LearningMaterialModel>> getMaterialsForCourses({
    required List<String> courseIds,
    String? category,
    String? type,
  }) async {
    try {
      final materialsData = await learningMaterialService.getMaterialsForCourses(
        courseIds: courseIds,
        category: category,
        type: type,
      );
      return materialsData
          .map((data) => LearningMaterialModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get materials for courses: $e');
    }
  }

  @override
  Future<LearningMaterialModel> getMaterial(String materialId) async {
    try {
      final materialData = await learningMaterialService.getMaterial(materialId);
      return LearningMaterialModel.fromJson(materialData);
    } catch (e) {
      throw Exception('Failed to get material: $e');
    }
  }

  @override
  Future<void> incrementViewCount(String materialId) async {
    try {
      // First get current material to get the view count
      final material = await getMaterial(materialId);
      await learningMaterialService.incrementViewCount(
        materialId,
        material.viewCount,
      );
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  @override
  Future<List<LearningMaterialModel>> searchMaterials(String query) async {
    try {
      final materialsData = await learningMaterialService.searchMaterials(query);
      return materialsData
          .map((data) => LearningMaterialModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search materials: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      // Get all materials and extract unique categories
      final materials = await getAllMaterials();
      final categories = materials
          .where((m) => m.category != null && m.category!.isNotEmpty)
          .map((m) => m.category!)
          .toSet()
          .toList();
      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }
}
