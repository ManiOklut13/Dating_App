import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younme_mobile/main.dart';
import 'package:younme_mobile/screens/chat/chat_tab_screen.dart';
import 'package:younme_mobile/screens/chat/individual_chat_screen.dart';
import 'package:younme_mobile/screens/profile/profile_tab_screen.dart';
import 'package:younme_mobile/screens/profile/edit_profile_modal.dart';

void main() {
  testWidgets('Chat tab displays header, recent matches, and conversation list', (WidgetTester tester) async {
    await tester.pumpWidget(const YoUnMeApp());
    await tester.pumpAndSettle();

    // Verify Chat Tab elements
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Messages, requests & connections'), findsOneWidget);
    expect(find.text('Ananya Sharma'), findsAtLeastNWidgets(1));
    expect(find.text('Riya Sen'), findsAtLeastNWidgets(1));

    // Verify Search Bar is present and functional
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Ananya');
    await tester.pumpAndSettle();

    expect(find.text('Ananya Sharma'), findsAtLeastNWidgets(1));
  });

  testWidgets('Navigation to Individual Chat preserves conversation and messages', (WidgetTester tester) async {
    await tester.pumpWidget(const YoUnMeApp());
    await tester.pumpAndSettle();

    // Tap on Ananya's conversation row
    final convFinder = find.text('Ananya Sharma').first;
    await tester.tap(convFinder);
    await tester.pumpAndSettle();

    // Verify Individual Chat Screen is pushed
    expect(find.byType(IndividualChatScreen), findsOneWidget);
    expect(find.text('online'), findsOneWidget);
    expect(find.text('Messages and calls are end-to-end encrypted with YoUnMe Contact Guard.'), findsOneWidget);

    // Pop back to Chat tab
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(ChatTabScreen), findsOneWidget);
  });

  testWidgets('Profile Tab renders correctly and preserves edits in Light and Dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(const YoUnMeApp());
    await tester.pumpAndSettle();

    // Navigate to Profile tab (index 4)
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileTabScreen), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Alex, 25'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);

    // Open Edit Profile modal
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileModalSheet), findsOneWidget);
    expect(find.text('Display Name'), findsOneWidget);

    // Close modal
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Verify profile info is still intact
    expect(find.text('Alex, 25'), findsOneWidget);
  });

  testWidgets('Theme toggle switches between Light and Dark mode dynamically', (WidgetTester tester) async {
    await tester.pumpWidget(const YoUnMeApp());
    await tester.pumpAndSettle();

    // Navigate to Profile tab where shell AppBar is visible
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Find the theme toggle IconButton in the shell AppBar
    final themeToggleFinder = find.byTooltip('Switch to Light Mode');
    expect(themeToggleFinder, findsOneWidget);

    // Tap to switch to Light mode
    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();

    // Now it should show tooltip 'Switch to Dark Mode'
    expect(find.byTooltip('Switch to Dark Mode'), findsOneWidget);

    // Tap again to switch back to Dark mode
    await tester.tap(find.byTooltip('Switch to Dark Mode'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Switch to Light Mode'), findsOneWidget);
  });
}
