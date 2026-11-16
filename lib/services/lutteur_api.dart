// Fichier : lib/services/lutteur_api.dart
// Les appels à l'API des lutteurs (GET /api/lutteurs...). Même principe que GalaApi.

import 'package:mbappat221_app/modeles/fiche_lutteur.dart';
import 'package:mbappat221_app/modeles/lutteur.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/services/client_api.dart';

class LutteurApi {
  const LutteurApi(this._client);

  final ClientApi _client;

  /// GET /api/lutteurs?recherche=fass&categorieId=4&page=0&taille=20
  /// [recherche] : nom, surnom ou écurie (au moins 2 lettres, sinon ignorée).
  /// [categorieId] : null = toutes les catégories.
  Future<PageResultats<LutteurListe>> rechercher({
    String recherche = '',
    int? categorieId,
    int page = 0,
    int taille = 20,
  }) async {
    final texte = recherche.trim();
    final json = await _client.lireJson('/api/lutteurs', parametres: {
      // « collection if » aussi dans une Map : la clé n'est ajoutée que si la condition est vraie.
      if (texte.length >= 2) 'recherche': texte,
      if (categorieId != null) 'categorieId': '$categorieId',
      'page': '$page',
      'taille': '$taille',
    });
    return PageResultats.fromJson(json, LutteurListe.fromJson);
  }

  /// GET /api/lutteurs/5/fiche : profil, photos, bilan de la saison active, historique des finales.
  Future<FicheLutteur> fiche(int lutteurId) async {
    final json = await _client.lireJson('/api/lutteurs/$lutteurId/fiche');
    return FicheLutteur.fromJson(json);
  }

  /// Adresse complète d'une photo (null s'il n'y en a pas).
  String? urlFichier(String? chemin) => _client.urlFichier(chemin);
}