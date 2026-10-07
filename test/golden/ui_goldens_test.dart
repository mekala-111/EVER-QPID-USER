import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// Shell goldens only — no Google Fonts / network widgets (CI offline).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Goldens', () {
    testWidgets('primary button', (tester) async {
      await pumpMaterial(
        tester,
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
            onPressed: () {},
            child: const Text('Continue'),
          ),
        ),
      );
      await expectLater(
        find.byType(ElevatedButton),
        matchesGoldenFile('goldens/primary_button.png'),
      );
    });

    testWidgets('profile card', (tester) async {
      await pumpMaterial(
        tester,
        SizedBox(
          width: 320,
          child: Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: PColors.primaryColor),
              title: const Text('Alex, 28'),
              subtitle: const Text('Kochi · Verified'),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(Card),
        matchesGoldenFile('goldens/profile_card.png'),
      );
    });

    testWidgets('chat bubble', (tester) async {
      await pumpMaterial(
        tester,
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            key: const Key('chat_bubble_shell'),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: PColors.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Hey there',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
      await expectLater(
        find.byKey(const Key('chat_bubble_shell')),
        matchesGoldenFile('goldens/chat_bubble.png'),
      );
    });

    testWidgets('subscription card', (tester) async {
      await pumpMaterial(
        tester,
        SizedBox(
          width: 320,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly', style: TextStyle(fontSize: 20)),
                  const Text('₹399'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Buy'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(Card),
        matchesGoldenFile('goldens/subscription_card.png'),
      );
    });

    testWidgets('clan card', (tester) async {
      await pumpMaterial(
        tester,
        SizedBox(
          width: 320,
          child: Card(
            child: ListTile(
              title: const Text('Friends'),
              subtitle: const Text('Nearby · 12 people'),
              trailing: Icon(Icons.groups, color: PColors.primaryColor),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(Card),
        matchesGoldenFile('goldens/clan_card.png'),
      );
    });

    testWidgets('dialog', (tester) async {
      await pumpMaterial(
        tester,
        const AlertDialog(
          title: Text('Log out?'),
          content: Text('You can sign back in anytime.'),
        ),
      );
      await expectLater(
        find.byType(AlertDialog),
        matchesGoldenFile('goldens/dialog.png'),
      );
    });
  });
}
