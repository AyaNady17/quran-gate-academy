import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/learning_materials/domain/repositories/learning_material_repository.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_state.dart';

/// Cubit for managing learning materials state
class LearningMaterialCubit extends Cubit<LearningMaterialState> {
  final LearningMaterialRepository learningMaterialRepository;

  LearningMaterialCubit({
    required this.learningMaterialRepository,
  }) : super(LearningMaterialInitial());

  /// Load all materials with optional filters
  Future<void> loadMaterials({
    String? category,
    String? type,
  }) async {
    emit(LearningMaterialLoading());
    try {
      final materials = await learningMaterialRepository.getAllMaterials(
        category: category,
        type: type,
      );
      emit(LearningMaterialsLoaded(materials));
    } catch (e) {
      emit(LearningMaterialError('Failed to load materials: ${e.toString()}'));
    }
  }

  /// Load materials for specific courses (for students)
  Future<void> loadMaterialsForCourses({
    required List<String> courseIds,
    String? category,
    String? type,
  }) async {
    emit(LearningMaterialLoading());
    try {
      if (courseIds.isEmpty) {
        emit(const LearningMaterialsLoaded([]));
        return;
      }

      final materials = await learningMaterialRepository.getMaterialsForCourses(
        courseIds: courseIds,
        category: category,
        type: type,
      );
      emit(LearningMaterialsLoaded(materials));
    } catch (e) {
      emit(LearningMaterialError('Failed to load materials: ${e.toString()}'));
    }
  }

  /// Load a single material by ID and increment view count
  Future<void> loadMaterial(String materialId) async {
    emit(LearningMaterialLoading());
    try {
      final material = await learningMaterialRepository.getMaterial(materialId);

      // Increment view count in background (don't wait)
      learningMaterialRepository.incrementViewCount(materialId).catchError((_) {
        // Silently fail if view count increment fails
      });

      emit(LearningMaterialDetailLoaded(material));
    } catch (e) {
      emit(LearningMaterialError('Failed to load material: ${e.toString()}'));
    }
  }

  /// Search materials by query
  Future<void> searchMaterials(String query) async {
    if (query.trim().isEmpty) {
      await loadMaterials();
      return;
    }

    emit(LearningMaterialLoading());
    try {
      final materials = await learningMaterialRepository.searchMaterials(query);
      emit(LearningMaterialsLoaded(materials));
    } catch (e) {
      emit(LearningMaterialError('Failed to search materials: ${e.toString()}'));
    }
  }

  /// Refresh materials list
  Future<void> refreshMaterials() async {
    await loadMaterials();
  }
}
