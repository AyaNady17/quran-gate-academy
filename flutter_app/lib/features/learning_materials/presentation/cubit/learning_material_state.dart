import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/learning_material_model.dart';

/// Base state for learning materials
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

  const LearningMaterialsLoaded(this.materials);

  @override
  List<Object?> get props => [materials];
}

/// Loaded state with single material detail
class LearningMaterialDetailLoaded extends LearningMaterialState {
  final LearningMaterialModel material;

  const LearningMaterialDetailLoaded(this.material);

  @override
  List<Object?> get props => [material];
}

/// Error state
class LearningMaterialError extends LearningMaterialState {
  final String message;

  const LearningMaterialError(this.message);

  @override
  List<Object?> get props => [message];
}
