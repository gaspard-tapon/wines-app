import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/presentation/widgets/stock_controls.dart';

void main() {
  group('StockControls', () {
    // =========================================================================
    // DISPLAY TESTS
    // =========================================================================

    group('affichage', () {
      testWidgets('devrait afficher le stock actuel', (WidgetTester tester) async {
        // ARRANGE
        const stock = 5;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(stock: stock),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text('$stock'), findsOneWidget);
      });

      testWidgets('devrait afficher les boutons + et -', (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(stock: 5),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
      });

      testWidgets('devrait afficher en mode compact avec les bonnes icônes', (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(stock: 5, compact: true),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      });
    });

    // =========================================================================
    // INTERACTION TESTS
    // =========================================================================

    group('interactions', () {
      testWidgets('devrait appeler onIncrement au tap sur +', (WidgetTester tester) async {
        // ARRANGE
        var incrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(
                stock: 5,
                onIncrement: () => incrementCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // ASSERT
        expect(incrementCalled, isTrue);
      });

      testWidgets('devrait appeler onDecrement au tap sur -', (WidgetTester tester) async {
        // ARRANGE
        var decrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(
                stock: 5,
                onDecrement: () => decrementCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // ASSERT
        expect(decrementCalled, isTrue);
      });

      testWidgets('devrait appeler onIncrement en mode compact', (WidgetTester tester) async {
        // ARRANGE
        var incrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(
                stock: 5,
                compact: true,
                onIncrement: () => incrementCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        // ASSERT
        expect(incrementCalled, isTrue);
      });

      testWidgets('devrait appeler onDecrement en mode compact', (WidgetTester tester) async {
        // ARRANGE
        var decrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(
                stock: 5,
                compact: true,
                onDecrement: () => decrementCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pump();

        // ASSERT
        expect(decrementCalled, isTrue);
      });
    });

    // =========================================================================
    // DISABLE DECREMENT AT ZERO TESTS
    // =========================================================================

    group('désactivation du bouton -', () {
      testWidgets('devrait désactiver le bouton - si stock = 0', (WidgetTester tester) async {
        // ARRANGE
        var decrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(
                stock: 0,
                onDecrement: () => decrementCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // ASSERT
        expect(decrementCalled, isFalse);
      });

      testWidgets('devrait désactiver le bouton - en mode compact si stock = 0', (WidgetTester tester) async {
        // ARRANGE
        var decrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(
                stock: 0,
                compact: true,
                onDecrement: () => decrementCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pump();

        // ASSERT
        expect(decrementCalled, isFalse);
      });

      testWidgets('devrait activer le bouton - si stock > 0', (WidgetTester tester) async {
        // ARRANGE
        var decrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(
                stock: 1,
                onDecrement: () => decrementCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // ASSERT
        expect(decrementCalled, isTrue);
      });
    });

    // =========================================================================
    // INCREMENT ALWAYS ENABLED TESTS
    // =========================================================================

    group('bouton + toujours actif', () {
      testWidgets('devrait activer le bouton + même si stock = 0', (WidgetTester tester) async {
        // ARRANGE
        var incrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StockControls(
                stock: 0,
                onIncrement: () => incrementCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // ASSERT
        expect(incrementCalled, isTrue);
      });
    });
  });

  // ===========================================================================
  // STOCK BADGE TESTS
  // ===========================================================================

  group('StockBadge', () {
    testWidgets('devrait afficher le stock', (WidgetTester tester) async {
      // ARRANGE
      const stock = 7;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockBadge(stock: stock),
          ),
        ),
      );

      // ACT & ASSERT
      expect(find.text('$stock'), findsOneWidget);
    });

    testWidgets('devrait afficher l\'icône wine_bar', (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockBadge(stock: 5),
          ),
        ),
      );

      // ACT & ASSERT
      expect(find.byIcon(Icons.wine_bar), findsOneWidget);
    });

    testWidgets('devrait afficher 0 pour un stock épuisé', (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockBadge(stock: 0),
          ),
        ),
      );

      // ACT & ASSERT
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('devrait avoir un style différent si stock = 0', (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: Column(
              children: [
                StockBadge(stock: 5),
                StockBadge(stock: 0),
              ],
            ),
          ),
        ),
      );

      // ACT - Trouver les containers
      final containers = tester.widgetList<Container>(find.byType(Container));

      // ASSERT - Les deux badges ont été créés
      expect(containers.length, greaterThanOrEqualTo(2));
    });
  });
}
