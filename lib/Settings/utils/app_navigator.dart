import 'package:flutter/material.dart';

/// App-wide navigator key, kept out of `main.dart` so the data layer can
/// navigate without importing the app entrypoint.
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState? get state => key.currentState;

  static BuildContext? get context => key.currentContext;

  static Future<T?>? pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) =>
      state?.pushNamed<T>(routeName, arguments: arguments);

  static void pushNamedAndRemoveUntil(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    state?.pushNamedAndRemoveUntil(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }
}
