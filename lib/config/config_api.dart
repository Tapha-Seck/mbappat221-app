// Fichier : lib/config/config_api.dart
// Adresse du backend Spring Boot.
//
// String.fromEnvironment lit une valeur passée AU MOMENT DU LANCEMENT :
//   flutter run --dart-define=API_URL=http://10.0.2.2:8080
// C'est l'équivalent d'une propriété ${API_URL:http://localhost:8080} dans application.yaml :
// une valeur par défaut, remplaçable sans toucher au code.
//
// Valeurs utiles :
//   - Chrome sur le PC          → http://localhost:8080 (par défaut)
//   - émulateur Android         → http://10.0.2.2:8080 (10.0.2.2 = « le PC » vu depuis l'émulateur)
//   - vrai téléphone en Wi-Fi   → http://192.168.x.x:8080 (l'adresse IP du PC)
//   - production                → https://api.mbappat221.sn (plus tard)

abstract final class ConfigApi {
  static const String urlBase =
  String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
}