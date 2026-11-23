// Fichier : lib/services/recherche_api.dart
// La recherche générale (loupe de l'accueil) : GET /api/recherche?q=...
// UN seul appel réseau pour les lutteurs, les galas et les animateurs (plus rapide en 3G/4G).

import 'package:mbappat221_app/modeles/recherche.dart';
import 'package:mbappat221_app/services/client_api.dart';

class RechercheApi {
  const RechercheApi(this._client);

  final ClientApi _client;

  /// [texte] : au moins 2 caractères (l'écran ne fait pas l'appel avant).
  Future<ResultatRecherche> rechercher(String texte) async {
    final json = await _client.lireJson('/api/recherche', parametres: {'q': texte.trim()});
    return ResultatRecherche.fromJson(json);
  }

  /// Adresse complète d'une photo ou d'une affiche (null s'il n'y en a pas).
  String? urlFichier(String? chemin) => _client.urlFichier(chemin);
}
