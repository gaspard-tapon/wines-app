class ApiConstants {
  static const String baseUrl = 'https://api-wine.gaspardtapon.fr';
  static const String winesEndpoint = '/vins';
  
  static String get winesUrl => '$baseUrl$winesEndpoint';
}
