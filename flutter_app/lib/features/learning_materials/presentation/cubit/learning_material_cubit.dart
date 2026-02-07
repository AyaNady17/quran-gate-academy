import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/learning_materials/domain/repositories/learning_material_repository.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_state.dart';

/// Learning Material Cubit - Manages learning materials state
class LearningMaterialCubit extends Cubit<LearningMaterialState> {
  final LearningMaterialRepository learningMaterialRepository;

  LearningMaterialCubit({
    required this.learningMaterialRepository,
  }) : super(LearningMaterialInitial());

  /// Load all learning materials with optional filters
  Future<void> loadMaterials({
    String? category,
    String? type,
    List<String>? courseIds,
  }) async {
    emit(LearningMaterialLoading());
    try {
      // Fetch materials with filters
      final materials = await learningMaterialRepository.getAllMaterials(
        category: category,
        type: type,
        courseIds: courseIds,
      );

      // Fetch all categories for filtering
      final categories = await learningMaterialRepository.getCategories();

      emit(LearningMaterialsLoaded(
        materials: materials,
        categories: categories,
        selectedCategory: category,
        selectedType: type,
      ));
    } catch (e) {
      emit(LearningMaterialError(
          'Failed to load learning materials: ${e.toString()}'));
    }
  }

  /// Load a single learning material by ID
  Future<void> loadMaterial(String materialId) async {
    emit(LearningMaterialLoading());
    try {
      final material = await learningMaterialRepository.getMaterial(materialId);

      emit(LearningMaterialDetailLoaded(material: material));
    } catch (e) {
      emit(LearningMaterialError(
          'Failed to load learning material: ${e.toString()}'));
    }
  }

  /// Search learning materials by title
  Future<void> searchMaterials(String query) async {
    if (query.isEmpty) {
      // If empty query, reload all materials
      await loadMaterials();
      return;
    }

    emit(LearningMaterialLoading());
    try {
      final materials = await learningMaterialRepository.searchMaterials(query);

      // Fetch all categories for filtering
      final categories = await learningMaterialRepository.getCategories();

      emit(LearningMaterialsLoaded(
        materials: materials,
        categories: categories,
      ));
    } catch (e) {
      emit(LearningMaterialError(
          'Failed to search learning materials: ${e.toString()}'));
    }
  }

  /// Filter materials by category
  Future<void> filterByCategory(String? category, {List<String>? courseIds}) async {
    final currentState = state;
    if (currentState is LearningMaterialsLoaded) {
      await loadMaterials(
        category: category,
        type: currentState.selectedType,
        courseIds: courseIds,
      );
    } else {
      await loadMaterials(category: category, courseIds: courseIds);
    }
  }

  /// Filter materials by type
  Future<void> filterByType(String? type, {List<String>? courseIds}) async {
    final currentState = state;
    if (currentState is LearningMaterialsLoaded) {
      await loadMaterials(
        category: currentState.selectedCategory,
        type: type,
        courseIds: courseIds,
      );
    } else {
      await loadMaterials(type: type, courseIds: courseIds);
    }
  }

  /// Refresh materials list
  Future<void> refreshMaterials({List<String>? courseIds}) async {
    final currentState = state;
    if (currentState is LearningMaterialsLoaded) {
      await loadMaterials(
        category: currentState.selectedCategory,
        type: currentState.selectedType,
        courseIds: courseIds,
      );
    } else {
      await loadMaterials(courseIds: courseIds);
    }
  }

  /// Get file view URL
  Future<String> getFileViewUrl(String fileId) async {
    try {
      return await learningMaterialRepository.getFileViewUrl(fileId);
    } catch (e) {
      throw Exception('Failed to get file URL: ${e.toString()}');
    }
  }

  /// Get file download URL
  Future<String> getFileDownloadUrl(String fileId) async {
    try {
      return await learningMaterialRepository.getFileDownloadUrl(fileId);
    } catch (e) {
      throw Exception('Failed to get download URL: ${e.toString()}');
    }
  }

  /// Create a new learning material
  Future<void> createMaterial({
    required String title,
    required String type,
    required List<int> fileBytes,
    required String fileName,
    required String uploadedBy,
    String? description,
    String? category,
    String? courseId,
  }) async {
    emit(LearningMaterialLoading());
    try {
      await learningMaterialRepository.createMaterial(
        title: title,
        type: type,
        fileBytes: fileBytes,
        fileName: fileName,
        uploadedBy: uploadedBy,
        description: description,
        category: category,
        courseId: courseId,
      );
      emit(LearningMaterialCreated());
    } catch (e) {
      emit(LearningMaterialError('Failed to create material: ${e.toString()}'));
    }
  }

  /// Update a learning material
  Future<void> updateMaterial({
    required String materialId,
    String? title,
    String? description,
    String? category,
    String? courseId,
    String? status,
  }) async {
    emit(LearningMaterialLoading());
    try {
      await learningMaterialRepository.updateMaterial(
        materialId: materialId,
        title: title,
        description: description,
        category: category,
        courseId: courseId,
        status: status,
      );
      emit(LearningMaterialUpdated());
    } catch (e) {
      emit(LearningMaterialError('Failed to update material: ${e.toString()}'));
    }
  }

  /// Delete a learning material
  Future<void> deleteMaterial(String materialId, String fileId) async {
    emit(LearningMaterialLoading());
    try {
      await learningMaterialRepository.deleteMaterial(materialId, fileId);
      emit(LearningMaterialDeleted());
    } catch (e) {
      emit(LearningMaterialError('Failed to delete material: ${e.toString()}'));
    }
  }

  /// Get all courses
  Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      return await learningMaterialRepository.getAllCourses();
    } catch (e) {
      throw Exception('Failed to get courses: ${e.toString()}');
    }
  }
}
