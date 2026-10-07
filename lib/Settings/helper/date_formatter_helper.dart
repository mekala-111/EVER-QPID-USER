import 'package:intl/intl.dart';

String formatForDisplay(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

String formatForApi(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
