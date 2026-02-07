import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/learning_material_model.dart';

/// Learning Material State
abstract class LearningMaterialState extends Equatable {
  const LearningMaterialState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LearningMaterialInitial extends LearningMaterialState {}

/// Loading state
class LearningMaterialLoading extends LearningMaterialState {}

/// Loaded state with list of materials
class LearningMaterialsLoaded extends LearningMaterialState {
  final List<LearningMaterialModel> materials;
  final List<String> categories;
  final String? selectedCategory;
  final String? selectedType;

  const LearningMaterialsLoaded({
    required this.materials,
    required this.categories,
    this.selectedCategory,
    this.selectedType,
  });

  @override
  List<Object?> get props => [
        materials,
        categories,
        selectedCategory,
        selectedType,
      ];
}

/// Loaded state for single material detail
class LearningMaterialDetailLoaded extends LearningMaterialState {
  final LearningMaterialModel material;

  const LearningMaterialDetailLoaded({required this.material});

  @override
  List<Object?> get props => [material];
}

/// Material created successfully
class LearningMaterialCreated extends LearningMaterialState {}

/// Material updated successfully
class LearningMaterialUpdated extends LearningMaterialState {}

/// Material deleted successfully
class LearningMaterialDeleted extends LearningMaterialState {}

/// Error state
class LearningMaterialError extends LearningMaterialState {
  final String message;

  const LearningMaterialError(this.message);

  @override
  List<Object?> get props => [message];
}
