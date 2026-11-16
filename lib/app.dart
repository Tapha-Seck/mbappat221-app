// Fichier : lib/app.dart
// Le widget racine : il configure l'application (titre, thème, premier écran).
// Équivalent Spring : une classe @Configuration qui assemble les briques.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/navigation/ecran_principal.dart';
import 'package:mbappat221_app/services/services_api.dart';
import 'package:mbappat221_app/theme/theme_mbappat.dart';
import 'package:mbappat221_app/widgets/cadre_telephone.dart';

class Mbappat221App extends StatelessWidget {
  /// Les services sont créés dans main.dart (ou par les tests) et passés ici.
  const Mbappat221App({super.key, required this.services});

  final ServicesApi services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mbappat 221',
      debugShowCheckedModeBanner: false,   // pas de bandeau « DEBUG »
      theme: ThemeMbappat.clair,           // couleurs, police Inter, barre d'onglets (voir theme_mbappat.dart)
      home: EcranPrincipal(services: services),
      // builder : « enveloppe » toute l'application dans un widget.
      // Ici, le cadre au format téléphone sur grand écran (voir cadre_telephone.dart).
      // « enfant ?? ... » : enfant est en principe toujours présent ; sinon, un widget vide.
      builder: (context, enfant) => CadreTelephone(child: enfant ?? const SizedBox.shrink()),
    );
  }
}