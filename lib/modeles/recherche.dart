// Fichier : lib/modeles/recherche.dart
// Le résultat de la recherche générale : miroir de RechercheDto (backend).
// Trois rubriques, chacune au format « page » (les premiers résultats + le nombre total).

import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/lutteur.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';

class ResultatRecherche {
  const ResultatRecherche({
    required this.texte,
    required this.lutteurs,
    required this.galas,
    required this.animateurs,
  });

  final String texte;
  final PageResultats<LutteurListe> lutteurs;
  final PageResultats<Gala> galas;
  final PageResultats<AnimateurDetail> animateurs;

  factory ResultatRecherche.fromJson(Map<String, dynamic> json) {
    // On réutilise les fromJson existants : PageResultats est générique (comme PageDto<T> en Java),
    // il suffit de lui passer la fonction qui convertit UN élément (≈ une référence de méthode Gala::new).
    return ResultatRecherche(
      texte: json['texte'] as String,
      lutteurs: PageResultats.fromJson(json['lutteurs'] as Map<String, dynamic>, LutteurListe.fromJson),
      galas: PageResultats.fromJson(json['galas'] as Map<String, dynamic>, Gala.fromJson),
      animateurs: PageResultats.fromJson(json['animateurs'] as Map<String, dynamic>, AnimateurDetail.fromJson),
    );
  }

  /// Aucun résultat dans aucune rubrique.
  bool get estVide => lutteurs.contenu.isEmpty && galas.contenu.isEmpty && animateurs.contenu.isEmpty;
}
