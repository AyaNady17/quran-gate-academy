import 'package:quran_gate_academy/core/models/learning_material_model.dart';

/// Repository interface for learning materials
abstract class LearningMaterialRepository {
  /// Get all published learning materials with optional filters
  Future<List<LearningMaterialModel>> getAllMaterials({
    String? category,
    String? type,
  });

  /// Get materials for specific courses (for course-based access)
  Future<List<LearningMaterialModel>> getMaterialsForCourses({
    required List<String> courseIds,
    String? category,
    String? type,
  });

  /// Get a single material by ID
  Future<LearningMaterialModel> getMaterial(String materialId);

  /// Increment view count for a material
  Future<void> incrementViewCount(String materialId);

  /// Search materials by title
  Future<List<LearningMaterialModel>> searchMaterials(String query);

  /// Get all unique categories from materials
  Future<List<String>> getCategories();
}
