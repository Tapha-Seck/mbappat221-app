// Fichier : lib/services/animateur_api.dart
// Les appels à l'API des animateurs (cantatrices et griots).

import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/services/client_api.dart';

class AnimateurApi {
  const AnimateurApi(this._client);

  final ClientApi _client;

  /// GET /api/animateurs?role=GRIOT : tous les animateurs, ou ceux d'un rôle (null = tous).
  /// La liste est courte (quelques dizaines) : pas de pagination.
  Future<List<AnimateurDetail>> lister({RoleAnimateur? role}) async {
    final json = await _client.lireJsonListe(
      '/api/animateurs',
      // « .name.toUpperCase() » : RoleAnimateur.griot → « GRIOT », la valeur attendue par Spring.
      parametres: role == null ? null : {'role': role.name.toUpperCase()},
    );
    return json.map((a) => AnimateurDetail.fromJson(a as Map<String, dynamic>)).toList();
  }

  /// GET /api/animateurs/3 : le profil et les galas animés.
  Future<ProfilAnimateur> profil(int animateurId) async {
    final json = await _client.lireJson('/api/animateurs/$animateurId');
    return ProfilAnimateur.fromJson(json);
  }

  String? urlFichier(String? chemin) => _client.urlFichier(chemin);
}