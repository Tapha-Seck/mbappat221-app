// Fichier : lib/ecrans/galas/elements_gala.dart
// Petits widgets partagés par la carte d'un gala, la fiche et l'accueil.
// (Avant, ils étaient privés dans carte_gala.dart ; maintenant plusieurs écrans s'en servent,
//  donc ils deviennent publics : on enlève le _ du nom, comme on passerait de private à public.)

import 'package:flutter/material.dart';

import 'package:mbappat221_app/outils/dates_fr.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

/// Bloc noir avec le jour (en or) et le mois : remplace l'affiche quand il n'y en a pas.
class BlocDate extends StatelessWidget {
  const BlocDate({super.key, required this.date, this.largeur = 64, this.hauteur = 84});

  final DateTime date;
  final double largeur;    // valeurs par défaut : BlocDate(date: d) suffit pour la carte
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    // Taille du texte proportionnelle à la hauteur : le même widget sert en petit et en grand.
    return Container(
      width: largeur,
      height: hauteur,
      decoration: BoxDecoration(color: Couleurs.noir, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${date.day}',
              style: TextStyle(
                  color: Couleurs.or, fontSize: hauteur * 0.31, fontWeight: FontWeight.w900)),
          Text(DatesFr.moisCourt(date),
              style: TextStyle(
                  color: Couleurs.blanc, fontSize: hauteur * 0.155, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Une ligne « icône + texte » (date, lieu, mise...).
class LigneInfo extends StatelessWidget {
  const LigneInfo({
    super.key,
    required this.icone,
    required this.texte,
    this.taille = 13,
    this.uneSeuleLigne = true,
  });

  final IconData icone;
  final String texte;
  final double taille;
  final bool uneSeuleLigne;   // true dans les cartes (texte coupé par « … »), false dans la fiche

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icone, size: taille + 2, color: Couleurs.orTexte),
          ),
          SizedBox(width: taille * 0.5),
          Expanded(
            child: Text(
              texte,
              maxLines: uneSeuleLigne ? 1 : null,          // null = pas de limite
              overflow: uneSeuleLigne ? TextOverflow.ellipsis : null,
              style: TextStyle(fontSize: taille, color: Couleurs.grisTexte),
            ),
          ),
        ],
      ),
    );
  }
}

/// Étiquette rouge « ANNULÉ ».
class EtiquetteAnnule extends StatelessWidget {
  const EtiquetteAnnule({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Couleurs.rouge, borderRadius: BorderRadius.circular(6)),
      child: const Text('ANNULÉ',
          style: TextStyle(color: Couleurs.blanc, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

/// Titre de section dans la fiche : « Catégories », « Animation »...
class TitreSection extends StatelessWidget {
  const TitreSection(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(texte,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    );
  }
}