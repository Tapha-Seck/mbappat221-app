// Fichier : lib/modeles/resultats_gala.dart
// Les résultats d'un gala : miroir de GalaPublicDto (backend), réponse de GET /api/galas/{id}.
// On n'en garde que ce qui manque à la carte du calendrier : les points et le résultat de chaque finale.

import 'package:mbappat221_app/modeles/gala.dart';

class ResultatsGala {
  const ResultatsGala({this.pointsVainqueur, this.pointsPerdant, required this.categories});

  /// Points figés à l'annonce du gala, les mêmes pour tous les vainqueurs (et pour tous les perdants).
  final int? pointsVainqueur;
  final int? pointsPerdant;

  /// De la moins capée à la plus capée.
  final List<CategorieGala> categories;

  factory ResultatsGala.fromJson(Map<String, dynamic> json) {
    return ResultatsGala(
      pointsVainqueur: json['pointsVainqueur'] as int?,
      pointsPerdant: json['pointsPerdant'] as int?,
      categories: (json['categories'] as List<dynamic>)
          .map((c) => CategorieGala.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Au moins une finale saisie : la fiche affiche alors la rubrique « Résultats ».
  /// any ≈ stream().anyMatch(...) en Java.
  bool get aDesResultats => categories.any((c) => c.finale != null);
}

/// Une catégorie du gala et, si elle a été saisie, sa finale.
class CategorieGala {
  const CategorieGala({required this.drapeau, this.finale});

  /// Nom, date, heure et montant : les mêmes champs JSON que dans le calendrier,
  /// donc on réutilise DrapeauCalendrier.fromJson.
  final DrapeauCalendrier drapeau;
  final ResultatFinale? finale;

  factory CategorieGala.fromJson(Map<String, dynamic> json) {
    final finale = json['finale'] as Map<String, dynamic>?;
    return CategorieGala(
      drapeau: DrapeauCalendrier.fromJson(json),
      finale: finale == null ? null : ResultatFinale.fromJson(finale),
    );
  }
}

/// Le résultat d'une finale : les deux finalistes et ce que chacun a reçu, prêt à afficher.
class ResultatFinale {
  const ResultatFinale({
    required this.vainqueur,
    required this.gainVainqueur,
    required this.perdant,
    required this.gainPerdant,
  });

  final Finaliste vainqueur;
  final String gainVainqueur;   // "700 000 FCFA + 1 cheval", "—"
  final Finaliste perdant;
  final String gainPerdant;

  factory ResultatFinale.fromJson(Map<String, dynamic> json) {
    return ResultatFinale(
      vainqueur: Finaliste.fromJson(json['vainqueur'] as Map<String, dynamic>),
      gainVainqueur: json['gainVainqueur'] as String,
      perdant: Finaliste.fromJson(json['perdant'] as Map<String, dynamic>),
      gainPerdant: json['gainPerdant'] as String,
    );
  }
}

/// Un lutteur en version courte (LutteurResumeDto) : de quoi afficher son nom et ouvrir sa fiche.
class Finaliste {
  const Finaliste({required this.id, required this.nom, this.surnom});

  final int id;
  final String nom;
  final String? surnom;

  factory Finaliste.fromJson(Map<String, dynamic> json) {
    return Finaliste(
      id: json['id'] as int,
      nom: json['nom'] as String,
      surnom: json['surnom'] as String?,
    );
  }

  String get nomAffiche => surnom ?? nom;
}
