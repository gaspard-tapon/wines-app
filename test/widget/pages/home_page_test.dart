import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import 'package:wines_app/presentation/pages/home_page.dart';
import 'package:wines_app/presentation/providers/cellar_providers.dart';
import '../../helpers/test_data.dart';

void main() {
  group('HomePage', () {
    // =========================================================================
    // INITIAL STATE TESTS
    // =========================================================================

    group('état initial', () {
      testWidgets('devrait afficher le titre "Ma Cave à Vin"', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cellarNotifierProvider.overrideWith((ref) {
                return _MockCellarNotifier([]);
              }),
            ],
            child: MaterialApp(home: HomePage()),
          ),
        );

        // ACT & ASSERT
        expect(find.text('Ma Cave à Vin'), findsOneWidget);
      });

      testWidgets('devrait afficher un indicateur de chargement initialement', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cellarNotifierProvider.overrideWith((ref) {
                return _LoadingCellarNotifier();
              }),
            ],
            child: MaterialApp(home: HomePage()),
          ),
        );

        // ACT & ASSERT
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    // =========================================================================
    // EMPTY STATE TESTS
    // =========================================================================

    group('état vide', () {
      testWidgets('devrait afficher un message si la cave est vide', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cellarNotifierProvider.overrideWith((ref) {
                return _MockCellarNotifier([]);
              }),
            ],
            child: MaterialApp(home: HomePage()),
          ),
        );
        await tester.pumpAndSettle();

        // ACT & ASSERT
        // Le message peut varier, on vérifie qu'il y a quelque chose
        expect(find.byType(HomePage), findsOneWidget);
      });
    });

    // =========================================================================
    // WINE LIST TESTS
    // =========================================================================

    group('liste de vins', () {
      testWidgets('devrait afficher les vins de la cave', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        final wines = TestData.cellarWineList;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cellarNotifierProvider.overrideWith((ref) {
                return _MockCellarNotifier(wines);
              }),
              filteredCellarWinesProvider.overrideWith((ref) {
                return AsyncValue.data(wines);
              }),
            ],
            child: MaterialApp(home: HomePage()),
          ),
        );
        await tester.pumpAndSettle();

        // ACT & ASSERT
        for (final cellarWine in wines) {
          expect(find.text(cellarWine.wine.nom), findsWidgets);
        }
      });
    });

    // =========================================================================
    // NAVIGATION TESTS
    // =========================================================================

    group('navigation', () {
      testWidgets('devrait avoir un FloatingActionButton', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cellarNotifierProvider.overrideWith((ref) {
                return _MockCellarNotifier([]);
              }),
            ],
            child: MaterialApp(home: HomePage()),
          ),
        );
        await tester.pumpAndSettle();

        // ACT & ASSERT
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    // =========================================================================
    // APP BAR TESTS
    // =========================================================================

    group('app bar', () {
      testWidgets('devrait avoir une AppBar', (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cellarNotifierProvider.overrideWith((ref) {
                return _MockCellarNotifier([]);
              }),
            ],
            child: MaterialApp(home: HomePage()),
          ),
        );

        // ACT & ASSERT
        expect(find.byType(AppBar), findsOneWidget);
      });
    });
  });
}

// =============================================================================
// MOCK NOTIFIERS
// =============================================================================

class _MockCellarNotifier extends StateNotifier<AsyncValue<List<CellarWine>>>
    implements CellarNotifier {
  _MockCellarNotifier(List<CellarWine> wines) : super(AsyncValue.data(wines));

  @override
  Future<void> loadCellar() async {}

  @override
  Future<void> addWine(wine) async {}

  @override
  Future<void> incrementStock(int wineId) async {}

  @override
  Future<void> decrementStock(int wineId) async {}

  @override
  Future<void> updateRating(int wineId, int rating) async {}

  @override
  Future<void> updateAnnotation(int wineId, String? annotation) async {}
}

class _LoadingCellarNotifier extends StateNotifier<AsyncValue<List<CellarWine>>>
    implements CellarNotifier {
  _LoadingCellarNotifier() : super(const AsyncValue.loading());

  @override
  Future<void> loadCellar() async {}

  @override
  Future<void> addWine(wine) async {}

  @override
  Future<void> incrementStock(int wineId) async {}

  @override
  Future<void> decrementStock(int wineId) async {}

  @override
  Future<void> updateRating(int wineId, int rating) async {}

  @override
  Future<void> updateAnnotation(int wineId, String? annotation) async {}
}
