// Fichier : lib/widgets/cadre_telephone.dart
// Sur un grand écran (Chrome sur le PC, tablette), affiche l'application dans une colonne
// de la largeur d'un téléphone, centrée sur un fond sombre.
// Sur un téléphone, ne change rien : l'application occupe tout l'écran.

import 'package:flutter/material.dart';

class CadreTelephone extends StatelessWidget {
  const CadreTelephone({super.key, required this.child});

  /// L'application (tout ce que MaterialApp affiche : écrans, messages, fenêtres).
  final Widget child;

  /// Largeur d'un grand téléphone (en pixels logiques, comme le « px » du CSS).
  static const double largeurTelephone = 430;

  /// En dessous de cette largeur d'écran, on considère qu'on est sur un téléphone.
  static const double largeurMinimaleCadre = 900;

  @override
  Widget build(BuildContext context) {
    // MediaQuery : les informations sur l'écran (taille, orientation...).
    // sizeOf ne redessine ce widget que si la TAILLE change (plus efficace que MediaQuery.of).
    final ecran = MediaQuery.sizeOf(context);

    if (ecran.width < largeurMinimaleCadre) {
      return child;   // téléphone (ou petite fenêtre) : plein écran
    }

    return ColoredBox(
      color: const Color(0xFF1A1714),   // fond sombre autour du « téléphone »
      child: Center(
        child: SizedBox(
          width: largeurTelephone,
          // On fait croire à l'application que l'écran mesure 430 px de large,
          // pour que tout se calcule comme sur un vrai téléphone.
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(size: Size(largeurTelephone, ecran.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}