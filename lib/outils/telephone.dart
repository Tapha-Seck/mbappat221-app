// Fichier : lib/outils/telephone.dart
// Numéros de téléphone sénégalais : affichage lisible et liens d'appel / WhatsApp.
//
// Un numéro sénégalais a 9 chiffres (77 123 45 67) ; l'indicatif du pays est 221.
// Dans le back-office, il peut être saisi de plusieurs façons : « 77 123 45 67 »,
// « +221 77 123 45 67 », « 00221771234567 »... On le ramène toujours à la même forme.

abstract final class Telephone {
  static const _indicatif = '221';

  /// Seulement les chiffres : « +221 77-123 45 67 » → « 221771234567 ».
  /// RegExp(r'\D') : tout caractère qui n'est PAS un chiffre (comme en Java).
  static String _chiffres(String numero) => numero.replaceAll(RegExp(r'\D'), '');

  /// Forme internationale sans « + » : « 221771234567 » (pour WhatsApp et les appels).
  static String international(String numero) {
    var chiffres = _chiffres(numero);
    if (chiffres.startsWith('00')) {
      chiffres = chiffres.substring(2);            // 00221... → 221...
    }
    if (chiffres.length == 9) {
      chiffres = '$_indicatif$chiffres';            // numéro local : on ajoute 221
    }
    return chiffres;
  }

  /// « 77 123 45 67 » pour un numéro sénégalais ; sinon le numéro tel qu'il a été saisi.
  static String affichage(String numero) {
    final chiffres = international(numero);
    if (chiffres.length != 12 || !chiffres.startsWith(_indicatif)) {
      return numero.trim();
    }
    final local = chiffres.substring(3);   // les 9 chiffres après 221
    return '${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5, 7)} ${local.substring(7)}';
  }

  /// Lien « tel: » : ouvre le composeur du téléphone avec le numéro.
  static Uri lienAppel(String numero) => Uri.parse('tel:+${international(numero)}');

  /// Lien WhatsApp : ouvre une discussion avec ce numéro (application ou site web).
  static Uri lienWhatsApp(String numero) => Uri.parse('https://wa.me/${international(numero)}');
}