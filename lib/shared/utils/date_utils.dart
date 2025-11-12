import 'package:intl/intl.dart';

class AppDateUtils {
  static const String defaultDateFormat = 'dd/MM/yyyy';
  static const String defaultDateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String databaseDateFormat = 'yyyy-MM-dd';
  static const String databaseDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  /// Format date for display
  static String formatDate(DateTime date, [String? format]) {
    final formatter = DateFormat(format ?? defaultDateFormat);
    return formatter.format(date);
  }

  /// Format datetime for display
  static String formatDateTime(DateTime dateTime, [String? format]) {
    final formatter = DateFormat(format ?? defaultDateTimeFormat);
    return formatter.format(dateTime);
  }

  /// Format date for database storage
  static String formatDateForDatabase(DateTime date) {
    final formatter = DateFormat(databaseDateFormat);
    return formatter.format(date);
  }

  /// Format datetime for database storage
  static String formatDateTimeForDatabase(DateTime dateTime) {
    final formatter = DateFormat(databaseDateTimeFormat);
    return formatter.format(dateTime);
  }

  /// Parse date from string
  static DateTime? parseDate(String dateString, [String? format]) {
    try {
      final formatter = DateFormat(format ?? defaultDateFormat);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse datetime from string
  static DateTime? parseDateTime(String dateTimeString, [String? format]) {
    try {
      final formatter = DateFormat(format ?? defaultDateTimeFormat);
      return formatter.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Get days difference between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get relative time string (e.g., "2 days ago", "in 3 days")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.isNegative) {
      // Past
      final absDifference = difference.abs();
      if (absDifference.inDays > 0) {
        return '${absDifference.inDays} ngày trước';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} giờ trước';
      } else if (absDifference.inMinutes > 0) {
        return '${absDifference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } else {
      // Future
      if (difference.inDays > 0) {
        return 'Trong ${difference.inDays} ngày';
      } else if (difference.inHours > 0) {
        return 'Trong ${difference.inHours} giờ';
      } else if (difference.inMinutes > 0) {
        return 'Trong ${difference.inMinutes} phút';
      } else {
        return 'Ngay bây giờ';
      }
    }
  }

  /// Get Vietnamese day of week
  static String getVietnameseDayOfWeek(DateTime date) {
    const days = [
      'Chủ nhật',
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
    ];
    return days[date.weekday % 7];
  }

  /// Get Vietnamese month name
  static String getVietnameseMonth(DateTime date) {
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return months[date.month - 1];
  }
}