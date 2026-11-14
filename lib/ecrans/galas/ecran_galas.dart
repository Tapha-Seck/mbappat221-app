// Fichier : lib/ecrans/galas/ecran_galas.dart
// Onglet « Galas » : la liste des galas à venir, chargée depuis l'API Spring Boot.
//
// Nouveaux concepts :
//  - initState()     : appelé UNE fois à la création de l'écran (≈ @PostConstruct).
//  - FutureBuilder   : se redessine selon l'état d'un Future : en cours, erreur, ou données reçues.
//  - RefreshIndicator: « tirer vers le bas pour actualiser ».
//  - ListView.builder: ne construit que les cartes VISIBLES à l'écran (performance, même avec 500 galas).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/carte_gala.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/services/gala_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class EcranGalas extends StatefulWidget {
  const EcranGalas({super.key, required this.galaApi});

  /// Le service est reçu par le constructeur (injection, comme en Spring).
  final GalaApi galaApi;

  @override
  State<EcranGalas> createState() => _EcranGalasState();
}

class _EcranGalasState extends State<EcranGalas> {
  /// « late » : la variable sera initialisée plus tard (dans initState), mais avant toute lecture.
  late Future<PageResultats<Gala>> _chargement;

  @override
  void initState() {
    super.initState();
    // « widget » donne accès aux paramètres du StatefulWidget (ici galaApi).
    _chargement = widget.galaApi.galasAVenir();
  }

  /// Relance le chargement (bouton « Réessayer », bouton actualiser, ou geste « tirer vers le bas »).
  Future<void> _recharger() async {
    final nouveauChargement = widget.galaApi.galasAVenir();
    setState(() => _chargement = nouveauChargement);
    try {
      await nouveauChargement;   // le geste « tirer » attend la fin du chargement
    } catch (_) {
      // Rien à faire ici : le FutureBuilder affiche déjà le message d'erreur.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galas à venir', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
            onPressed: _recharger,
          ),
        ],
      ),
      // FutureBuilder<T> : « builder » est rappelé à chaque changement d'état du Future.
      body: FutureBuilder<PageResultats<Gala>>(
        future: _chargement,
        builder: (context, etat) {
          // 1. Chargement en cours → une roue qui tourne.
          if (etat.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Erreur (serveur arrêté, pas de réseau...) → message + bouton Réessayer.
          if (etat.hasError) {
            return _MessageErreur(message: '${etat.error}', surReessayer: _recharger);
          }
          // 3. Données reçues.
          final galas = etat.requireData.contenu;
          return RefreshIndicator(
            onRefresh: _recharger,
            color: Couleurs.noir,
            child: galas.isEmpty ? const _AucunGala() : _ListeGalas(galas: galas, galaApi: widget.galaApi),
          );
        },
      ),
    );
  }
}

class _ListeGalas extends StatelessWidget {
  const _ListeGalas({required this.galas, required this.galaApi});

  final List<Gala> galas;
  final GalaApi galaApi;

  @override
  Widget build(BuildContext context) {
    // ListView.separated : comme ListView.builder, avec un espace entre deux cartes.
    // itemBuilder est appelé seulement pour les cartes qui apparaissent à l'écran.
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),   // le geste « tirer » marche même avec 1 seul gala
      itemCount: galas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final gala = galas[index];
        return CarteGala(gala: gala, urlAffiche: galaApi.urlFichier(gala.afficheUrl));
      },
    );
  }
}

class _AucunGala extends StatelessWidget {
  const _AucunGala();

  @override
  Widget build(BuildContext context) {
    // Un ListView (et pas un simple Center) pour que le geste « tirer vers le bas » fonctionne.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: const [
        SizedBox(height: 80),
        Icon(Icons.event_busy, size: 56, color: Couleurs.orTexte),
        SizedBox(height: 16),
        Text('Aucun gala annoncé pour le moment',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        SizedBox(height: 8),
        Text('Reviens bientôt : les prochains galas apparaîtront ici dès leur annonce.',
            textAlign: TextAlign.center, style: TextStyle(color: Couleurs.grisTexte)),
      ],
    );
  }
}

class _MessageErreur extends StatelessWidget {
  const _MessageErreur({required this.message, required this.surReessayer});

  final String message;
  /// Un champ qui contient une FONCTION : celle à appeler au clic (≈ un Runnable en Java).
  /// « Future<void> Function() » : une fonction sans paramètre qui renvoie un Future (async).
  final Future<void> Function() surReessayer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 56, color: Couleurs.rouge),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: surReessayer,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}