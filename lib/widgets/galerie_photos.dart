// Fichier : lib/widgets/galerie_photos.dart
// Une galerie de photos (lutteurs, animateurs) : on les fait glisser, un appui ouvre le plein écran.
//
// Nouveaux concepts :
//  - PageView          : des pages qu'on fait glisser du doigt.
//  - AnimatedContainer : un conteneur qui s'anime tout seul quand ses dimensions changent
//                        (les petits points sous la galerie).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/ecran_affiche.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

/// Des photos qu'on fait glisser du doigt ; un appui ouvre la photo en plein écran (zoom).
/// StatefulWidget : il retient la photo affichée, pour allumer le bon petit point.
class GaleriePhotos extends StatefulWidget {
  const GaleriePhotos({
    super.key,
    required this.photos,
    required this.titre,
    required this.prefixeHero,
    this.hauteur = 340,
  });

  final List<String> photos;   // adresses COMPLÈTES
  final String titre;          // titre de l'écran plein écran
  final String prefixeHero;    // ex. « photo-lutteur-5 » : rend le tag Hero unique
  final double hauteur;

  @override
  State<GaleriePhotos> createState() => _GaleriePhotosState();
}

class _GaleriePhotosState extends State<GaleriePhotos> {
  int _photoActive = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: widget.hauteur,
            color: Couleurs.noir,
            // PageView.builder : une page par photo, construite seulement quand elle apparaît.
            child: PageView.builder(
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _photoActive = index),
              itemBuilder: (context, index) {
                final url = widget.photos[index];
                final tag = '${widget.prefixeHero}-$index';
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => EcranAffiche(url: url, titre: widget.titre, tagHero: tag),
                  )),
                  child: Hero(
                    tag: tag,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, erreur, pile) => const Center(
                        child: Icon(Icons.broken_image_outlined, color: Couleurs.blanc, size: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.photos.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.photos.length; i++)
              // Le point actif s'allonge en douceur (200 ms) : AnimatedContainer anime le changement.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _photoActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _photoActive ? Couleurs.or : Couleurs.bordure,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}