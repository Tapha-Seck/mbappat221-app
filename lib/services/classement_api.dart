// Fichier : lib/services/classement_api.dart
// Les appels à l'API des classements.

import 'package:mbappat221_app/modeles/classement.dart';
import 'package:mbappat221_app/services/client_api.dart';

class ClassementApi {
  const ClassementApi(this._client);

  final ClientApi _client;

  /// GET /api/classements?categorieId=4 : le classement de la saison active dans une catégorie.
  Future<Classement> classement(int categorieId) async {
    final json = await _client.lireJson('/api/classements', parametres: {'categorieId': '$categorieId'});
    return Classement.fromJson(json);
  }

  /// GET /api/classements/podium : les premiers de chaque catégorie, saison active.
  Future<Podium> podium() async {
    final json = await _client.lireJson('/api/classements/podium');
    return Podium.fromJson(json);
  }
}