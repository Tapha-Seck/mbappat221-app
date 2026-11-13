// Fichier : lib/ecrans/accueil/ecran_accueil.dart
// Onglet « Accueil » : bandeau de bienvenue, puis les rubriques principales.
// À l'étape F2, la carte « Prochain gala » affichera un vrai gala venu de l'API.
//
// Nouveau concept : découper un écran en petits widgets privés (_Bandeau, _TitreSection, _CarteRubrique).
// C'est l'équivalent d'extraire des méthodes privées en Java pour garder build() lisible.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/theme/couleurs.dart';

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mbappat 221', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      // ListView avec padding : tout le contenu défile si l'écran est trop petit.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Bandeau(),
          SizedBox(height: 24),
          _TitreSection('Prochain gala'),
          SizedBox(height: 8),
          _CarteRubrique(
            icone: Icons.event,
            titre: 'Le calendrier arrive bientôt',
            texte: 'Date, lieu, affiche et lutteurs de chaque gala annoncé.',
          ),
          SizedBox(height: 24),
          _TitreSection('Classement de la saison'),
          SizedBox(height: 8),
          _CarteRubrique(
            icone: Icons.emoji_events,
            titre: 'Le podium par catégorie',
            texte: 'Les meilleurs lutteurs de la saison, calculés selon le barème officiel.',
          ),
        ],
      ),
    );
  }
}

/// Le bandeau noir de bienvenue, en haut de l'accueil.
class _Bandeau extends StatelessWidget {
  const _Bandeau();

  @override
  Widget build(BuildContext context) {
    final textes = Theme.of(context).textTheme;

    // Container + BoxDecoration : un bloc avec fond, coins arrondis, bordure...
    // (l'équivalent d'une <div> avec background et border-radius en CSS).
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Couleurs.noir,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        // Aligne les enfants à gauche (par défaut, Column les centre horizontalement).
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('La lutte simple sénégalaise',
              style: textes.headlineSmall?.copyWith(
                color: Couleurs.blanc,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 6),
          Text('par Sérère Réfoum',
              style: textes.bodyMedium?.copyWith(
                color: Couleurs.or,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 16),
          Text('Galas, lutteurs, résultats et classements : toute la saison dans ta poche.',
              style: textes.bodyMedium?.copyWith(color: Couleurs.blanc)),
        ],
      ),
    );
  }
}

/// Un titre de section (« Prochain gala », « Classement de la saison »...).
class _TitreSection extends StatelessWidget {
  // Paramètre POSITIONNEL (sans accolades) : on écrit _TitreSection('Prochain gala'),
  // exactement comme un constructeur Java classique.
  const _TitreSection(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(texte,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800));
  }
}

/// Une carte blanche avec une icône dorée, un titre et un texte.
class _CarteRubrique extends StatelessWidget {
  const _CarteRubrique({required this.icone, required this.titre, required this.texte});

  final IconData icone;
  final String titre;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final textes = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Couleurs.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E2D4)),
      ),
      // Row : aligne ses enfants horizontalement (Column le fait verticalement).
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Couleurs.or,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: Couleurs.noir),
          ),
          const SizedBox(width: 16),
          // Expanded : le texte prend toute la largeur restante et passe à la ligne
          // au lieu de déborder de l'écran.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: textes.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(texte, style: textes.bodySmall?.copyWith(color: Couleurs.grisTexte)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}