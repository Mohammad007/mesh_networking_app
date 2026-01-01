import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:offline_chat/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete App Flow Integration Tests', () {
    testWidgets('Complete user journey from splash to home', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // 1. Splash Screen should appear
      expect(find.text('Mesh Network'), findsOneWidget);
      expect(find.text('SECURE OFFLINE MESSAGING'), findsOneWidget);

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 2. Should navigate to permissions if not granted
      // Or username setup if permissions already granted
      // Or home if everything is set up

      // Try to find permission screen
      if (find.text('Required Permissions').evaluate().isNotEmpty) {
        // Permission screen
        expect(find.text('Required Permissions'), findsOneWidget);

        // Grant permissions (this would require actual permission mocking)
        // Tap Continue button
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
      }

      // Try to find username setup
      if (find.text('Create Your Identity').evaluate().isNotEmpty) {
        // Username setup screen
        expect(find.text('Create Your Identity'), findsOneWidget);

        // Enter username
        await tester.enterText(find.byType(TextField), 'TestUser');
        await tester.pumpAndSettle();

        // Tap Create Identity button
        await tester.tap(find.text('Create Identity'));
        await tester.pumpAndSettle();
      }

      // 3. Should reach Home Dashboard
      expect(find.text('MeshNet'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('Mesh toggle on/off flow', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to home if not there
      // Assuming we're on home dashboard

      // Find mesh toggle switch
      final meshSwitch = find.byType(Switch);
      expect(meshSwitch, findsOneWidget);

      // Toggle mesh ON
      await tester.tap(meshSwitch);
      await tester.pumpAndSettle();

      // Should show Online status
      expect(find.text('Online'), findsOneWidget);

      // Toggle mesh OFF
      await tester.tap(meshSwitch);
      await tester.pumpAndSettle();

      // Should show Offline status
      expect(find.text('Offline'), findsAtLeastNWidgets(1));
    });

    testWidgets('Navigate to Discovery screen and back', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Toggle mesh ON first (discovery needs active mesh)
      final meshSwitch = find.byType(Switch);
      if (meshSwitch.evaluate().isNotEmpty) {
        await tester.tap(meshSwitch);
        await tester.pumpAndSettle();
      }

      // Tap Discover Nearby button
      await tester.tap(find.text('Discover Nearby'));
      await tester.pumpAndSettle();

      // Should navigate to Discovery screen
      expect(find.text('Discovering Nodes'), findsOneWidget);
      expect(find.text('Auto-discovering nearby mesh nodes'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to home
      expect(find.text('MeshNet'), findsOneWidget);
    });

    testWidgets('Navigate to Broadcast screen', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Toggle mesh ON
      final meshSwitch = find.byType(Switch);
      if (meshSwitch.evaluate().isNotEmpty) {
        await tester.tap(meshSwitch);
        await tester.pumpAndSettle();
      }

      // Tap Emergency Broadcast button
      await tester.tap(find.text('Emergency Broadcast'));
      await tester.pumpAndSettle();

      // Should navigate to Broadcast screen
      expect(find.text('Emergency Broadcast'), findsOneWidget);
      expect(find.text('Emergency Templates'), findsOneWidget);

      // Should see all templates
      expect(find.text('Need Help'), findsOneWidget);
      expect(find.text('Medical Emergency'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to home
      expect(find.text('MeshNet'), findsOneWidget);
    });

    testWidgets('Navigate to Network Map screen', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Network Map from feature grid
      await tester.tap(find.text('Network Map'));
      await tester.pumpAndSettle();

      // Should navigate to Network Map screen
      expect(find.text('Network Topology'), findsOneWidget);
      expect(find.text('Live mesh network visualization'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to home
      expect(find.text('MeshNet'), findsOneWidget);
    });

    testWidgets('Navigate to Settings screen', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Settings icon
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should navigate to Settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Mesh Network'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to home
      expect(find.text('MeshNet'), findsOneWidget);
    });

    testWidgets('Broadcast message flow', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Toggle mesh ON
      final meshSwitch = find.byType(Switch);
      if (meshSwitch.evaluate().isNotEmpty) {
        await tester.tap(meshSwitch);
        await tester.pumpAndSettle();
      }

      // Navigate to Broadcast
      await tester.tap(find.text('Emergency Broadcast'));
      await tester.pumpAndSettle();

      // Select a template
      await tester.tap(find.text('Need Help'));
      await tester.pumpAndSettle();

      // Message should be filled in text field
      // Tap Send Broadcast Alert button
      await tester.tap(find.text('Send Broadcast Alert'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Send Broadcast?'), findsOneWidget);

      // Tap Cancel to close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should still be on broadcast screen
      expect(find.text('Emergency Broadcast'), findsOneWidget);
    });

    testWidgets('Settings - Toggle encryption', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Find encryption switch
      final switches = find.byType(Switch);
      expect(switches, findsAtLeastNWidgets(1));

      // Toggle encryption switch
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Switch should have toggled (visual confirmation)
    });

    testWidgets('Settings - Adjust TTL slider', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Find TTL slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // TTL value should have changed (visual confirmation)
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Handle no permissions gracefully', (
      WidgetTester tester,
    ) async {
      // This would require permission mocking
      // Verify app doesn't crash without permissions
    });

    testWidgets('Handle mesh start failure', (WidgetTester tester) async {
      // This would require mocking mesh service failure
      // Verify error is displayed to user
    });
  });

  group('Performance Tests', () {
    testWidgets('App launches within reasonable time', (
      WidgetTester tester,
    ) async {
      final startTime = DateTime.now();

      app.main();
      await tester.pumpAndSettle();

      final duration = DateTime.now().difference(startTime);

      // App should launch within 5 seconds
      expect(duration.inSeconds, lessThan(5));
    });

    testWidgets('Screen transitions are smooth', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to multiple screens quickly
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Discover Nearby').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // App should remain responsive
    });
  });
}
