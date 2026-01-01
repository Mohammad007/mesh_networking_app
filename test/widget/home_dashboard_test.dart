import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:offline_chat/ui/screens/home_dashboard_screen.dart';
import 'package:offline_chat/providers/mesh_provider.dart';

// Mock MeshProvider for testing
class MockMeshProvider extends MeshProvider {
  bool _mockMeshActive = false;
  int _mockConnectedNodes = 0;
  int _mockPendingMessages = 0;

  @override
  bool get isMeshActive => _mockMeshActive;

  @override
  int get connectedNodesCount => _mockConnectedNodes;

  @override
  int get pendingMessagesCount => _mockPendingMessages;

  void setMeshActive(bool active) {
    _mockMeshActive = active;
    notifyListeners();
  }

  void setConnectedNodes(int count) {
    _mockConnectedNodes = count;
    notifyListeners();
  }

  void setPendingMessages(int count) {
    _mockPendingMessages = count;
    notifyListeners();
  }
}

void main() {
  group('HomeDashboardScreen Widget Tests', () {
    late MockMeshProvider mockProvider;

    setUp(() {
      mockProvider = MockMeshProvider();
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<MeshProvider>.value(
        value: mockProvider,
        child: const MaterialApp(home: HomeDashboardScreen()),
      );
    }

    testWidgets('Should display MeshNet title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('MeshNet'), findsOneWidget);
    });

    testWidgets('Should display Offline status when mesh is inactive', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockProvider.setMeshActive(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Offline'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should display Online status when mesh is active', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockProvider.setMeshActive(true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('Should display connected nodes count', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockProvider.setMeshActive(true);
      mockProvider.setConnectedNodes(5);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('5'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should display pending messages count', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockProvider.setPendingMessages(3);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('3'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should have mesh toggle switch', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('Should have Quick Actions section', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('Should have Discover Nearby button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Discover Nearby'), findsOneWidget);
    });

    testWidgets('Should have Emergency Broadcast button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Emergency Broadcast'), findsOneWidget);
    });

    testWidgets('Should have Settings icon button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              widget.icon is Icon &&
              (widget.icon as Icon).icon == Icons.settings,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Should display feature grid with 4 items', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Network Map'), findsOneWidget);
      expect(find.text('Connections'), findsOneWidget);
      expect(find.text('Broadcast'), findsOneWidget);
    });

    testWidgets('Should show floating action button when mesh is active', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockProvider.setMeshActive(true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
      'Should not show floating action button when mesh is inactive',
      (WidgetTester tester) async {
        // Arrange
        mockProvider.setMeshActive(false);

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.byType(FloatingActionButton), findsNothing);
      },
    );

    testWidgets('Should display mesh info when active', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockProvider.setMeshActive(true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('P2P'), findsOneWidget);
      expect(find.text('AES-256'), findsOneWidget);
    });

    testWidgets('Should have correct stats card titles', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Online Nearby'), findsOneWidget);
      expect(find.text('Queue'), findsOneWidget);
    });
  });
}
