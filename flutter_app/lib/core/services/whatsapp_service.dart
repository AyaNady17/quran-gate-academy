import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/models/student_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for WhatsApp integration
/// Handles sending session reminders via WhatsApp deep links
class WhatsAppService {
  /// Send a session reminder via WhatsApp
  ///
  /// Opens WhatsApp on the device with a pre-filled message for the teacher to send.
  /// Returns true if WhatsApp was successfully launched, false otherwise.
  Future<bool> sendReminder({
    required StudentModel student,
    required ClassSessionModel session,
  }) async {
    // Check if student has WhatsApp number
    if (student.whatsapp == null || student.whatsapp!.trim().isEmpty) {
      throw WhatsAppException('Student doesn\'t have a WhatsApp number registered');
    }

    try {
      // Format phone number with country code
      final phoneNumber = _formatPhoneNumber(
        student.whatsapp!,
        student.countryCode,
      );

      // Build reminder message
      final message = _buildMessage(
        studentName: student.fullName,
        session: session,
      );

      // Construct WhatsApp URL
      final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

      // Launch WhatsApp
      return await _launchWhatsApp(whatsappUrl);
    } catch (e) {
      if (e is WhatsAppException) {
        rethrow;
      }
      throw WhatsAppException('Failed to open WhatsApp: ${e.toString()}');
    }
  }

  /// Format phone number to ensure it has country code
  String _formatPhoneNumber(String phone, String? countryCode) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // If number doesn't start with country code, add it
    if (countryCode != null && !cleaned.startsWith(countryCode)) {
      // Remove leading zeros if present
      cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');
      // Add country code
      cleaned = countryCode + cleaned;
    }

    // Ensure we have a valid number (minimum 10 digits)
    if (cleaned.length < 10) {
      throw WhatsAppException('Invalid phone number format');
    }

    return cleaned;
  }

  /// Build the reminder message template
  String _buildMessage({
    required String studentName,
    required ClassSessionModel session,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Hello $studentName,');
    buffer.writeln();
    buffer.writeln('This is a reminder for your Quran class today at ${session.scheduledTime}.');
    buffer.writeln();
    buffer.writeln('Course: ${session.courseId}');
    buffer.writeln('Duration: ${session.duration} minutes');

    if (session.meetingLink != null && session.meetingLink!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Meeting Link: ${session.meetingLink}');
    }

    buffer.writeln();
    buffer.writeln('Looking forward to seeing you!');

    return buffer.toString();
  }

  /// Launch WhatsApp with the constructed URL
  Future<bool> _launchWhatsApp(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw WhatsAppException(
        'Unable to open WhatsApp. Please check if it\'s installed',
      );
    }
  }
}

/// Custom exception for WhatsApp-related errors
class WhatsAppException implements Exception {
  final String message;

  WhatsAppException(this.message);

  @override
  String toString() => message;
}
