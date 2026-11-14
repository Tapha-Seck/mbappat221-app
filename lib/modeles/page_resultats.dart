// Fichier : lib/modeles/page_resultats.dart
// Une page de résultats : le miroir Dart de PageDto<T> du backend.
//
// <T> : une classe générique, exactement comme en Java (PageResultats<Gala>, PageResultats<Lutteur>...).

class PageResultats<T> {
  const PageResultats({
    required this.contenu,
    required this.page,
    required this.taille,
    required this.totalElements,
    required this.totalPages,
  });

  final List<T> contenu;
  final int page;
  final int taille;
  final int totalElements;
  final int totalPages;

  /// Un « getter » : se lit comme un champ (page.estLaDerniere), calculé à chaque lecture.
  /// Équivalent Java : public boolean estLaDerniere() { ... }
  bool get estLaDerniere => page + 1 >= totalPages;

  /// Construit la page à partir du JSON.
  /// [convertir] transforme chaque élément JSON en objet T : on passe par exemple Gala.fromJson,
  /// comme on passerait Gala::new ou une Function<Map, Gala> en Java.
  factory PageResultats.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) convertir,
      ) {
    return PageResultats(
      contenu: (json['contenu'] as List<dynamic>)
          .map((element) => convertir(element as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      taille: json['taille'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}