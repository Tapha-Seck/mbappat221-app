// Fichier : lib/ecrans/galas/ecran_galas.dart
// Onglet « Galas » : calendrier des galas à venir et résultats (développé à l'étape F2).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/widgets/ecran_en_construction.dart';

class EcranGalas extends StatelessWidget {
  const EcranGalas({super.key});

  @override
  Widget build(BuildContext context) {
    return const EcranEnConstruction(
      titre: 'Galas',
      icone: Icons.calendar_month,
      message: 'Le calendrier des galas à venir et les résultats arrivent très vite.',
    );
  }
}