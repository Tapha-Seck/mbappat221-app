// Fichier : lib/modeles/gala.dart
// Un gala du calendrier public : miroir de GalaCalendrierDto et DrapeauCalendrierDto (backend).
//
// Rappel : en Java, Jackson transforme le JSON en record tout seul.
// En Dart, on écrit nous-mêmes la conversion dans un constructeur « fromJson »
// (on pourra l'automatiser plus tard avec un générateur de code, json_serializable).

import 'package:mbappat221_app/modeles/animateur.dart';

enum StatutGala {
  brouillon('Brouillon'),
  annonce('Annoncé'),
  termine('Terminé'),
  annule('Annulé');

  const StatutGala(this.libelle);

  final String libelle;

  static StatutGala depuisJson(String valeur) => StatutGala.values.byName(valeur.toLowerCase());
}

/// Une catégorie disputée lors du gala (un « drapeau »).
class DrapeauCalendrier {
  const DrapeauCalendrier({
    required this.categorieNom,
    required this.categorieOrdre,
    this.date,
    this.heure,
    this.montantAnnonce,
  });

  final String categorieNom;
  final int categorieOrdre;
  final DateTime? date;
  final String? heure;          // "16:00" ou "16:00:00" (LocalTime de Java)
  final int? montantAnnonce;    // en FCFA, seulement s'il est annoncé à l'avance

  factory DrapeauCalendrier.fromJson(Map<String, dynamic> json) {
    final date = json['date'] as String?;
    return DrapeauCalendrier(
      categorieNom: json['categorieNom'] as String,
      categorieOrdre: json['categorieOrdre'] as int,
      // DateTime.parse("2026-11-21") ≈ LocalDate.parse(...), seulement si la date est présente.
      date: date == null ? null : DateTime.parse(date),
      heure: json['heure'] as String?,
      montantAnnonce: json['montantAnnonce'] as int?,
    );
  }

  /// "16:00" (sans les secondes), ou null.
  String? get heureCourte {
    // On copie le champ dans une variable locale : après « h == null », Dart SAIT que h
    // n'est plus null (« promotion de type ») et autorise h.length sans cast.
    final h = heure;
    return h == null || h.length < 5 ? h : h.substring(0, 5);
  }
}

class Gala {
  const Gala({
    required this.id,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.lieu,
    required this.region,
    required this.statut,
    required this.mise,
    this.organisateur,
    this.animateurs = const [],
    this.infosComplementaires,
    this.miseTotale,
    this.afficheUrl,
    this.drapeaux = const [],
  });

  final int id;
  final String nom;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String lieu;
  final String region;
  final StatutGala statut;
  final String mise;                    // libellé prêt à afficher : "1 500 000 FCFA", "10 bœufs"
  final String? organisateur;
  final List<AnimateurResume> animateurs;
  final String? infosComplementaires;
  final int? miseTotale;
  final String? afficheUrl;             // relative : "/fichiers/galas/3/xxx.jpg"
  final List<DrapeauCalendrier> drapeaux;

  factory Gala.fromJson(Map<String, dynamic> json) {
    return Gala(
      id: json['id'] as int,
      nom: json['nom'] as String,
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      dateFin: DateTime.parse(json['dateFin'] as String),
      lieu: json['lieu'] as String,
      region: json['region'] as String,
      statut: StatutGala.depuisJson(json['statut'] as String),
      mise: json['mise'] as String,
      organisateur: json['organisateur'] as String?,
      // « ?? const [] » : si la liste est absente du JSON, on prend une liste vide.
      animateurs: (json['animateurs'] as List<dynamic>? ?? const [])
          .map((a) => AnimateurResume.fromJson(a as Map<String, dynamic>))
          .toList(),
      infosComplementaires: json['infosComplementaires'] as String?,
      miseTotale: json['miseTotale'] as int?,
      afficheUrl: json['afficheUrl'] as String?,
      drapeaux: (json['drapeaux'] as List<dynamic>? ?? const [])
          .map((d) => DrapeauCalendrier.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get estAnnule => statut == StatutGala.annule;
}