import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/p_colors.dart';

class FlutterToastClass {
  static Timer? _debounceTimer;

  static toast(String text) {
    // Cancel any ongoing debounce timer
    if (_debounceTimer?.isActive ?? false) {
      return; // Ignore subsequent calls within the debounce period
    }

    // Show the toast message
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 4,
      backgroundColor: PColors.primaryColor,
      textColor: PColors.colorFFFFFF,
      fontSize: 13.0,
    );

    // Start a debounce timer
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      // Allow subsequent calls after the timer expires
    });
  }
}
