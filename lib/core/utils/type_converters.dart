/// Utility class for safely converting dynamic database values to specific types
class TypeConverters {
  /// Safely convert dynamic value to double
  /// Handles: double, int, String, num, null
  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  /// Safely convert dynamic value to int
  /// Handles: int, double, String, num, null
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  /// Safely convert dynamic value to String
  static String toStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// Safely convert dynamic value to DateTime
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
