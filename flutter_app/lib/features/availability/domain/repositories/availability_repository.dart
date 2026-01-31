import 'package:quran_gate_academy/core/models/availability_model.dart';

/// Availability repository interface
abstract class AvailabilityRepository {
  /// Create a new availability slot
  Future<AvailabilityModel> createAvailabilitySlot({
    required String teacherId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  });

  /// Get all availability slots for a teacher
  Future<List<AvailabilityModel>> getTeacherAvailability({
    required String teacherId,
  });

  /// Update an availability slot
  Future<AvailabilityModel> updateAvailabilitySlot({
    required String slotId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isAvailable,
  });

  /// Delete an availability slot
  Future<void> deleteAvailabilitySlot(String slotId);

  /// Check if a teacher is available at a specific time
  Future<bool> checkAvailability({
    required String teacherId,
    required String dayOfWeek,
    required String time,
  });
}
