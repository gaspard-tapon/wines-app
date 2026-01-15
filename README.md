# 🍷 Ma Cave à Vin - Application Flutter

Application Flutter de démonstration pour la gestion d'une cave à vin, conçue pour illustrer l'implémentation des différents types de tests et la configuration CI/CD avec GitLab CI et GitHub Actions.

## 📋 Table des matières

- [À propos](#à-propos)
- [Architecture](#architecture)
- [Fonctionnalités](#fonctionnalités)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Types de tests](#types-de-tests)
  - [Tests unitaires](#1-tests-unitaires)
  - [Tests de widgets](#2-tests-de-widgets)
  - [Tests d'intégration](#3-tests-dintégration)
- [CI/CD](#cicd)
  - [GitLab CI](#gitlab-ci)
  - [GitHub Actions](#github-actions)
- [Structure du projet](#structure-du-projet)
- [Technologies utilisées](#technologies-utilisées)

## 🎯 À propos

Cette application est un projet éducatif qui démontre comment implémenter une architecture propre (Clean Architecture) dans Flutter, avec une couverture de tests complète incluant :

- **Tests unitaires** : pour tester la logique métier (use cases, repositories, data sources)
- **Tests de widgets** : pour tester l'interface utilisateur et les interactions
- **Tests d'intégration** : pour tester les flux complets de l'application

L'application gère une collection de vins avec les fonctionnalités suivantes :
- Consultation d'un catalogue de vins
- Ajout de vins à la cave personnelle
- Gestion du stock (incrémenter/décrémenter)
- Notation des vins (0-5 étoiles)
- Annotation personnelle
- Filtrage et tri de la collection

## 🏗️ Architecture

L'application suit une architecture **Clean Architecture** avec trois couches principales :

```
lib/
├── domain/          # Couche métier (entities, repositories, use cases)
├── data/            # Couche données (datasources, models, repositories impl)
└── presentation/    # Couche présentation (pages, widgets, providers)
```

### Couche Domain
- **Entities** : Modèles métier purs (Wine, CellarWine, FilterSortOptions)
- **Repositories** : Interfaces définissant les contrats de données
- **Use Cases** : Logique métier isolée et testable

### Couche Data
- **DataSources** : Accès aux données (local avec Hive, remote avec HTTP)
- **Models** : Modèles de données avec sérialisation
- **Repositories Impl** : Implémentations concrètes des repositories

### Couche Presentation
- **Pages** : Écrans de l'application
- **Widgets** : Composants réutilisables
- **Providers** : Gestion d'état avec Riverpod

## ✨ Fonctionnalités

- 📚 **Catalogue de vins** : Consultation d'une liste de vins disponibles
- 🏠 **Ma Cave** : Visualisation de votre collection personnelle
- ➕ **Ajout de vins** : Ajout de vins depuis le catalogue à votre cave
- 📊 **Gestion du stock** : Incrémenter/décrémenter le nombre de bouteilles
- ⭐ **Notation** : Noter les vins de 0 à 5 étoiles
- 📝 **Annotations** : Ajouter des notes personnelles sur chaque vin
- 🔍 **Filtrage et tri** : Filtrer par couleur, région, millésime et trier par différents critères
- 💾 **Stockage local** : Persistance des données avec Hive

## 📦 Prérequis

- Flutter SDK >= 3.11.0
- Dart SDK >= 3.11.0
- Android Studio / VS Code avec extensions Flutter
- Git

## 🚀 Installation

1. **Cloner le repository**
```bash
git clone <repository-url>
cd wines_app
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer les fichiers de code (Hive)**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Lancer l'application**
```bash
flutter run
```

## 🧪 Types de tests

### 1. Tests unitaires

Les tests unitaires vérifient la logique métier isolée, sans dépendances externes.

#### Exemple : Test d'un Use Case

```dart
// test/domain/usecases/increment_stock_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wines_app/domain/usecases/increment_stock.dart';
import 'package:wines_app/domain/repositories/cellar_repository.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import 'package:wines_app/domain/entities/wine.dart';

class MockCellarRepository extends Mock implements CellarRepository {}

void main() {
  late IncrementStock useCase;
  late MockCellarRepository mockRepository;

  setUp(() {
    mockRepository = MockCellarRepository();
    useCase = IncrementStock(mockRepository);
  });

  test('devrait incrémenter le stock d\'un vin', () async {
    // Arrange
    const wineId = 1;
    final expectedCellarWine = CellarWine(
      wine: Wine(
        id: wineId,
        nom: 'Test Wine',
        appellation: 'Test',
        region: 'Test',
        cepage: 'Test',
        couleur: 'Rouge',
        description: 'Test',
        producteur: 'Test',
        degreAlcool: 12.5,
        image: 'test.jpg',
      ),
      stock: 2,
    );

    when(mockRepository.incrementStock(wineId))
        .thenAnswer((_) async => expectedCellarWine);

    // Act
    final result = await useCase(wineId);

    // Assert
    expect(result, equals(expectedCellarWine));
    verify(mockRepository.incrementStock(wineId)).called(1);
  });
}
```

#### Exemple : Test d'un Repository

```dart
// test/data/repositories/cellar_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wines_app/data/repositories/cellar_repository_impl.dart';
import 'package:wines_app/data/datasources/local_cellar_datasource.dart';
import 'package:wines_app/data/models/cellar_wine_model.dart';
import 'package:wines_app/data/models/wine_model.dart';

class MockLocalCellarDataSource extends Mock implements LocalCellarDataSource {}

void main() {
  late CellarRepositoryImpl repository;
  late MockLocalCellarDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocalCellarDataSource();
    repository = CellarRepositoryImpl(localDataSource: mockDataSource);
  });

  test('devrait retourner la liste des vins de la cave', () async {
    // Arrange
    final models = [
      CellarWineModel(
        wine: WineModel(
          id: 1,
          nom: 'Wine 1',
          appellation: 'Appellation 1',
          region: 'Region 1',
          cepage: 'Cepage 1',
          couleur: 'Rouge',
          description: 'Description 1',
          producteur: 'Producteur 1',
          degreAlcool: 12.5,
          image: 'image1.jpg',
        ),
        stock: 5,
      ),
    ];

    when(mockDataSource.getCellarWines()).thenAnswer((_) async => models);

    // Act
    final result = await repository.getCellarWines();

    // Assert
    expect(result.length, equals(1));
    expect(result.first.wine.id, equals(1));
    verify(mockDataSource.getCellarWines()).called(1);
  });
}
```

#### Exécuter les tests unitaires

```bash
flutter test test/domain/
flutter test test/data/
```

### 2. Tests de widgets

Les tests de widgets vérifient l'interface utilisateur et les interactions.

#### Exemple : Test d'un Widget

```dart
// test/presentation/widgets/wine_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/presentation/widgets/wine_card.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import 'package:wines_app/domain/entities/wine.dart';

void main() {
  testWidgets('devrait afficher les informations du vin', (WidgetTester tester) async {
    // Arrange
    final cellarWine = CellarWine(
      wine: Wine(
        id: 1,
        nom: 'Château Margaux',
        appellation: 'Margaux',
        region: 'Bordeaux',
        cepage: 'Cabernet Sauvignon',
        millesime: 2015,
        couleur: 'Rouge',
        description: 'Un grand cru classé',
        producteur: 'Château Margaux',
        degreAlcool: 13.5,
        image: 'margaux.jpg',
      ),
      stock: 3,
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CellarWineCard(
            cellarWine: cellarWine,
            onTap: () {},
            onIncrement: () {},
            onDecrement: () {},
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Château Margaux'), findsOneWidget);
    expect(find.text('Margaux'), findsOneWidget);
    expect(find.text('2015'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('devrait appeler onTap quand on clique sur la carte', (WidgetTester tester) async {
    // Arrange
    bool tapped = false;
    final cellarWine = CellarWine(
      wine: Wine(
        id: 1,
        nom: 'Test Wine',
        appellation: 'Test',
        region: 'Test',
        cepage: 'Test',
        couleur: 'Rouge',
        description: 'Test',
        producteur: 'Test',
        degreAlcool: 12.5,
        image: 'test.jpg',
      ),
      stock: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CellarWineCard(
            cellarWine: cellarWine,
            onTap: () => tapped = true,
            onIncrement: () {},
            onDecrement: () {},
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(Card));
    await tester.pumpAndSettle();

    // Assert
    expect(tapped, isTrue);
  });
}
```

#### Exemple : Test d'une Page avec Riverpod

```dart
// test/presentation/pages/home_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wines_app/presentation/pages/home_page.dart';
import 'package:wines_app/presentation/providers/cellar_providers.dart';

void main() {
  testWidgets('devrait afficher la liste des vins', (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Attendre le chargement
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomePage), findsOneWidget);
    // Vérifier la présence d'éléments spécifiques selon l'état
  });
}
```

#### Exécuter les tests de widgets

```bash
flutter test test/presentation/
```

### 3. Tests d'intégration

Les tests d'intégration vérifient les flux complets de l'application.

#### Configuration

Créer le fichier `integration_test/app_test.dart` :

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wines_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flux complet de l\'application', () {
    testWidgets('devrait ajouter un vin à la cave', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Naviguer vers la page des vins disponibles
      await tester.tap(find.text('Ajouter un vin'));
      await tester.pumpAndSettle();

      // Sélectionner un vin
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Ajouter à la cave
      await tester.tap(find.text('Ajouter à ma cave'));
      await tester.pumpAndSettle();

      // Retourner à la page d'accueil
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert - Vérifier que le vin apparaît dans la cave
      expect(find.text('Ma Cave'), findsOneWidget);
      // Vérifier la présence du vin ajouté
    });

    testWidgets('devrait incrémenter le stock d\'un vin', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Trouver un vin et incrémenter son stock
      final incrementButton = find.byIcon(Icons.add);
      if (incrementButton.evaluate().isNotEmpty) {
        await tester.tap(incrementButton.first);
        await tester.pumpAndSettle();

        // Assert - Vérifier que le stock a été incrémenté
        // (selon votre implémentation)
      }
    });
  });
}
```

#### Ajouter la dépendance

Dans `pubspec.yaml` :

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

#### Exécuter les tests d'intégration

```bash
flutter test integration_test/
```

Pour exécuter sur un appareil spécifique :

```bash
flutter test integration_test/app_test.dart -d <device-id>
```

## 🔄 CI/CD

### GitLab CI

Créer le fichier `.gitlab-ci.yml` à la racine du projet :

```yaml
# .gitlab-ci.yml
image: cirrusci/flutter:stable

stages:
  - test
  - build

variables:
  FLUTTER_ROOT: "/opt/flutter"
  PATH: "${FLUTTER_ROOT}/bin:${PATH}"

before_script:
  - flutter doctor
  - flutter pub get
  - flutter pub run build_runner build --delete-conflicting-outputs

# Tests unitaires et de widgets
test:unit:
  stage: test
  script:
    - flutter analyze
    - flutter test test/domain/
    - flutter test test/data/
    - flutter test test/presentation/
  coverage: '/lines:\s+(\d+\.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/lcov.info
    paths:
      - coverage/
    expire_in: 1 week

# Tests d'intégration
test:integration:
  stage: test
  script:
    - flutter test integration_test/
  only:
    - main
    - develop

# Build Android
build:android:
  stage: build
  script:
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk
    expire_in: 1 week
  only:
    - tags

# Build iOS (nécessite un runner macOS)
build:ios:
  stage: build
  script:
    - flutter build ios --release --no-codesign
  artifacts:
    paths:
      - build/ios/iphoneos/Runner.app
    expire_in: 1 week
  only:
    - tags
  tags:
    - macos
```

### GitHub Actions

Créer le fichier `.github/workflows/flutter.yml` :

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.11.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate code
        run: flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Verify formatting
        run: dart format --set-exit-if-changed .
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run unit tests
        run: flutter test test/domain/ test/data/
      
      - name: Run widget tests
        run: flutter test test/presentation/
      
      - name: Generate coverage
        run: |
          flutter test --coverage
          lcov --summary coverage/lcov.info
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
          flags: unittests
          name: codecov-umbrella

  integration_test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.11.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate code
        run: flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Run integration tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 29
          script: flutter test integration_test/

  build_android:
    runs-on: ubuntu-latest
    needs: test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.11.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate code
        run: flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## 📁 Structure du projet

```
lib/
├── core/
│   └── constants/          # Constantes de l'application
├── data/
│   ├── datasources/        # Sources de données (local, remote)
│   ├── models/             # Modèles de données avec sérialisation
│   └── repositories/       # Implémentations des repositories
├── domain/
│   ├── entities/           # Entités métier
│   ├── repositories/       # Interfaces des repositories
│   └── usecases/           # Cas d'usage métier
└── presentation/
    ├── pages/              # Écrans de l'application
    ├── providers/          # Providers Riverpod
    └── widgets/            # Widgets réutilisables

test/
├── domain/                 # Tests unitaires de la couche domain
├── data/                   # Tests unitaires de la couche data
└── presentation/           # Tests de widgets

integration_test/            # Tests d'intégration
```

## 🛠️ Technologies utilisées

- **Flutter** : Framework de développement multiplateforme
- **Riverpod** : Gestion d'état réactive et testable
- **Hive** : Base de données NoSQL locale
- **HTTP** : Client HTTP pour les appels API
- **Build Runner** : Génération de code pour Hive
- **Flutter Test** : Framework de test intégré
- **Mockito** : Bibliothèque de mocking pour les tests

## 📚 Ressources

- [Documentation Flutter](https://docs.flutter.dev/)
- [Tests Flutter](https://docs.flutter.dev/testing)
- [Riverpod](https://riverpod.dev/)
- [Hive](https://docs.hivedb.dev/)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [GitHub Actions](https://docs.github.com/en/actions)

## 📝 Licence

Ce projet est un projet éducatif à des fins de démonstration.

---

**Note** : Ce projet est conçu pour illustrer les bonnes pratiques de test et de CI/CD dans Flutter. Adaptez les configurations selon vos besoins spécifiques.
