import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String formatMonthYear(int year, int month) {
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatQuantity(double quantity) {
    return quantity.toStringAsFixed(2);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d/M').format(date);
  }
}
