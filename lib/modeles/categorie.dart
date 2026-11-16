// Fichier : lib/modeles/categorie.dart
// Une catégorie de lutteurs (Poids Lourds, Poids Légers...) : miroir de CategorieDto.

class Categorie {
  const Categorie({required this.id, required this.nom, required this.ordre});

  final int id;
  final String nom;
  final int ordre;   // ordre officiel d'affichage

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'] as int,
      nom: json['nom'] as String,
      ordre: json['ordre'] as int,
    );
  }
}