import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/presentation/widgets/rating_widget.dart';

void main() {
  group('RatingWidget', () {
    // =========================================================================
    // DISPLAY TESTS
    // =========================================================================

    group('affichage', () {
      testWidgets('devrait afficher 5 étoiles', (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RatingWidget(rating: 0),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.byIcon(Icons.star), findsNothing);
        expect(find.byIcon(Icons.star_border), findsNWidgets(5));
      });

      testWidgets('devrait afficher le bon nombre d\'étoiles pleines', (WidgetTester tester) async {
        // ARRANGE
        const rating = 3;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RatingWidget(rating: rating),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.byIcon(Icons.star), findsNWidgets(3));
        expect(find.byIcon(Icons.star_border), findsNWidgets(2));
      });

      testWidgets('devrait afficher 5 étoiles pleines pour rating = 5', (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RatingWidget(rating: 5),
            ),
          ),
        );

        // ACT & ASSERT
        expect(find.byIcon(Icons.star), findsNWidgets(5));
        expect(find.byIcon(Icons.star_border), findsNothing);
      });

      testWidgets('devrait utiliser la taille spécifiée', (WidgetTester tester) async {
        // ARRANGE
        const customSize = 32.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RatingWidget(rating: 3, size: customSize),
            ),
          ),
        );

        // ACT
        final iconWidgets = tester.widgetList<Icon>(find.byType(Icon));

        // ASSERT
        for (final icon in iconWidgets) {
          expect(icon.size, equals(customSize));
        }
      });
    });

    // =========================================================================
    // INTERACTION TESTS
    // =========================================================================

    group('interactions', () {
      testWidgets('devrait appeler onRatingChanged au tap sur une étoile', (WidgetTester tester) async {
        // ARRANGE
        int? selectedRating;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RatingWidget(
                rating: 2,
                onRatingChanged: (rating) => selectedRating = rating,
              ),
            ),
          ),
        );

        // ACT - Taper sur la 4ème étoile
        final stars = find.byType(GestureDetector);
        await tester.tap(stars.at(3));
        await tester.pump();

        // ASSERT
        expect(selectedRating, equals(4));
      });

      testWidgets('devrait permettre de changer la note de 3 à 1', (WidgetTester tester) async {
        // ARRANGE
        int? selectedRating;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RatingWidget(
                rating: 3,
                onRatingChanged: (rating) => selectedRating = rating,
              ),
            ),
          ),
        );

        // ACT - Taper sur la 1ère étoile
        final stars = find.byType(GestureDetector);
        await tester.tap(stars.at(0));
        await tester.pump();

        // ASSERT
        expect(selectedRating, equals(1));
      });

      testWidgets('ne devrait pas réagir au tap si readOnly est true', (WidgetTester tester) async {
        // ARRANGE
        int? selectedRating;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RatingWidget(
                rating: 3,
                readOnly: true,
                onRatingChanged: (rating) => selectedRating = rating,
              ),
            ),
          ),
        );

        // ACT
        final stars = find.byType(GestureDetector);
        await tester.tap(stars.at(4));
        await tester.pump();

        // ASSERT
        expect(selectedRating, isNull);
      });

      testWidgets('ne devrait pas réagir si onRatingChanged est null', (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RatingWidget(rating: 3),
            ),
          ),
        );

        // ACT - Ne devrait pas lever d'exception
        final stars = find.byType(GestureDetector);
        await tester.tap(stars.at(4));
        await tester.pump();

        // ASSERT - Pas d'erreur
        expect(find.byType(RatingWidget), findsOneWidget);
      });
    });

    // =========================================================================
    // STYLING TESTS
    // =========================================================================

    group('style', () {
      testWidgets('devrait afficher les étoiles pleines en ambre', (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RatingWidget(rating: 3),
            ),
          ),
        );

        // ACT
        final filledStars = tester.widgetList<Icon>(find.byIcon(Icons.star));

        // ASSERT
        for (final star in filledStars) {
          expect(star.color, equals(Colors.amber));
        }
      });

      testWidgets('devrait afficher les étoiles vides en gris', (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RatingWidget(rating: 3),
            ),
          ),
        );

        // ACT
        final emptyStars = tester.widgetList<Icon>(find.byIcon(Icons.star_border));

        // ASSERT
        for (final star in emptyStars) {
          expect(star.color, equals(Colors.grey));
        }
      });
    });
  });

  // ===========================================================================
  // RATING DISPLAY TESTS
  // ===========================================================================

  group('RatingDisplay', () {
    testWidgets('devrait afficher un RatingWidget en lecture seule', (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingDisplay(rating: 4),
          ),
        ),
      );

      // ACT & ASSERT
      expect(find.byType(RatingWidget), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('devrait utiliser la taille par défaut de 16', (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingDisplay(rating: 3),
          ),
        ),
      );

      // ACT
      final icons = tester.widgetList<Icon>(find.byType(Icon));

      // ASSERT
      for (final icon in icons) {
        expect(icon.size, equals(16));
      }
    });

    testWidgets('devrait accepter une taille personnalisée', (WidgetTester tester) async {
      // ARRANGE
      const customSize = 24.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingDisplay(rating: 3, size: customSize),
          ),
        ),
      );

      // ACT
      final icons = tester.widgetList<Icon>(find.byType(Icon));

      // ASSERT
      for (final icon in icons) {
        expect(icon.size, equals(customSize));
      }
    });

    testWidgets('ne devrait pas réagir aux taps', (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingDisplay(rating: 3),
          ),
        ),
      );

      // ACT - Taper sur les étoiles ne devrait rien changer
      final initialFilledCount = find.byIcon(Icons.star).evaluate().length;
      final stars = find.byType(GestureDetector);
      await tester.tap(stars.at(4));
      await tester.pump();
      
      final finalFilledCount = find.byIcon(Icons.star).evaluate().length;

      // ASSERT
      expect(finalFilledCount, equals(initialFilledCount));
    });
  });
}
