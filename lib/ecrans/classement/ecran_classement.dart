// Fichier : lib/ecrans/classement/ecran_classement.dart
// Onglet « Classement » : classement de la saison par catégorie (développé plus tard).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/widgets/ecran_en_construction.dart';

class EcranClassement extends StatelessWidget {
  const EcranClassement({super.key});

  @override
  Widget build(BuildContext context) {
    return const EcranEnConstruction(
      titre: 'Classement',
      icone: Icons.leaderboard,
      message: 'Le classement de la saison, catégorie par catégorie, avec le podium.',
    );
  }
}