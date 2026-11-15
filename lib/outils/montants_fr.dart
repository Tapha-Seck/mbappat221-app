// Fichier : lib/outils/montants_fr.dart
// Formatage des montants en FCFA, comme le backend (Mise.formaterFcfa) : 1500000 → « 1 500 000 FCFA ».

abstract final class MontantsFr {
  static String fcfa(int montant) {
    final chiffres = montant.abs().toString();
    // StringBuffer ≈ StringBuilder en Java : on construit la chaîne morceau par morceau.
    final tampon = StringBuffer();
    for (var i = 0; i < chiffres.length; i++) {
      // Un espace avant chaque groupe de 3 chiffres, en partant de la droite.
      if (i > 0 && (chiffres.length - i) % 3 == 0) {
        tampon.write(' ');
      }
      tampon.write(chiffres[i]);
    }
    final signe = montant < 0 ? '-' : '';
    return '$signe$tampon FCFA';
  }
}