// Fichier : lib/ecrans/galas/carte_gala.dart
// La carte d'un gala dans une liste : affiche (ou bloc date), nom, date, lieu, mise et catégories.
// Un appui sur la carte appelle [surAppui] (ouverture de la fiche du gala).
//
// Rappels : « collection if » [ if (c) widget ], « collection for » [ for (x in liste) widget ],
// spread « ... » pour insérer une liste dans une autre.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/elements_gala.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/outils/dates_fr.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class CarteGala extends StatelessWidget {
  const CarteGala({super.key, required this.gala, this.urlAffiche, this.surAppui});

  final Gala gala;
  final String? urlAffiche;      // adresse complète de l'affiche, ou null
  final VoidCallback? surAppui;  // VoidCallback = fonction sans paramètre (≈ Runnable) ; null = pas cliquable

  @override
  Widget build(BuildContext context) {
    final textes = Theme.of(context).textTheme;

    // Material + InkWell : la carte réagit au toucher avec l'effet « vague » de Material Design.
    // (Un Container ne sait pas réagir au toucher ; InkWell, si.)
    return Material(
      color: Couleurs.blanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Couleurs.bordure),
      ),
      clipBehavior: Clip.antiAlias,   // l'effet du toucher reste dans les coins arrondis
      child: InkWell(
        onTap: surAppui,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Vignette(dateDebut: gala.dateDebut, urlAffiche: urlAffiche),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gala.estAnnule) const EtiquetteAnnule(),
                    Text(
                      gala.nom,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textes.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        decoration: gala.estAnnule ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LigneInfo(
                      icone: Icons.calendar_today_outlined,
                      texte: DatesFr.majuscule(DatesFr.periode(gala.dateDebut, gala.dateFin)),
                    ),
                    LigneInfo(icone: Icons.place_outlined, texte: '${gala.lieu} · ${gala.region}'),
                    LigneInfo(icone: Icons.payments_outlined, texte: gala.mise),
                    if (gala.drapeaux.isNotEmpty) ...[
                      const SizedBox(height: 8),
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
        ),
      ),
    );
  }
}

/// L'affiche du promoteur en miniature, ou à défaut le bloc date.
class _Vignette extends StatelessWidget {
  const _Vignette({required this.dateDebut, this.urlAffiche});

  final DateTime dateDebut;
  final String? urlAffiche;

  @override
  Widget build(BuildContext context) {
    final blocDate = BlocDate(date: dateDebut);
    final url = urlAffiche;
    if (url == null) {
      return blocDate;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 64,
        height: 84,
        fit: BoxFit.cover,
        cacheWidth: 192,   // décode l'image en petit : moins de mémoire utilisée
        errorBuilder: (context, erreur, pile) => blocDate,
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