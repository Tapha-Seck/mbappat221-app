// Fichier : lib/outils/youtube.dart
// Les liens YouTube des Tv Tv : « Voir la chaîne » et « S'abonner ».
//
// Astuce YouTube : ajouter « ?sub_confirmation=1 » à l'adresse d'une CHAÎNE ouvre directement
// la fenêtre « S'abonner ». Cela ne marche que pour une chaîne (pas pour une vidéo youtu.be).

abstract final class YouTube {
  /// Les débuts d'adresse d'une chaîne : /@nom, /channel/ID, /c/nom, /user/nom.
  static const _debutsDeChaine = ['/@', '/channel/', '/c/', '/user/'];

  /// L'adresse est-elle celle d'une chaîne (et non d'une vidéo) ?
  static bool estUneChaine(String adresse) {
    final uri = Uri.tryParse(adresse);   // tryParse : null au lieu d'une exception si l'adresse est mal formée
    if (uri == null || !uri.host.contains('youtube.com')) {
      return false;
    }
    // any(...) ≈ stream().anyMatch(...) en Java.
    return _debutsDeChaine.any(uri.path.startsWith);
  }

  /// L'adresse de la chaîne, telle qu'enregistrée (le serveur ajoute déjà « https:// »).
  static Uri lienChaine(String adresse) => Uri.parse(adresse);

  /// La chaîne avec la fenêtre « S'abonner » ouverte. On GARDE les paramètres déjà présents.
  static Uri lienAbonnement(String adresse) {
    final uri = Uri.parse(adresse);
    // « ...uri.queryParameters » : on recopie les paramètres existants, puis on ajoute le nôtre.
    return uri.replace(queryParameters: {...uri.queryParameters, 'sub_confirmation': '1'});
  }
}