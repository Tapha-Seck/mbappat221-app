// Fichier : lib/outils/dates_fr.dart
// Formatage des dates en français, sans dépendance externe.
// (Équivalent Java : DateTimeFormatter.ofPattern("EEEE d MMMM yyyy", Locale.FRENCH).)

abstract final class DatesFr {
  // DateTime.weekday : 1 = lundi ... 7 = dimanche (comme DayOfWeek en Java).
  static const _jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
  static const _mois = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  static const _moisCourts = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  /// « samedi 21 novembre 2026 », « dimanche 1er novembre 2026 »
  static String complete(DateTime date) =>
      '${_jours[date.weekday - 1]} ${_jour(date.day)} ${_mois[date.month - 1]} ${date.year}';

  /// « nov. » (pour le petit bloc date des cartes)
  static String moisCourt(DateTime date) => _moisCourts[date.month - 1];

  /// La période d'un gala :
  ///   un seul jour       → « samedi 21 novembre 2026 »
  ///   même mois          → « du 21 au 22 novembre 2026 »
  ///   deux mois          → « du 30 novembre au 1er décembre 2026 »
  ///   deux années        → « du 31 décembre 2026 au 1er janvier 2027 »
  static String periode(DateTime debut, DateTime fin) {
    if (_memeJour(debut, fin)) {
      return complete(debut);
    }
    final finTexte = '${_jour(fin.day)} ${_mois[fin.month - 1]} ${fin.year}';
    if (debut.year != fin.year) {
      return 'du ${_jour(debut.day)} ${_mois[debut.month - 1]} ${debut.year} au $finTexte';
    }
    if (debut.month != fin.month) {
      return 'du ${_jour(debut.day)} ${_mois[debut.month - 1]} au $finTexte';
    }
    return 'du ${_jour(debut.day)} au $finTexte';
  }

  /// Met une majuscule à la première lettre : « samedi... » → « Samedi... ».
  static String majuscule(String texte) =>
      texte.isEmpty ? texte : texte[0].toUpperCase() + texte.substring(1);

  static String _jour(int jour) => jour == 1 ? '1er' : '$jour';

  static bool _memeJour(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}