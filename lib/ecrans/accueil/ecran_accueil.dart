// Fichier : lib/ecrans/accueil/ecran_accueil.dart
// Onglet « Accueil » : bandeau de bienvenue, le VRAI prochain gala (API), puis le classement.
//
// Nouveau concept : découper un écran en petits widgets privés (_Bandeau, _TitreSection, _CarteRubrique).
// C'est l'équivalent d'extraire des méthodes privées en Java pour garder build() lisible.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/carte_gala.dart';
import 'package:mbappat221_app/ecrans/galas/ecran_fiche_gala.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/services/gala_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key, required this.galaApi});

  final GalaApi galaApi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        // Le logo à la place du titre texte. Image.asset lit une image EMBARQUÉE dans l'application
        // (déclarée dans pubspec.yaml, section assets), comme une ressource de src/main/resources.
        title: Image.asset(
          'assets/images/logo_mbappat221.png',
          height: 46,
          semanticLabel: 'Mbappat 221',   // lu à voix haute par les lecteurs d'écran (accessibilité)
        ),
      ),
      // ListView avec padding : tout le contenu défile si l'écran est trop petit.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Bandeau(),
          const SizedBox(height: 24),
          const _TitreSection('Prochain gala'),
          const SizedBox(height: 8),
          _ProchainGala(galaApi: galaApi),
          const SizedBox(height: 24),
          const _TitreSection('Classement de la saison'),
          const SizedBox(height: 8),
          const _CarteRubrique(
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

/// Le prochain gala annoncé, chargé depuis l'API (le premier de GET /api/galas/a-venir).
/// StatefulWidget : il garde le Future du chargement (comme l'écran Galas).
class _ProchainGala extends StatefulWidget {
  const _ProchainGala({required this.galaApi});

  final GalaApi galaApi;

  @override
  State<_ProchainGala> createState() => _ProchainGalaState();
}

class _ProchainGalaState extends State<_ProchainGala> {
  late Future<PageResultats<Gala>> _chargement;

  @override
  void initState() {
    super.initState();
    // taille: 1 : on ne demande QU'UN gala au serveur (réponse plus légère sur mobile).
    _chargement = widget.galaApi.galasAVenir(taille: 1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PageResultats<Gala>>(
      future: _chargement,
      builder: (context, etat) {
        if (etat.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (etat.hasError) {
          return const _CarteRubrique(
            icone: Icons.wifi_off,
            titre: 'Calendrier indisponible',
            texte: 'Impossible de charger le prochain gala. Vérifie ta connexion.',
          );
        }
        final galas = etat.requireData.contenu;
        if (galas.isEmpty) {
          return const _CarteRubrique(
            icone: Icons.event_busy,
            titre: 'Aucun gala annoncé pour le moment',
            texte: 'Les prochains galas apparaîtront ici dès leur annonce.',
          );
        }
        final gala = galas.first;
        // On réutilise la carte de l'onglet Galas : même rendu, même appui → fiche.
        return CarteGala(
          gala: gala,
          urlAffiche: widget.galaApi.urlFichier(gala.afficheUrl),
          surAppui: () => EcranFicheGala.ouvrir(context, gala: gala, galaApi: widget.galaApi),
        );
      },
    );
  }
}