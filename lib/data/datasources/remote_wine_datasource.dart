import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/wine_model.dart';

class RemoteWineDataSource {
  final http.Client client;

  RemoteWineDataSource({http.Client? client}) : client = client ?? http.Client();

  /// Récupère tous les vins depuis l'API
  Future<List<WineModel>> getWines() async {
    final response = await client.get(
      Uri.parse(ApiConstants.winesUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => WineModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des vins: ${response.statusCode}');
    }
  }

  /// Récupère un vin par son ID
  Future<WineModel?> getWineById(int id) async {
    final wines = await getWines();
    try {
      return wines.firstWhere((wine) => wine.id == id);
    } catch (_) {
      return null;
    }
  }
}
