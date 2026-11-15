// Fichier : lib/ecrans/galas/ecran_affiche.dart
// L'affiche d'un gala en plein écran, avec zoom au doigt (pincer pour agrandir, glisser pour se déplacer).
//
// Nouveaux concepts :
//  - InteractiveViewer : rend son enfant zoomable et déplaçable, sans aucun calcul de notre part.
//  - Hero : anime l'image de la fiche jusqu'au plein écran (elle « vole » d'un écran à l'autre).

import 'package:flutter/material.dart';

class EcranAffiche extends StatelessWidget {
  const EcranAffiche({super.key, required this.url, required this.titre, required this.tagHero});

  final String url;
  final String titre;
  final String tagHero;   // même tag que l'image de la fiche : Flutter relie les deux pour l'animation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: const Border(),   // pas de trait de séparation sur fond noir
        title: Text(titre, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 5,              // jusqu'à 5 fois plus grand : on lit les petits textes de l'affiche
        child: Center(
          child: Hero(
            tag: tagHero,
            child: Image.network(url, fit: BoxFit.contain),   // contain : l'affiche entière, sans rognage
          ),
        ),
      ),
    );
  }
}