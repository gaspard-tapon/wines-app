/// Fichier contenant tous les mocks pour les tests
/// Utilise mocktail pour créer des mocks facilement
library;

import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import 'package:wines_app/domain/repositories/cellar_repository.dart';
import 'package:wines_app/domain/repositories/wine_repository.dart';
import 'package:wines_app/data/datasources/local_cellar_datasource.dart';
import 'package:wines_app/data/datasources/remote_wine_datasource.dart';
import 'package:wines_app/domain/entities/wine.dart';
import 'package:wines_app/data/models/wine_model.dart';
import 'package:wines_app/data/models/cellar_wine_model.dart';

// =============================================================================
// REPOSITORY MOCKS
// =============================================================================

/// Mock du repository de la cave
class MockCellarRepository extends Mock implements CellarRepository {}

/// Mock du repository des vins
class MockWineRepository extends Mock implements WineRepository {}

// =============================================================================
// DATASOURCE MOCKS
// =============================================================================

/// Mock de la datasource locale de la cave
class MockLocalCellarDataSource extends Mock implements LocalCellarDataSource {}

/// Mock de la datasource distante des vins
class MockRemoteWineDataSource extends Mock implements RemoteWineDataSource {}

// =============================================================================
// HTTP CLIENT MOCK
// =============================================================================

/// Mock du client HTTP
class MockHttpClient extends Mock implements http.Client {}

// =============================================================================
// FALLBACK VALUES REGISTRATION
// =============================================================================

/// Enregistre toutes les valeurs par défaut nécessaires pour mocktail
void registerFallbackValues() {
  registerFallbackValue(
    const Wine(
      id: 0,
      nom: '',
      appellation: '',
      region: '',
      cepage: '',
      couleur: '',
      description: '',
      producteur: '',
      degreAlcool: 0,
      image: '',
    ),
  );
  
  registerFallbackValue(
    WineModel(
      id: 0,
      nom: '',
      appellation: '',
      region: '',
      cepage: '',
      couleur: '',
      description: '',
      producteur: '',
      degreAlcool: 0,
      image: '',
    ),
  );
  
  registerFallbackValue(
    CellarWineModel(
      wine: WineModel(
        id: 0,
        nom: '',
        appellation: '',
        region: '',
        cepage: '',
        couleur: '',
        description: '',
        producteur: '',
        degreAlcool: 0,
        image: '',
      ),
      stock: 0,
      rating: 0,
      addedAt: DateTime(2024),
    ),
  );
  
  registerFallbackValue(Uri.parse('https://example.com'));
}
