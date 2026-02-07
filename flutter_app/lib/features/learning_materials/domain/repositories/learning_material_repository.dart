import 'package:quran_gate_academy/core/models/learning_material_model.dart';

/// Learning Material repository interface
abstract class LearningMaterialRepository {
  /// Get all learning materials with optional filters
  Future<List<LearningMaterialModel>> getAllMaterials({
    String? category,
    String? type,
    List<String>? courseIds,
  });

  /// Get a single learning material by ID
  Future<LearningMaterialModel> getMaterial(String materialId);

  /// Increment view count for a material
  Future<void> incrementViewCount(String materialId);

  /// Search materials by title
  Future<List<LearningMaterialModel>> searchMaterials(String query);

  /// Get unique categories
  Future<List<String>> getCategories();

  /// Get file view URL
  Future<String> getFileViewUrl(String fileId);

  /// Get file download URL
  Future<String> getFileDownloadUrl(String fileId);
}
