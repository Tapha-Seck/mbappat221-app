// Fichier : lib/ecrans/galas/carte_gala.dart
// La carte d'un gala dans la liste : affiche (ou bloc date), nom, date, lieu, mise et catégories.
//
// Nouveaux concepts :
//  - « collection if » :  [ if (condition) widget, ... ]  ajoute le widget seulement si la condition est vraie.
//  - « collection for » : [ for (final d in liste) widget ]  crée un widget par élément (≈ stream().map()).
//  - Image.network : affiche une image depuis une URL, avec un remplaçant en cas d'erreur.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/outils/dates_fr.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class CarteGala extends StatelessWidget {
  const CarteGala({super.key, required this.gala, this.urlAffiche});

  final Gala gala;
  final String? urlAffiche;   // adresse complète de l'affiche, ou null

  @override
  Widget build(BuildContext context) {
    final textes = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Couleurs.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Vignette(dateDebut: gala.dateDebut, urlAffiche: urlAffiche),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (gala.estAnnule) const _EtiquetteAnnule(),
                Text(
                  gala.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,   // « … » si le nom est trop long
                  style: textes.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    // Nom barré si le gala est annulé.
                    decoration: gala.estAnnule ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                _Ligne(
                  icone: Icons.calendar_today_outlined,
                  texte: DatesFr.majuscule(DatesFr.periode(gala.dateDebut, gala.dateFin)),
                ),
                _Ligne(icone: Icons.place_outlined, texte: '${gala.lieu} · ${gala.region}'),
                _Ligne(icone: Icons.payments_outlined, texte: gala.mise),
                if (gala.drapeaux.isNotEmpty) ...[
                  // « ... » (spread) : insère tous les éléments d'une liste dans une autre.
                  const SizedBox(height: 8),
                  // Wrap : comme une Row, mais passe à la ligne s'il n'y a plus de place.
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final drapeau in gala.drapeaux) _Categorie(nom: drapeau.categorieNom),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// L'affiche du promoteur en miniature, ou à défaut un bloc noir avec le jour et le mois.
class _Vignette extends StatelessWidget {
  const _Vignette({required this.dateDebut, this.urlAffiche});

  final DateTime dateDebut;
  final String? urlAffiche;

  static const double _largeur = 64;
  static const double _hauteur = 84;

  @override
  Widget build(BuildContext context) {
    final blocDate = _BlocDate(date: dateDebut, largeur: _largeur, hauteur: _hauteur);
    final url = urlAffiche;
    if (url == null) {
      return blocDate;
    }
    // ClipRRect : coupe son enfant avec des coins arrondis (border-radius + overflow: hidden en CSS).
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: _largeur,
        height: _hauteur,
        fit: BoxFit.cover,                       // remplit le cadre sans déformer (object-fit: cover)
        cacheWidth: 192,                         // décode l'image en petit : moins de mémoire utilisée
        // Si l'image ne se charge pas (réseau, fichier supprimé), on montre le bloc date.
        errorBuilder: (context, erreur, pile) => blocDate,
      ),
    );
  }
}

class _BlocDate extends StatelessWidget {
  const _BlocDate({required this.date, required this.largeur, required this.hauteur});

  final DateTime date;
  final double largeur;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largeur,
      height: hauteur,
      decoration: BoxDecoration(color: Couleurs.noir, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${date.day}',
              style: const TextStyle(color: Couleurs.or, fontSize: 26, fontWeight: FontWeight.w900)),
          Text(DatesFr.moisCourt(date),
              style: const TextStyle(color: Couleurs.blanc, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Une ligne « icône + texte » (date, lieu, mise).
class _Ligne extends StatelessWidget {
  const _Ligne({required this.icone, required this.texte});

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icone, size: 15, color: Couleurs.orTexte),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texte,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Couleurs.grisTexte),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une petite pastille de catégorie : « Poids lourds ».
class _Categorie extends StatelessWidget {
  const _Categorie({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Couleurs.fond,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: Text(nom, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _EtiquetteAnnule extends StatelessWidget {
  const _EtiquetteAnnule();

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