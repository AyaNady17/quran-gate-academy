import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/availability_model.dart';

/// Base availability state
abstract class AvailabilityState extends Equatable {
  const AvailabilityState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AvailabilityInitial extends AvailabilityState {}

/// Loading state
class AvailabilityLoading extends AvailabilityState {}

/// Availability loaded state
class AvailabilityLoaded extends AvailabilityState {
  final List<AvailabilityModel> slots;

  const AvailabilityLoaded(this.slots);

  @override
  List<Object?> get props => [slots];
}

/// Slot created state
class AvailabilitySlotCreated extends AvailabilityState {
  final AvailabilityModel slot;

  const AvailabilitySlotCreated(this.slot);

  @override
  List<Object?> get props => [slot];
}

/// Slot updated state
class AvailabilitySlotUpdated extends AvailabilityState {
  final AvailabilityModel slot;

  const AvailabilitySlotUpdated(this.slot);

  @override
  List<Object?> get props => [slot];
}

/// Slot deleted state
class AvailabilitySlotDeleted extends AvailabilityState {}

/// Availability check result state
class AvailabilityCheckResult extends AvailabilityState {
  final bool isAvailable;

  const AvailabilityCheckResult(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

/// Error state
class AvailabilityError extends AvailabilityState {
  final String message;

  const AvailabilityError(this.message);

  @override
  List<Object?> get props => [message];
}
