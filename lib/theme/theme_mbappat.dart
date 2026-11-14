// Fichier : lib/theme/theme_mbappat.dart
// Le thème global : couleurs, police Inter, style de la barre d'onglets.
// Tous les widgets lisent ce thème : on change une valeur ici, toute l'application suit
// (comme les variables CSS --or, --noir du back-office).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/theme/couleurs.dart';

abstract final class ThemeMbappat {
  /// « static final » : calculé une seule fois, au premier accès (initialisation paresseuse),
  /// puis réutilisé. Même idée qu'un singleton Java « private static final ThemeData CLAIR = ... ».
  static final ThemeData clair = _construireClair();

  /// Le _ rend la méthode privée au fichier (comme « private static »).
  static ThemeData _construireClair() {
    // ColorScheme : la palette complète de Material 3. fromSeed() calcule toutes les teintes
    // à partir d'une couleur « graine », et on impose nos couleurs exactes pour les rôles principaux.
    final palette = ColorScheme.fromSeed(
      seedColor: Couleurs.or,
      primary: Couleurs.noir,        // boutons principaux, éléments actifs
      onPrimary: Couleurs.blanc,     // texte posé sur « primary »
      secondary: Couleurs.or,
      onSecondary: Couleurs.noir,
      surface: Couleurs.blanc,       // barres du haut, cartes
      onSurface: Couleurs.noir,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: palette,
      fontFamily: 'Inter',                       // déclarée dans pubspec.yaml (section fonts)
      scaffoldBackgroundColor: Couleurs.fond,    // fond crème derrière chaque écran

      // La barre du haut de chaque écran : toujours blanche, même quand le contenu défile dessous
      // (par défaut, Material 3 la teinte en beige au défilement : « scrolled under »).
      appBarTheme: const AppBarThemeData(
        backgroundColor: Couleurs.blanc,
        foregroundColor: Couleurs.noir,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Couleurs.bordure)),   // fin trait de séparation
      ),

      // La barre d'onglets du bas.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Couleurs.blanc,
        indicatorColor: Couleurs.or,             // la « pastille » dorée derrière l'onglet actif
        height: 68,
        // WidgetStateProperty : une valeur qui dépend de l'état (sélectionné, survolé, désactivé...).
        // resolveWith reçoit l'ensemble des états courants et renvoie le style à utiliser.
        labelTextStyle: WidgetStateProperty.resolveWith((etats) {
          final actif = etats.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: actif ? FontWeight.w700 : FontWeight.w500,   // opérateur ternaire, comme en Java
            color: actif ? Couleurs.noir : Couleurs.grisTexte,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((etats) {
          final actif = etats.contains(WidgetState.selected);
          return IconThemeData(color: actif ? Couleurs.noir : Couleurs.grisTexte);
        }),
      ),
    );
  }
}