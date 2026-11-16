// Fichier : lib/services/referentiel_api.dart
// Les données de référence, qui changent rarement : catégories (plus tard : régions...).

import 'package:mbappat221_app/modeles/categorie.dart';
import 'package:mbappat221_app/services/client_api.dart';

class ReferentielApi {
  ReferentielApi(this._client);

  final ClientApi _client;

  /// Gardées en mémoire après le premier appel : les catégories ne changent pas
  /// pendant que l'application est ouverte (une seule requête, même si plusieurs écrans les demandent).
  List<Categorie>? _categories;

  /// GET /api/categories : dans l'ordre officiel.
  Future<List<Categorie>> categories() async {
    final dejaChargees = _categories;
    if (dejaChargees != null) {
      return dejaChargees;
    }
    final json = await _client.lireJsonListe('/api/categories');
    final categories = json.map((c) => Categorie.fromJson(c as Map<String, dynamic>)).toList();
    _categories = categories;
    return categories;
  }
}