import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal MaterialApp wrapper for widget / golden tests.
Future<void> pumpMaterial(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: child),
    ),
  );
}
