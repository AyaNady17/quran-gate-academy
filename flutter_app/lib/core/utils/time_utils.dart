/// Utility class for handling time formatting and parsing
/// Ensures consistent time handling across the application
class TimeUtils {
  /// Parse a time string in various formats to DateTime
  /// Accepts: "HH:mm", "H:mm", "HH:mm AM/PM", "H:mm AM/PM"
  /// Returns DateTime with the time set (date will be today)
  static DateTime parseTimeString(String timeString, DateTime date) {
    try {
      // Remove extra whitespace
      timeString = timeString.trim();

      // Check if it contains AM/PM
      final hasAmPm = timeString.toUpperCase().contains('AM') ||
          timeString.toUpperCase().contains('PM');

      if (hasAmPm) {
        // Parse 12-hour format with AM/PM
        final isPm = timeString.toUpperCase().contains('PM');
        final timeOnly = timeString
            .toUpperCase()
            .replaceAll('AM', '')
            .replaceAll('PM', '')
            .trim();

        final parts = timeOnly.split(':');
        if (parts.length != 2) {
          throw FormatException('Invalid time format: $timeString');
        }

        int hour = int.parse(parts[0].trim());
        final minute = int.parse(parts[1].trim());

        // Convert to 24-hour format
        if (isPm && hour != 12) {
          hour += 12;
        } else if (!isPm && hour == 12) {
          hour = 0;
        }

        return DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
      } else {
        // Parse 24-hour format (HH:mm)
        final parts = timeString.split(':');
        if (parts.length != 2) {
          throw FormatException('Invalid time format: $timeString');
        }

        final hour = int.parse(parts[0].trim());
        final minute = int.parse(parts[1].trim());

        return DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
      }
    } catch (e) {
      throw FormatException('Failed to parse time: $timeString - ${e.toString()}');
    }
  }

  /// Format time string from 24-hour format to 12-hour format with AM/PM
  /// Input: "14:30" or "09:00"
  /// Output: "2:30 PM" or "9:00 AM"
  static String formatTo12Hour(String time24Hour) {
    try {
      final parts = time24Hour.split(':');
      if (parts.length != 2) {
        return time24Hour; // Return as-is if format is unexpected
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24Hour; // Return as-is if parsing fails
    }
  }

  /// Format time string to 24-hour format (HH:mm)
  /// Ensures consistent storage format
  /// Input: "14:30" or "2:30 PM" or "9:00 AM"
  /// Output: "14:30" or "14:30" or "09:00"
  static String formatTo24Hour(String timeString) {
    try {
      // If already in 24-hour format, just ensure padding
      if (!timeString.toUpperCase().contains('AM') &&
          !timeString.toUpperCase().contains('PM')) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0].trim());
          final minute = int.parse(parts[1].trim());
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
      }

      // Parse and convert to 24-hour format
      final isPm = timeString.toUpperCase().contains('PM');
      final timeOnly = timeString
          .toUpperCase()
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim();

      final parts = timeOnly.split(':');
      if (parts.length != 2) {
        return timeString; // Return as-is if format is unexpected
      }

      int hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());

      // Convert to 24-hour format
      if (isPm && hour != 12) {
        hour += 12;
      } else if (!isPm && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString; // Return as-is if parsing fails
    }
  }

  /// Get the current time in 24-hour format
  static String getCurrentTime24Hour() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Check if a time string is in valid format
  static bool isValidTimeFormat(String timeString) {
    try {
      final cleanTime = timeString
          .toUpperCase()
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim();
      final parts = cleanTime.split(':');
      if (parts.length != 2) return false;

      final hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());

      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }
}
