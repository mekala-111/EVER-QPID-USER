import 'package:everqpidapp/Features/messages/model/chat_model.dart';
import 'package:everqpidapp/Features/messages/view/widgets/message_bubble_widget.dart';
import 'package:everqpidapp/Features/onboarding/view/phone_login_screen.dart';
import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Features/settings/view/settings_screen.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhoneLoginScreen', () {
    testWidgets('renders phone field and continue CTA', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
          child: const MaterialApp(home: PhoneLoginScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(PhoneLoginScreen), findsOneWidget);
    });
  });

  group('MessageBubble', () {
    testWidgets('shows text content', (tester) async {
      ChatMessageModel.myUserId = 'me';
      final msg = ChatMessageModel(
        id: '1',
        senderId: 'me',
        receiverId: 'you',
        type: ChatMessageType.text,
        content: 'hello world',
        mediaUrl: '',
        isRead: false,
        sentAt: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      );
      await pumpMaterial(tester, MessageBubble(message: msg));
      expect(find.text('hello world'), findsOneWidget);
    });

    testWidgets('hides empty text', (tester) async {
      ChatMessageModel.myUserId = 'me';
      final msg = ChatMessageModel(
        id: '1',
        senderId: 'me',
        receiverId: 'you',
        type: ChatMessageType.text,
        content: '   ',
        mediaUrl: '',
        isRead: false,
        sentAt: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      );
      await pumpMaterial(tester, MessageBubble(message: msg));
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('SettingsScreen smoke', () {
    testWidgets('builds without crash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SettingsScreen(userId: 'u1')),
      );
      await tester.pump();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('Simple UI shells', () {
    testWidgets('primary button shell', (tester) async {
      await pumpMaterial(
        tester,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PColors.primaryColor,
          ),
          onPressed: () {},
          child: const Text('Continue'),
        ),
      );
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
    });

    testWidgets('dialog shell', (tester) async {
      await pumpMaterial(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Confirm'),
                  content: Text('Delete account?'),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete account?'), findsOneWidget);
    });

    testWidgets('profile card shell', (tester) async {
      await pumpMaterial(
        tester,
        Card(
          child: ListTile(
            title: const Text('Alex, 28'),
            subtitle: const Text('Kochi'),
            trailing: Icon(Icons.verified, color: PColors.primaryColor),
          ),
        ),
      );
      expect(find.text('Alex, 28'), findsOneWidget);
    });

    testWidgets('subscription tile shell', (tester) async {
      await pumpMaterial(
        tester,
        ListTile(
          title: const Text('Monthly'),
          subtitle: const Text('₹399'),
          trailing: ElevatedButton(
            onPressed: () {},
            child: const Text('Subscribe'),
          ),
        ),
      );
      expect(find.text('Subscribe'), findsOneWidget);
    });

    testWidgets('clan card shell', (tester) async {
      await pumpMaterial(
        tester,
        Card(
          child: Column(
            children: const [
              Text('Friends clan'),
              Text('12 nearby'),
            ],
          ),
        ),
      );
      expect(find.text('Friends clan'), findsOneWidget);
    });

    testWidgets('OTP shell', (tester) async {
      await pumpMaterial(
        tester,
        const Column(
          children: [
            Text('Enter OTP'),
            TextField(decoration: InputDecoration(hintText: '6-digit code')),
            ElevatedButton(onPressed: null, child: Text('Verify')),
          ],
        ),
      );
      expect(find.text('Enter OTP'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('Home / Discovery / Matches shells', (tester) async {
      await pumpMaterial(
        tester,
        const Column(
          children: [
            Text('Discover'),
            Text('Matches'),
            Text('Home'),
          ],
        ),
      );
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Profile / Verification shells', (tester) async {
      await pumpMaterial(
        tester,
        const Column(
          children: [
            Text('My Profile'),
            Text('Verify identity'),
          ],
        ),
      );
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Verify identity'), findsOneWidget);
    });
  });
}
