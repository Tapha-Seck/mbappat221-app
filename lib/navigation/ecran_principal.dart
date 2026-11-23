// Fichier : lib/navigation/ecran_principal.dart
// L'écran « coquille » : la barre de 5 onglets en bas, et l'écran de l'onglet actif au-dessus.
//
// C'est un StatefulWidget car il retient une donnée qui change : l'onglet sélectionné.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/accueil/ecran_accueil.dart';
import 'package:mbappat221_app/ecrans/classement/ecran_classement.dart';
import 'package:mbappat221_app/ecrans/galas/ecran_galas.dart';
import 'package:mbappat221_app/ecrans/lutteurs/ecran_lutteurs.dart';
import 'package:mbappat221_app/ecrans/plus/ecran_plus.dart';
import 'package:mbappat221_app/ecrans/recherche/ecran_recherche.dart';
import 'package:mbappat221_app/services/services_api.dart';

class EcranPrincipal extends StatefulWidget {
  const EcranPrincipal({super.key, required this.services});

  /// Tous les services, transmis aux onglets qui en ont besoin (injection par constructeur).
  final ServicesApi services;

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  int _ongletActif = 0;   // 0 = Accueil, 1 = Galas, 2 = Lutteurs, 3 = Classement, 4 = Plus

  /// Les 5 écrans, dans l'ordre des onglets.
  /// « late final » : la liste est créée au premier accès (quand « widget » est disponible),
  /// puis gardée : les écrans ne sont pas recréés à chaque changement d'onglet.
  late final List<Widget> _ecrans = [
    EcranAccueil(
      galaApi: widget.services.galas,
      classementApi: widget.services.classements,
      lutteurApi: widget.services.lutteurs,
      // La loupe ouvre la recherche générale, qui reçoit TOUS les services.
      surRecherche: () => EcranRecherche.ouvrir(context, widget.services),
    ),
    EcranGalas(galaApi: widget.services.galas, lutteurApi: widget.services.lutteurs),
    EcranLutteurs(lutteurApi: widget.services.lutteurs, referentielApi: widget.services.referentiel),
    EcranClassement(
      classementApi: widget.services.classements,
      referentielApi: widget.services.referentiel,
      lutteurApi: widget.services.lutteurs,
    ),
    EcranPlus(animateurApi: widget.services.animateurs),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack empile les 5 écrans et n'affiche que celui de l'index donné.
      // Avantage : chaque onglet garde son état (liste déjà chargée, position de défilement...)
      // quand on change d'onglet. Un simple « _ecrans[_ongletActif] » le perdrait.
      body: IndexedStack(index: _ongletActif, children: _ecrans),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _ongletActif,
        // Fonction anonyme (lambda) : (index) => ...  ≈  index -> ... en Java.
        // setState prévient Flutter de redessiner avec le nouvel onglet.
        onDestinationSelected: (index) => setState(() => _ongletActif = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),        // icône quand l'onglet est inactif
            selectedIcon: Icon(Icons.home),         // icône pleine quand il est actif
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Galas',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_kabaddi_outlined),
            selectedIcon: Icon(Icons.sports_kabaddi),
            label: 'Lutteurs',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Classement',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Plus',
          ),
        ],
      ),
    );
  }
}