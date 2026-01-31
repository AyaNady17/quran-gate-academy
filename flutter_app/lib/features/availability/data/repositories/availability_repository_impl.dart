import 'package:quran_gate_academy/core/models/availability_model.dart';
import 'package:quran_gate_academy/features/availability/data/services/availability_service.dart';
import 'package:quran_gate_academy/features/availability/domain/repositories/availability_repository.dart';

/// Availability repository implementation
class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityService availabilityService;

  AvailabilityRepositoryImpl({required this.availabilityService});

  @override
  Future<AvailabilityModel> createAvailabilitySlot({
    required String teacherId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final slotData = await availabilityService.createAvailabilitySlot(
        teacherId: teacherId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );

      return AvailabilityModel.fromJson(slotData);
    } catch (e) {
      throw Exception('Failed to create availability slot: $e');
    }
  }

  @override
  Future<List<AvailabilityModel>> getTeacherAvailability({
    required String teacherId,
  }) async {
    try {
      final slotsData = await availabilityService.getTeacherAvailability(
        teacherId: teacherId,
      );

      return slotsData
          .map((data) => AvailabilityModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get teacher availability: $e');
    }
  }

  @override
  Future<AvailabilityModel> updateAvailabilitySlot({
    required String slotId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isAvailable,
  }) async {
    try {
      final slotData = await availabilityService.updateAvailabilitySlot(
        slotId: slotId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        isAvailable: isAvailable,
      );

      return AvailabilityModel.fromJson(slotData);
    } catch (e) {
      throw Exception('Failed to update availability slot: $e');
    }
  }

  @override
  Future<void> deleteAvailabilitySlot(String slotId) async {
    try {
      await availabilityService.deleteAvailabilitySlot(slotId);
    } catch (e) {
      throw Exception('Failed to delete availability slot: $e');
    }
  }

  @override
  Future<bool> checkAvailability({
    required String teacherId,
    required String dayOfWeek,
    required String time,
  }) async {
    try {
      return await availabilityService.checkAvailability(
        teacherId: teacherId,
        dayOfWeek: dayOfWeek,
        time: time,
      );
    } catch (e) {
      throw Exception('Failed to check availability: $e');
    }
  }
}
