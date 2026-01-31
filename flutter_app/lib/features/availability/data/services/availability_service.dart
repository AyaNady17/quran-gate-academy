import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Availability Service - Handles all Appwrite operations for teacher availability
class AvailabilityService {
  final Databases databases;

  AvailabilityService({required this.databases});

  /// Create a new availability slot
  Future<Map<String, dynamic>> createAvailabilitySlot({
    required String teacherId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.teacherAvailabilityCollectionId,
        documentId: ID.unique(),
        data: {
          'teacherId': teacherId,
          'dayOfWeek': dayOfWeek,
          'startTime': startTime,
          'endTime': endTime,
          'isAvailable': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to create availability slot: ${e.message}');
    }
  }

  /// Get all availability slots for a teacher
  Future<List<Map<String, dynamic>>> getTeacherAvailability({
    required String teacherId,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.teacherAvailabilityCollectionId,
        queries: [
          Query.equal('teacherId', teacherId),
          Query.orderAsc('dayOfWeek'),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch teacher availability: ${e.message}');
    }
  }

  /// Update an availability slot
  Future<Map<String, dynamic>> updateAvailabilitySlot({
    required String slotId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isAvailable,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (dayOfWeek != null) data['dayOfWeek'] = dayOfWeek;
      if (startTime != null) data['startTime'] = startTime;
      if (endTime != null) data['endTime'] = endTime;
      if (isAvailable != null) data['isAvailable'] = isAvailable;

      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.teacherAvailabilityCollectionId,
        documentId: slotId,
        data: data,
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to update availability slot: ${e.message}');
    }
  }

  /// Delete an availability slot
  Future<void> deleteAvailabilitySlot(String slotId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.teacherAvailabilityCollectionId,
        documentId: slotId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to delete availability slot: ${e.message}');
    }
  }

  /// Check if a teacher is available at a specific time
  Future<bool> checkAvailability({
    required String teacherId,
    required String dayOfWeek,
    required String time,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.teacherAvailabilityCollectionId,
        queries: [
          Query.equal('teacherId', teacherId),
          Query.equal('dayOfWeek', dayOfWeek),
          Query.equal('isAvailable', true),
        ],
      );

      // Check if the requested time falls within any availability slot
      for (final doc in response.documents) {
        final startTime = doc.data['startTime'] as String;
        final endTime = doc.data['endTime'] as String;

        if (_isTimeInRange(time, startTime, endTime)) {
          return true;
        }
      }

      return false;
    } on AppwriteException catch (e) {
      throw Exception('Failed to check availability: ${e.message}');
    }
  }

  /// Helper method to check if a time falls within a range
  bool _isTimeInRange(String time, String startTime, String endTime) {
    final timeParts = time.split(':');
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final timeMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }
}
