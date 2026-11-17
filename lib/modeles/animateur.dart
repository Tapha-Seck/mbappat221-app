// Fichier : lib/modeles/animateur.dart
// Les animateurs (cantatrices, griots et Tv Tv) : miroir de AnimateurResumeDto (sur un gala),
// AnimateurDto (profil complet), GalaAnimeDto et AnimateurProfilDto (backend).

import 'package:mbappat221_app/modeles/gala.dart';

/// Enum « enrichi » : comme un enum Java avec un champ et un constructeur.
///   Java : CANTATRICE("Cantatrice"), GRIOT("Griot"); private final String libelle; ...
///   Le pluriel est écrit à la main : « Tv Tv » reste « Tv Tv » (un simple « + s » ne marcherait pas).
enum RoleAnimateur {
  cantatrice('Cantatrice', 'Cantatrices'),
  griot('Griot', 'Griots'),
  /// Les « Tv Tv » : jeunes qui ont une chaîne YouTube consacrée à la lutte simple.
  tv('Tv Tv', 'Tv Tv');

  const RoleAnimateur(this.libelle, this.libellePluriel);

  final String libelle;
  final String libellePluriel;   // pour les filtres : « Cantatrices », « Griots », « Tv Tv »

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

/// Un animateur avec tout son profil (liste publique et page de profil).
class AnimateurDetail {
  const AnimateurDetail({
    required this.id,
    required this.nom,
    required this.role,
    this.surnom,
    this.region,
    this.apercu,
    this.biographie,
    this.telephone,
    this.youtubeUrl,
    this.photoUrl,
    this.photos = const [],
  });

  final int id;
  final String nom;
  final RoleAnimateur role;
  final String? surnom;
  final String? region;
  final String? apercu;
  final String? biographie;
  /// Contact pour réservation. Il n'est saisi dans le back-office QU'AVEC l'accord de l'animateur :
  /// s'il est null, on n'affiche aucun bouton d'appel.
  final String? telephone;
  /// L'adresse de la chaîne YouTube (surtout pour les Tv Tv), ou null.
  final String? youtubeUrl;
  final String? photoUrl;
  final List<String> photos;   // 0 à 4, la première est la principale

  factory AnimateurDetail.fromJson(Map<String, dynamic> json) {
    return AnimateurDetail(
      id: json['id'] as int,
      nom: json['nom'] as String,
      role: RoleAnimateur.depuisJson(json['role'] as String),
      surnom: json['surnom'] as String?,
      region: json['region'] as String?,
      apercu: json['apercu'] as String?,
      biographie: json['biographie'] as String?,
      telephone: json['telephone'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
      photos: (json['photos'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }

  /// Le surnom en premier s'il existe, comme pour les lutteurs.
  String get nomAffiche => surnom ?? nom;

  /// « Cantatrice · Fatick » ou « Griot »
  String get roleEtRegion => region == null ? role.libelle : '${role.libelle} · $region';
}

/// Un gala animé par l'animateur (sur sa page de profil).
class GalaAnime {
  const GalaAnime({
    required this.id,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.lieu,
    required this.region,
    required this.statut,
  });

  final int id;
  final String nom;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String lieu;
  final String region;
  final StatutGala statut;

  factory GalaAnime.fromJson(Map<String, dynamic> json) {
    return GalaAnime(
      id: json['id'] as int,
      nom: json['nom'] as String,
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      dateFin: DateTime.parse(json['dateFin'] as String),
      lieu: json['lieu'] as String,
      region: json['region'] as String,
      statut: StatutGala.depuisJson(json['statut'] as String),
    );
  }
}

/// La page de profil : l'animateur et ses galas.
class ProfilAnimateur {
  const ProfilAnimateur({required this.animateur, required this.galas});

  final AnimateurDetail animateur;
  final List<GalaAnime> galas;

  factory ProfilAnimateur.fromJson(Map<String, dynamic> json) {
    return ProfilAnimateur(
      animateur: AnimateurDetail.fromJson(json['animateur'] as Map<String, dynamic>),
      galas: (json['galas'] as List<dynamic>? ?? const [])
          .map((g) => GalaAnime.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }
}