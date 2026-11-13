// Fichier : lib/ecrans/plus/ecran_plus.dart
// Onglet « Plus » : les rubriques secondaires (animateurs, à propos, contact).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/theme/couleurs.dart';

class EcranPlus extends StatelessWidget {
  const EcranPlus({super.key});

  /// Affiche un petit message en bas de l'écran (un « SnackBar »).
  /// ScaffoldMessenger.of(context) retrouve le gestionnaire de messages de l'écran courant.
  void _bientot(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cette rubrique arrive bientôt.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plus', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      // ListView : une liste qui défile (comme un <ul> dans une page web).
      body: ListView(
        children: [
          // ListTile : une ligne toute prête avec icône à gauche, titre, sous-titre et flèche à droite.
          ListTile(
            leading: const Icon(Icons.mic_none, color: Couleurs.orTexte),
            title: const Text('Cantatrices et griots'),
            subtitle: const Text('Les animateurs des galas'),
            trailing: const Icon(Icons.chevron_right),
            // () => _bientot(context) : une lambda sans paramètre, comme () -> bientot(context) en Java.
            onTap: () => _bientot(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Couleurs.orTexte),
            title: const Text('À propos de Mbappat 221'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _bientot(context),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline, color: Couleurs.orTexte),
            title: const Text('Nous contacter'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _bientot(context),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Mbappat 221 · par Sérère Réfoum',
              textAlign: TextAlign.center,
              style: TextStyle(color: Couleurs.grisTexte, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}