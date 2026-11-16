// Fichier : lib/modeles/fiche_lutteur.dart
// La fiche complète d'un lutteur : miroir de FicheLutteurDto, LutteurDto, BilanSaisonDto
// et FinaleHistoriqueDto (backend).

class FicheLutteur {
  const FicheLutteur({
    required this.lutteur,
    required this.photos,
    required this.saisonLibelle,
    required this.bilan,
    required this.historique,
  });

  final LutteurDetail lutteur;
  final List<String> photos;              // jusqu'à 4 photos (adresses relatives)
  final String saisonLibelle;             // « 2026-2027 »
  final BilanSaison bilan;                // le bilan de cette saison
  final List<FinaleHistorique> historique; // toutes ses finales, toutes saisons

  factory FicheLutteur.fromJson(Map<String, dynamic> json) {
    return FicheLutteur(
      lutteur: LutteurDetail.fromJson(json['lutteur'] as Map<String, dynamic>),
      // « .cast<String>() » : la liste JSON est une List<dynamic> ; on la voit comme une List<String>.
      photos: (json['photos'] as List<dynamic>? ?? const []).cast<String>(),
      saisonLibelle: json['saisonLibelle'] as String,
      bilan: BilanSaison.fromJson(json['bilan'] as Map<String, dynamic>),
      historique: (json['historique'] as List<dynamic>? ?? const [])
          .map((f) => FinaleHistorique.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LutteurDetail {
  const LutteurDetail({
    required this.id,
    required this.nom,
    required this.categorieNom,
    required this.retraite,
    this.surnom,
    this.ecurieNom,
    this.region,
    this.photoUrl,
    this.apercu,
    this.biographie,
  });

  final int id;
  final String nom;
  final String categorieNom;
  final bool retraite;
  final String? surnom;
  final String? ecurieNom;
  final String? region;
  final String? photoUrl;     // la photo principale
  final String? apercu;       // une phrase de présentation
  final String? biographie;

  factory LutteurDetail.fromJson(Map<String, dynamic> json) {
    return LutteurDetail(
      id: json['id'] as int,
      nom: json['nom'] as String,
      categorieNom: json['categorieNom'] as String,
      retraite: json['retraite'] as bool? ?? false,
      surnom: json['surnom'] as String?,
      ecurieNom: json['ecurieNom'] as String?,
      region: json['region'] as String?,
      photoUrl: json['photoUrl'] as String?,
      apercu: json['apercu'] as String?,
      biographie: json['biographie'] as String?,
    );
  }

  String get nomAffiche => surnom ?? nom;
}

class BilanSaison {
  const BilanSaison({
    required this.finalesDisputees,
    required this.victoires,
    required this.defaites,
    required this.points,
    required this.totalGagne,
    this.lotsRecus = const [],
  });

  final int finalesDisputees;
  final int victoires;
  final int defaites;
  final int points;
  final int totalGagne;          // en FCFA (long en Java ; int en Dart couvre 64 bits sur mobile)
  final List<String> lotsRecus;  // « 1 bœuf », « 1 moto »...

  factory BilanSaison.fromJson(Map<String, dynamic> json) {
    return BilanSaison(
      finalesDisputees: json['finalesDisputees'] as int,
      victoires: json['victoires'] as int,
      defaites: json['defaites'] as int,
      points: json['points'] as int,
      totalGagne: json['totalGagne'] as int,
      lotsRecus: (json['lotsRecus'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }
}

/// Une finale disputée par le lutteur, vue de son côté (victoire ou défaite, contre qui).
class FinaleHistorique {
  const FinaleHistorique({
    required this.finaleId,
    required this.galaNom,
    required this.categorieNom,
    required this.victoire,
    required this.adversaire,
    required this.points,
    this.date,
    this.lieu,
    this.gainRecu,
  });

  final int finaleId;
  final String galaNom;
  final String categorieNom;
  final bool victoire;
  final String adversaire;   // surnom de l'adversaire, ou son nom
  final int points;
  final DateTime? date;
  final String? lieu;
  final String? gainRecu;    // « 500 000 FCFA », « 1 bœuf »... ou null

  factory FinaleHistorique.fromJson(Map<String, dynamic> json) {
    final date = json['date'] as String?;
    final adversaire = json['adversaire'] as Map<String, dynamic>?;
    return FinaleHistorique(
      finaleId: json['finaleId'] as int,
      galaNom: json['galaNom'] as String,
      categorieNom: json['categorieNom'] as String,
      victoire: json['victoire'] as bool,
      adversaire: adversaire == null
          ? 'adversaire inconnu'
          : (adversaire['surnom'] as String? ?? adversaire['nom'] as String),
      points: json['points'] as int,
      date: date == null ? null : DateTime.parse(date),
      lieu: json['lieu'] as String?,
      gainRecu: json['gainRecu'] as String?,
    );
  }
}