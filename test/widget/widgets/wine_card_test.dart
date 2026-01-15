import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/presentation/widgets/wine_card.dart';
import '../../helpers/test_data.dart';

void main() {
  group('WineCard', () {
    // =========================================================================
    // DISPLAY TESTS
    // =========================================================================

    group('affichage', () {
      testWidgets('devrait afficher le nom du vin', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: WineCard(wine: wine)),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text(wine.nom), findsOneWidget);
      });

      testWidgets('devrait afficher l\'appellation', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: WineCard(wine: wine)),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text(wine.appellation), findsOneWidget);
      });

      testWidgets('devrait afficher la région', (WidgetTester tester) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: WineCard(wine: wine)),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text(wine.region), findsOneWidget);
      });

      testWidgets('devrait afficher le millésime si présent', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: WineCard(wine: wine)),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text('${wine.millesime}'), findsOneWidget);
      });

      testWidgets('ne devrait pas afficher de millésime si null', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineSansMillesime;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: WineCard(wine: wine)),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text('null'), findsNothing);
      });

      testWidgets('devrait afficher la couleur du vin en badge', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: WineCard(wine: wine)),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text(wine.couleur.toUpperCase()), findsOneWidget);
      });

      testWidgets('devrait afficher l\'icône de localisation', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: WineCard(wine: wine)),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.byIcon(Icons.location_on), findsOneWidget);
      });
    });

    // =========================================================================
    // BADGE "IN CELLAR" TESTS
    // =========================================================================

    group('badge "dans la cave"', () {
      testWidgets('devrait afficher le badge check si isInCellar est true', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WineCard(wine: wine, isInCellar: true),
              ),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets(
        'ne devrait pas afficher le badge check si isInCellar est false',
        (WidgetTester tester) async {
          // ARRANGE
          final wine = TestData.wineRouge;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: WineCard(wine: wine, isInCellar: false),
                ),
              ),
            ),
          );

          // ACT & ASSERT
          expect(find.byIcon(Icons.check), findsNothing);
        },
      );
    });

    // =========================================================================
    // BUTTON "ADD TO CELLAR" TESTS
    // =========================================================================

    group('bouton "Ajouter"', () {
      testWidgets('devrait afficher le bouton si onAddToCellar est fourni', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WineCard(wine: wine, onAddToCellar: () {}),
              ),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text('Ajouter'), findsOneWidget);
      });

      testWidgets('devrait afficher "Ajouter +1" si déjà dans la cave', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WineCard(
                  wine: wine,
                  onAddToCellar: () {},
                  isInCellar: true,
                ),
              ),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.text('Ajouter +1'), findsOneWidget);
      });

      testWidgets('devrait appeler onAddToCellar au tap', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        var addCalled = false;
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WineCard(
                  wine: wine,
                  onAddToCellar: () => addCalled = true,
                ),
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.text('Ajouter'));
        await tester.pump();

        // ASSERT
        expect(addCalled, isTrue);
      });

      testWidgets(
        'ne devrait pas afficher le bouton si onAddToCellar est null',
        (WidgetTester tester) async {
          // ARRANGE
          final wine = TestData.wineRouge;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(child: WineCard(wine: wine)),
              ),
            ),
          );

          // ACT & ASSERT
          expect(find.text('Ajouter'), findsNothing);
          expect(find.text('Ajouter +1'), findsNothing);
        },
      );
    });

    // =========================================================================
    // TAP INTERACTION TESTS
    // =========================================================================

    group('interaction tap sur la carte', () {
      testWidgets('devrait appeler onTap au tap sur la carte', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        var tapCalled = false;
        final wine = TestData.wineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WineCard(wine: wine, onTap: () => tapCalled = true),
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byType(InkWell).first);
        await tester.pump();

        // ASSERT
        expect(tapCalled, isTrue);
      });
    });
  });

  // ===========================================================================
  // CELLAR WINE CARD TESTS
  // ===========================================================================

  group('CellarWineCard', () {
    // =========================================================================
    // DISPLAY TESTS
    // =========================================================================

    group('affichage', () {
      testWidgets('devrait afficher le nom du vin', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final cellarWine = TestData.cellarWineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CellarWineCard(cellarWine: cellarWine)),
          ),
        );

        // ACT & ASSERT
        expect(find.text(cellarWine.wine.nom), findsOneWidget);
      });

      testWidgets('devrait afficher l\'appellation', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final cellarWine = TestData.cellarWineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CellarWineCard(cellarWine: cellarWine)),
          ),
        );

        // ACT & ASSERT
        expect(find.text(cellarWine.wine.appellation), findsOneWidget);
      });

      testWidgets('devrait afficher le millésime si présent', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final cellarWine = TestData.cellarWineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CellarWineCard(cellarWine: cellarWine)),
          ),
        );

        // ACT & ASSERT
        expect(find.text('${cellarWine.wine.millesime}'), findsOneWidget);
      });

      testWidgets('devrait afficher le rating avec RatingDisplay', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final cellarWine = TestData.cellarWineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CellarWineCard(cellarWine: cellarWine)),
          ),
        );

        // ACT & ASSERT
        // Le rating 5 = 5 étoiles pleines
        expect(find.byIcon(Icons.star), findsNWidgets(cellarWine.rating));
      });

      testWidgets('devrait afficher la couleur du vin', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final cellarWine = TestData.cellarWineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CellarWineCard(cellarWine: cellarWine)),
          ),
        );

        // ACT & ASSERT
        expect(
          find.text(cellarWine.wine.couleur.toUpperCase()),
          findsOneWidget,
        );
      });
    });

    // =========================================================================
    // INTERACTION TESTS
    // =========================================================================

    group('interactions', () {
      testWidgets('devrait appeler onTap au tap sur la carte', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        var tapCalled = false;
        final cellarWine = TestData.cellarWineRouge;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CellarWineCard(
                cellarWine: cellarWine,
                onTap: () => tapCalled = true,
              ),
            ),
          ),
        );

        // ACT
        await tester.tap(find.byType(InkWell));
        await tester.pump();

        // ASSERT
        expect(tapCalled, isTrue);
      });
    });
  });
}
