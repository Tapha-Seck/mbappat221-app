// Fichier : lib/ecrans/plus/ecran_a_propos.dart
// « À propos de Mbappat 221 » : présentation, à qui elle s'adresse, ce qui arrive bientôt, version.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/elements_gala.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class EcranAPropos extends StatelessWidget {
  const EcranAPropos({super.key});

  /// À garder identique à la « version » de pubspec.yaml (sans le « +1 »).
  static const version = '1.0.0';

  static Future<void> ouvrir(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const EcranAPropos()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Le logo est un PNG transparent : il se pose directement sur le fond crème.
          Center(child: Image.asset('assets/images/logo_mbappat221.png', height: 120)),
          const SizedBox(height: 16),
          const Text('La lutte simple sénégalaise',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const Text('par Sérère Réfoum',
              textAlign: TextAlign.center,
              style: TextStyle(color: Couleurs.orTexte, fontWeight: FontWeight.w700)),
          const TitreSection('L\'application'),
          const Text(
            'Mbappat 221 rassemble toute la saison de lutte simple : le calendrier des galas '
                'avec leurs affiches, les lutteurs et leurs écuries, les résultats des finales, '
                'le classement de chaque catégorie et les cantatrices et griots qui animent les arènes.',
            style: TextStyle(height: 1.5),
          ),
          const TitreSection('Pour qui ?'),
          const _Public(
            icone: Icons.groups_outlined,
            titre: 'Les amateurs',
            texte: 'Suivre les galas, les résultats et le classement de leurs lutteurs préférés.',
          ),
          const _Public(
            icone: Icons.sports_kabaddi,
            titre: 'Les lutteurs',
            texte: 'Une fiche avec leurs photos, leur palmarès et leurs points de la saison.',
          ),
          const _Public(
            icone: Icons.campaign_outlined,
            titre: 'Les promoteurs',
            texte: 'Faire connaître leurs galas avec l\'affiche, les catégories, la mise et l\'animation.',
          ),
          const TitreSection('Le classement'),
          const Text(
            'Les points sont attribués à chaque finale selon le barème officiel de la saison. '
                'Le classement se met à jour dès qu\'un résultat est enregistré.',
            style: TextStyle(height: 1.5),
          ),
          const TitreSection('Bientôt'),
          const _Public(
            icone: Icons.confirmation_number_outlined,
            titre: 'La billetterie',
            texte: 'Acheter sa place pour un gala directement depuis l\'application.',
          ),
          const _Public(
            icone: Icons.live_tv_outlined,
            titre: 'Les galas en pay-per-view',
            texte: 'Regarder les galas en direct, au Sénégal comme à l\'étranger.',
          ),
          const SizedBox(height: 32),
          const Text('Version $version',
              textAlign: TextAlign.center, style: TextStyle(color: Couleurs.grisTexte)),
        ],
      ),
    );
  }
}

/// Une ligne « icône dorée + titre + texte » (publics de l'application, nouveautés à venir).
class _Public extends StatelessWidget {
  const _Public({required this.icone, required this.titre, required this.texte});

  final IconData icone;
  final String titre;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Couleurs.or, borderRadius: BorderRadius.circular(10)),
            child: Icon(icone, color: Couleurs.noir, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(texte, style: const TextStyle(color: Couleurs.grisTexte, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}