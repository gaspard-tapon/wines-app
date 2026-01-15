import '../../domain/entities/wine.dart';
import '../../domain/repositories/wine_repository.dart';
import '../datasources/remote_wine_datasource.dart';

class WineRepositoryImpl implements WineRepository {
  final RemoteWineDataSource remoteDataSource;

  WineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Wine>> getAvailableWines() async {
    final wineModels = await remoteDataSource.getWines();
    return wineModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Wine?> getWineById(int id) async {
    final wineModel = await remoteDataSource.getWineById(id);
    return wineModel?.toEntity();
  }
}
