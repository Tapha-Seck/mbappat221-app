// Fichier : lib/widgets/filtres_categories.dart
// La rangée de pastilles « Toutes · Poids Lourds · Poids Légers… », qui défile horizontalement.
// Partagée par les onglets Lutteurs (avec « Toutes ») et Classement (sans « Toutes »).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/modeles/categorie.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class FiltresCategories extends StatelessWidget {
  const FiltresCategories({
    super.key,
    required this.categories,
    required this.categorieId,
    required this.surChoix,
    this.libelleToutes,
  });

  final List<Categorie> categories;
  final int? categorieId;            // la catégorie choisie (null = « Toutes »)
  final ValueChanged<int?> surChoix; // appelée avec l'identifiant choisi
  final String? libelleToutes;       // « Toutes » ; null = pas de pastille « Toutes »

  @override
  Widget build(BuildContext context) {
    final toutes = libelleToutes;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (toutes != null)
            _Filtre(libelle: toutes, actif: categorieId == null, surAppui: () => surChoix(null)),
          for (final categorie in categories)
            _Filtre(
              libelle: categorie.nom,
              actif: categorieId == categorie.id,
              surAppui: () => surChoix(categorie.id),
            ),
        ],
      ),
    );
  }
}

class _Filtre extends StatelessWidget {
  const _Filtre({required this.libelle, required this.actif, required this.surAppui});

  final String libelle;
  final bool actif;
  final VoidCallback surAppui;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      // ChoiceChip : une pastille sélectionnable (un seul choix actif à la fois).
      child: ChoiceChip(
        label: Text(libelle),
        selected: actif,
        onSelected: (_) => surAppui(),
        showCheckmark: false,
        selectedColor: Couleurs.or,
        backgroundColor: Couleurs.blanc,
        side: BorderSide(color: actif ? Couleurs.or : Couleurs.bordure),
        labelStyle: TextStyle(
          color: Couleurs.noir,
          fontWeight: actif ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}