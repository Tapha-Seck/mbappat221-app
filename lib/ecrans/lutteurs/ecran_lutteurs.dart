// Fichier : lib/ecrans/lutteurs/ecran_lutteurs.dart
// Onglet « Lutteurs » : recherche et fiches des lutteurs (développé plus tard).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/widgets/ecran_en_construction.dart';

class EcranLutteurs extends StatelessWidget {
  const EcranLutteurs({super.key});

  @override
  Widget build(BuildContext context) {
    return const EcranEnConstruction(
      titre: 'Lutteurs',
      icone: Icons.person_search,
      message: 'Retrouve bientôt chaque lutteur : écurie, catégorie, palmarès et photos.',
    );
  }
}