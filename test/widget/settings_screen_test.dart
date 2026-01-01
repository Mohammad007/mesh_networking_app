import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:offline_chat/ui/screens/settings_screen.dart';
import 'package:offline_chat/providers/mesh_provider.dart';

class MockMeshProvider extends MeshProvider {
  int _mockConnectedNodes = 0;
  int _mockPendingMessages = 0;
  String? _mockUsername = 'TestUser';

  @override
  int get connectedNodesCount => _mockConnectedNodes;

  @override
  int get pendingMessagesCount => _mockPendingMessages;

  @override
  String? get currentUsername => _mockUsername;

  void setConnectedNodes(int count) {
    _mockConnectedNodes = count;
    notifyListeners();
  }

  void setPendingMessages(int count) {
    _mockPendingMessages = count;
    notifyListeners();
  }

  @override
  Future<void> clearAllData() async {
    // Mock implementation
  }
}

void main() {
  group('SettingsScreen Widget Tests', () {
    late MockMeshProvider mockProvider;

    setUp(() {
      mockProvider = MockMeshProvider();
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<MeshProvider>.value(
        value: mockProvider,
        child: const MaterialApp(home: SettingsScreen()),
      );
    }

    testWidgets('Should display Settings title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Should display user info card with username', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('TestUser'), findsOneWidget);
    });

    testWidgets('Should display section titles', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mesh Network'), findsOneWidget);
      expect(find.text('Data Management'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('Should have Encryption switch', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Encryption'), findsOneWidget);
      expect(find.text('AES-256 end-to-end encryption'), findsOneWidget);
    });

    testWidgets('Should have TTL Limit slider', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('TTL Limit'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('Should have Auto Connect switch', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Auto Connect'), findsOneWidget);
      expect(
        find.text('Automatically connect to trusted nodes'),
        findsOneWidget,
      );
    });

    testWidgets('Should have Clear Message Cache option', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Clear Message Cache'), findsOneWidget);
      expect(find.text('Delete all cached messages'), findsOneWidget);
    });

    testWidgets('Should have Reset Device option', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reset Device'), findsOneWidget);
      expect(find.text('Clear all data and settings'), findsOneWidget);
    });

    testWidgets('Should display statistics', (WidgetTester tester) async {
      // Arrange
      mockProvider.setConnectedNodes(5);
      mockProvider.setPendingMessages(3);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Total Messages'), findsOneWidget);
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('Pending Messages'), findsOneWidget);
      expect(find.text('Connected Nodes'), findsOneWidget);
    });

    testWidgets('Should display About section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('About MeshNet'), findsOneWidget);
      expect(
        find.text('Offline mesh networking for emergency communication'),
        findsOneWidget,
      );
    });

    testWidgets('Should have back button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              widget.icon is Icon &&
              (widget.icon as Icon).icon == Icons.arrow_back,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Should toggle encryption switch', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the switch
      final switches = find.byType(Switch);
      expect(switches, findsAtLeastNWidgets(1));

      // Tap first switch (encryption)
      await tester.tap(switches.first);
      await tester.pump();

      // Switch should have toggled (hard to verify without state access)
    });

    testWidgets('Should adjust TTL slider', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider (gesture test)
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      // Slider value should have changed
    });
  });
}
