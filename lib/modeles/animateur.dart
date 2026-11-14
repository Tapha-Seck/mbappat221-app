// Fichier : lib/modeles/animateur.dart
// Un animateur (cantatrice ou griot) tel qu'il apparaît sur un gala : miroir de AnimateurResumeDto.

/// Enum « enrichi » : comme un enum Java avec un champ et un constructeur.
///   Java : CANTATRICE("Cantatrice"), GRIOT("Griot"); private final String libelle; ...
enum RoleAnimateur {
  cantatrice('Cantatrice'),
  griot('Griot');

  const RoleAnimateur(this.libelle);

  final String libelle;

  /// Le JSON contient "CANTATRICE" ; byName cherche la constante « cantatrice »
  /// (≈ RoleAnimateur.valueOf(...) en Java). Lance une erreur si la valeur est inconnue.
  static RoleAnimateur depuisJson(String valeur) => RoleAnimateur.values.byName(valeur.toLowerCase());
}

class AnimateurResume {
  const AnimateurResume({
    required this.id,
    required this.nom,
    required this.role,
    this.surnom,
    this.photoUrl,
  });

  final int id;
  final String nom;
  final RoleAnimateur role;
  final String? surnom;     // « String? » : peut être null (en Java, tout objet peut l'être ;
  final String? photoUrl;   //  en Dart, il faut le DIRE avec ?, sinon le compilateur l'interdit)

  /// « factory » : un constructeur qui peut faire un calcul avant de créer l'objet
  /// (≈ une méthode statique de fabrique en Java : AnimateurResume.depuisJson(map)).
  factory AnimateurResume.fromJson(Map<String, dynamic> json) {
    return AnimateurResume(
      id: json['id'] as int,                 // « as int » : un cast, comme (Integer) en Java
      nom: json['nom'] as String,
      role: RoleAnimateur.depuisJson(json['role'] as String),
      surnom: json['surnom'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// « Ndèye Fatou « La Diva » » ou simplement le nom s'il n'y a pas de surnom.
  String get nomAffiche => surnom == null ? nom : '$nom « $surnom »';
}