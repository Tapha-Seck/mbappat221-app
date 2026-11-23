// Fichier : lib/services/gala_api.dart
// Les appels à l'API des galas. Équivalent Java : un @Service qui utilise un RestClient.
//
// Le ClientApi est « injecté » par le constructeur, comme en Spring :
// dans les tests, on peut en passer un qui ne touche pas au réseau.

import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/modeles/resultats_gala.dart';
import 'package:mbappat221_app/services/client_api.dart';

class GalaApi {
  const GalaApi(this._client);

  final ClientApi _client;

  /// GET /api/galas/a-venir?page=0&taille=20 : les galas annoncés, du plus proche au plus lointain.
  Future<PageResultats<Gala>> galasAVenir({int page = 0, int taille = 20}) async {
    final json = await _client.lireJson(
      '/api/galas/a-venir',
      parametres: {'page': '$page', 'taille': '$taille'},
    );
    // « Gala.fromJson » sans parenthèses : on passe le constructeur lui-même (≈ Gala::new en Java).
    return PageResultats.fromJson(json, Gala.fromJson);
  }

  /// GET /api/galas/resultats : les galas TERMINÉS, du plus récent au plus ancien (onglet « Résultats »).
  Future<PageResultats<Gala>> galasTermines({int page = 0, int taille = 20}) async {
    final json = await _client.lireJson(
      '/api/galas/resultats',
      parametres: {'page': '$page', 'taille': '$taille'},
    );
    return PageResultats.fromJson(json, Gala.fromJson);
  }

  /// GET /api/galas/{id} : les points du gala et le résultat de chaque finale déjà saisie.
  Future<ResultatsGala> resultats(int galaId) async {
    final json = await _client.lireJson('/api/galas/$galaId');
    return ResultatsGala.fromJson(json);
  }

  /// Adresse complète d'une affiche ou d'une photo (null s'il n'y en a pas).
  String? urlFichier(String? chemin) => _client.urlFichier(chemin);
}