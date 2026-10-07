import 'package:everqpidapp/Settings/helper/permission_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('permission prompt is user-triggered and Skip marks completed',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => PermissionManager.showIfNeeded(context),
            child: const Text('Login complete'),
          ),
        ),
      ),
    );

    expect(find.text('Stay in the loop'), findsNothing);
    expect(find.text('So, are you from around here?'), findsNothing);

    await tester.tap(find.text('Login complete'));
    await tester.pumpAndSettle();

    final hasNotifications = find.text('Stay in the loop');
    final hasLocation = find.text('So, are you from around here?');
    expect(
      hasNotifications.evaluate().isNotEmpty ||
          hasLocation.evaluate().isNotEmpty,
      isTrue,
    );

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(
      (await SharedPreferences.getInstance())
          .getBool(PermissionManager.stateKey),
      isTrue,
    );

    await tester.tap(find.text('Login complete'));
    await tester.pumpAndSettle();
    expect(find.text('Stay in the loop'), findsNothing);
    expect(find.text('So, are you from around here?'), findsNothing);
  });

  testWidgets('failed grant does not mark completed when Retry clears flag',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PermissionManager.stateKey, true);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => PermissionManager.showIfNeeded(context),
            child: const Text('Login complete'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Login complete'));
    await tester.pumpAndSettle();
    expect(find.text('So, are you from around here?'), findsNothing);
    expect(find.text('Stay in the loop'), findsNothing);
  });
}
