import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/availability/domain/repositories/availability_repository.dart';
import 'package:quran_gate_academy/features/availability/presentation/cubit/availability_state.dart';

/// Availability Cubit - Manages teacher availability state
class AvailabilityCubit extends Cubit<AvailabilityState> {
  final AvailabilityRepository availabilityRepository;

  AvailabilityCubit({required this.availabilityRepository})
      : super(AvailabilityInitial());

  /// Load teacher's availability slots
  Future<void> loadAvailability({required String teacherId}) async {
    emit(AvailabilityLoading());
    try {
      final slots = await availabilityRepository.getTeacherAvailability(
        teacherId: teacherId,
      );
      emit(AvailabilityLoaded(slots));
    } catch (e) {
      emit(AvailabilityError('Failed to load availability: ${e.toString()}'));
    }
  }

  /// Create a new availability slot
  Future<void> createSlot({
    required String teacherId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    emit(AvailabilityLoading());
    try {
      final slot = await availabilityRepository.createAvailabilitySlot(
        teacherId: teacherId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );
      emit(AvailabilitySlotCreated(slot));
    } catch (e) {
      emit(AvailabilityError('Failed to create slot: ${e.toString()}'));
    }
  }

  /// Update an existing availability slot
  Future<void> updateSlot({
    required String slotId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isAvailable,
  }) async {
    emit(AvailabilityLoading());
    try {
      final slot = await availabilityRepository.updateAvailabilitySlot(
        slotId: slotId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        isAvailable: isAvailable,
      );
      emit(AvailabilitySlotUpdated(slot));
    } catch (e) {
      emit(AvailabilityError('Failed to update slot: ${e.toString()}'));
    }
  }

  /// Delete an availability slot
  Future<void> deleteSlot(String slotId) async {
    emit(AvailabilityLoading());
    try {
      await availabilityRepository.deleteAvailabilitySlot(slotId);
      emit(AvailabilitySlotDeleted());
    } catch (e) {
      emit(AvailabilityError('Failed to delete slot: ${e.toString()}'));
    }
  }

  /// Check if teacher is available at a specific time
  Future<void> checkAvailability({
    required String teacherId,
    required String dayOfWeek,
    required String time,
  }) async {
    try {
      final isAvailable = await availabilityRepository.checkAvailability(
        teacherId: teacherId,
        dayOfWeek: dayOfWeek,
        time: time,
      );
      emit(AvailabilityCheckResult(isAvailable));
    } catch (e) {
      emit(AvailabilityError('Failed to check availability: ${e.toString()}'));
    }
  }

  /// Refresh availability
  Future<void> refreshAvailability({required String teacherId}) async {
    await loadAvailability(teacherId: teacherId);
  }
}
