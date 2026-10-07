// string_extensions.dart

extension StringExtensions on String {
  // Capitalize first letter of a string
  String toCapitalized() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // Capitalize first letter of each word
  String toTitleCase() {
    if (isEmpty) return '';
    return split(' ').map((word) => word.toCapitalized()).join(' ');
  }

  // Remove any extra spaces
  String removeExtraSpaces() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // Capitalize first letter of each sentence
  String toSentenceCase() {
    if (isEmpty) return '';
    return replaceAllMapped(RegExp(r'(^|\.\s+)([a-z])'),
        (Match m) => '${m[1]}${m[2]?.toUpperCase()}');
  }

  // Check if string is empty or only whitespace
  bool get isBlank => trim().isEmpty;

  // Check if string contains only numbers
  bool get isNumeric => num.tryParse(this) != null;

  // Check if string is valid email
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(this);
}

String formatDuration(int totalSeconds) {
  int hours = totalSeconds ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  List<String> parts = [];

  if (hours > 0) parts.add("$hours Hr");
  if (minutes > 0) parts.add("$minutes Min");
  if (seconds > 0 && hours == 0) {
    parts.add("$seconds Sec"); // Show seconds only if no hours
  }

  return parts.join(" ");
}
