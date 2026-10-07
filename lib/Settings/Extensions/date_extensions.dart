import 'package:intl/intl.dart';

extension DateFormatter on String {
  /// Converts a date string from one format to another.
  String formatDate(
      {required String inputFormat, required String outputFormat}) {
    try {
      DateTime inputDate = DateFormat(inputFormat).parse(this);
      return DateFormat(outputFormat).format(inputDate);
    } catch (e) {
      return this;
    }
  }

  /// Converts a date string to a DateTime object.
  DateTime? toDateTime({required String format}) {
    try {
      return DateFormat(format).parse(this);
    } catch (e) {
      return null;
    }
  }
}

extension DateTimeFormatter on DateTime {
  /// Formats a DateTime object to a string.
  String format({required String format}) {
    return DateFormat(format).format(this);
  }
}
