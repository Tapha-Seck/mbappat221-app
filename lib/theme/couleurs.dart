// Fichier : lib/theme/couleurs.dart
// Les couleurs de Mbappat 221, identiques au back-office (admin.css).
//
// « abstract final class » : on ne peut ni l'instancier ni en hériter.
// C'est l'équivalent Java de : public final class Couleurs { private Couleurs() {} ... }
// « static const » = « public static final » d'une constante connue à la compilation.

import 'package:flutter/material.dart';

abstract final class Couleurs {
  /// Format 0xAARRGGBB : FF = totalement opaque, puis le code hexadécimal habituel (#FAB724).
  static const or = Color(0xFFFAB724);       // jaune or du logo
  static const noir = Color(0xFF050301);     // noir du logo
  static const orTexte = Color(0xFF8A6100);  // or foncé, lisible sur fond blanc
  static const fond = Color(0xFFF6F3EC);     // fond crème des écrans
  static const blanc = Color(0xFFFFFFFF);
  static const grisTexte = Color(0xFF6B6760); // textes secondaires
  static const bordure = Color(0xFFE8E2D4);   // contour des cartes
  static const rouge = Color(0xFFB3261E);     // gala annulé, erreurs
}