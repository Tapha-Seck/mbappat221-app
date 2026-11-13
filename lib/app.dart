// Fichier : lib/app.dart
// Le widget racine : il configure l'application (titre, thème, premier écran).
// Équivalent Spring : une classe @Configuration qui assemble les briques.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/navigation/ecran_principal.dart';
import 'package:mbappat221_app/theme/theme_mbappat.dart';

class Mbappat221App extends StatelessWidget {
  const Mbappat221App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mbappat 221',
      debugShowCheckedModeBanner: false,   // pas de bandeau « DEBUG »
      theme: ThemeMbappat.clair,           // couleurs, police Inter, barre d'onglets (voir theme_mbappat.dart)
      home: const EcranPrincipal(),        // l'écran avec les 5 onglets
    );
  }
}