// Fichier : lib/modeles/classement.dart
// Le classement d'une catégorie et le podium de la saison :
// miroir de ClassementDto, LigneClassementDto et PodiumDto (backend).
//
// Les points sont calculés par le serveur selon le barème de la saison (jamais codé en dur ici).

class LigneClassement {
  const LigneClassement({
    required this.rang,
    required this.lutteurId,
    required this.nom,
    required this.points,
    required this.victoires,
    required this.defaites,
    required this.finales,
    required this.totalGagne,
    this.surnom,
  });

  final int rang;          // deux lutteurs à égalité parfaite ont le même rang
  final int lutteurId;
  final String nom;
  final String? surnom;
  final int points;
  final int victoires;
  final int defaites;
  final int finales;
  final int totalGagne;    // FCFA

  factory LigneClassement.fromJson(Map<String, dynamic> json) {
    final lutteur = json['lutteur'] as Map<String, dynamic>;
    return LigneClassement(
      rang: json['rang'] as int,
      lutteurId: lutteur['id'] as int,
      nom: lutteur['nom'] as String,
      surnom: lutteur['surnom'] as String?,
      points: json['points'] as int,
      victoires: json['victoires'] as int,
      defaites: json['defaites'] as int,
      finales: json['finales'] as int,
      totalGagne: json['totalGagne'] as int,
    );
  }

  String get nomAffiche => surnom ?? nom;

  /// « 3 V · 1 D »
  String get bilanCourt => '$victoires V · $defaites D';
}

class Classement {
  const Classement({
    required this.categorieId,
    required this.categorieNom,
    required this.saisonLibelle,
    required this.lignes,
  });

  final int categorieId;
  final String categorieNom;
  final String saisonLibelle;
  final List<LigneClassement> lignes;

  factory Classement.fromJson(Map<String, dynamic> json) {
    return Classement(
      categorieId: json['categorieId'] as int,
      categorieNom: json['categorieNom'] as String,
      saisonLibelle: json['saisonLibelle'] as String,
      lignes: (json['lignes'] as List<dynamic>? ?? const [])
          .map((l) => LigneClassement.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Le premier du classement, ou null si personne n'a encore disputé de finale
  /// (≈ stream().findFirst().orElse(null) en Java).
  LigneClassement? get leader => lignes.isEmpty ? null : lignes.first;
}

/// Le podium de la saison : les premiers de CHAQUE catégorie (même celles sans finale).
class Podium {
  const Podium({required this.saisonLibelle, required this.categories});

  final String saisonLibelle;
  final List<Classement> categories;

  factory Podium.fromJson(Map<String, dynamic> json) {
    return Podium(
      saisonLibelle: json['saisonLibelle'] as String,
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .map((c) => Classement.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}