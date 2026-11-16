// Fichier : lib/modeles/lutteur.dart
// Un lutteur dans la liste publique : miroir de LutteurListeDto (backend).

class LutteurListe {
  const LutteurListe({
    required this.id,
    required this.nom,
    required this.categorieId,
    required this.categorieNom,
    this.surnom,
    this.ecurieNom,
    this.region,
    this.photoUrl,
  });

  final int id;
  final String nom;
  final int categorieId;
  final String categorieNom;
  final String? surnom;      // le nom de lutte, souvent le plus connu du public
  final String? ecurieNom;   // null = sans écurie
  final String? region;
  final String? photoUrl;

  factory LutteurListe.fromJson(Map<String, dynamic> json) {
    return LutteurListe(
      id: json['id'] as int,
      nom: json['nom'] as String,
      categorieId: json['categorieId'] as int,
      categorieNom: json['categorieNom'] as String,
      surnom: json['surnom'] as String?,
      ecurieNom: json['ecurieNom'] as String?,
      region: json['region'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Le nom affiché en gros : le surnom s'il existe (c'est sous ce nom qu'on le connaît), sinon le nom.
  String get nomAffiche => surnom ?? nom;

  /// « Poids Lourds · Écurie Fass » ou « Poids Lourds · Sans écurie »
  String get categorieEtEcurie => '$categorieNom · ${ecurieNom ?? 'Sans écurie'}';
}