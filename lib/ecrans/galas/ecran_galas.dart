// Fichier : lib/ecrans/galas/ecran_galas.dart
// Onglet « Galas » : deux sous-onglets, « À venir » (le calendrier) et « Résultats » (les galas terminés).
//
// Concepts déjà vus :
//  - initState()     : appelé UNE fois à la création de l'écran (≈ @PostConstruct).
//  - FutureBuilder   : se redessine selon l'état d'un Future : en cours, erreur, ou données reçues.
//  - RefreshIndicator: « tirer vers le bas pour actualiser ».
//  - ListView.builder: ne construit que les cartes VISIBLES à l'écran (performance, même avec 500 galas).
//
// Nouveaux concepts :
//  - DefaultTabController + TabBar + TabBarView : des onglets en haut de l'écran, qu'on change
//    d'un appui ou en glissant le doigt sur le côté.
//  - AutomaticKeepAliveClientMixin : garde un sous-onglet en mémoire quand on passe à l'autre
//    (sinon il serait recréé, et la liste rechargée depuis le serveur, à chaque aller-retour).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/carte_gala.dart';
import 'package:mbappat221_app/ecrans/galas/ecran_fiche_gala.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/services/gala_api.dart';
import 'package:mbappat221_app/services/lutteur_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class EcranGalas extends StatelessWidget {
  const EcranGalas({super.key, required this.galaApi, required this.lutteurApi});

  /// Les services sont reçus par le constructeur (injection, comme en Spring).
  final GalaApi galaApi;
  final LutteurApi lutteurApi;   // pour ouvrir la fiche d'un finaliste depuis les résultats

  @override
  Widget build(BuildContext context) {
    // DefaultTabController : relie la barre d'onglets (TabBar) et les pages (TabBarView).
    // « length » doit être égal au nombre d'onglets.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Galas', style: TextStyle(fontWeight: FontWeight.w800)),
          // « bottom » : un widget collé sous le titre de la barre, ici les onglets.
          bottom: const TabBar(
            labelColor: Couleurs.noir,
            unselectedLabelColor: Couleurs.grisTexte,
            indicatorColor: Couleurs.or,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            tabs: [Tab(text: 'À venir'), Tab(text: 'Résultats')],
          ),
        ),
        body: TabBarView(
          children: [
            _ListeGalas(
              // « galaApi.galasAVenir » sans parenthèses : on passe la MÉTHODE elle-même,
              // que la liste appellera quand elle voudra (≈ une référence de méthode galaApi::galasAVenir).
              charger: galaApi.galasAVenir,
              galaApi: galaApi,
              lutteurApi: lutteurApi,
              vide: const _MessageVide(
                icone: Icons.event_busy,
                titre: 'Aucun gala annoncé pour le moment',
                texte: 'Reviens bientôt : les prochains galas apparaîtront ici dès leur annonce.',
              ),
            ),
            _ListeGalas(
              charger: galaApi.galasTermines,
              galaApi: galaApi,
              lutteurApi: lutteurApi,
              vide: const _MessageVide(
                icone: Icons.emoji_events_outlined,
                titre: 'Aucun résultat pour le moment',
                texte: 'Les galas apparaîtront ici dès que leurs finales seront saisies.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une liste de galas (à venir ou terminés) : chargement, erreur, liste vide ou cartes.
class _ListeGalas extends StatefulWidget {
  const _ListeGalas({
    required this.charger,
    required this.galaApi,
    required this.lutteurApi,
    required this.vide,
  });

  /// La fonction qui charge la première page : « {int page, int taille} » sont ses paramètres nommés,
  /// facultatifs, que l'on n'utilise pas ici (valeurs par défaut).
  final Future<PageResultats<Gala>> Function({int page, int taille}) charger;
  final GalaApi galaApi;
  final LutteurApi lutteurApi;
  final Widget vide;   // ce qu'on affiche quand la liste est vide

  @override
  State<_ListeGalas> createState() => _ListeGalasState();
}

// « with » : ajoute un « mixin », un morceau de classe réutilisable (≈ une interface Java
// avec des méthodes par défaut). Ici il demande à Flutter de garder cet onglet en vie.
class _ListeGalasState extends State<_ListeGalas> with AutomaticKeepAliveClientMixin {
  /// « late » : la variable sera initialisée plus tard (dans initState), mais avant toute lecture.
  late Future<PageResultats<Gala>> _chargement;

  @override
  bool get wantKeepAlive => true;   // exigé par le mixin : oui, garder l'onglet

  @override
  void initState() {
    super.initState();
    _chargement = widget.charger();
  }

  /// Relance le chargement (bouton « Réessayer » ou geste « tirer vers le bas »).
  Future<void> _recharger() async {
    final nouveauChargement = widget.charger();
    setState(() => _chargement = nouveauChargement);
    try {
      await nouveauChargement;   // le geste « tirer » attend la fin du chargement
    } catch (_) {
      // Rien à faire ici : le FutureBuilder affiche déjà le message d'erreur.
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);   // obligatoire avec AutomaticKeepAliveClientMixin
    // FutureBuilder<T> : « builder » est rappelé à chaque changement d'état du Future.
    return FutureBuilder<PageResultats<Gala>>(
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
          child: galas.isEmpty ? _ListeVide(enfant: widget.vide) : _cartes(galas),
        );
      },
    );
  }

  Widget _cartes(List<Gala> galas) {
    // ListView.separated : comme ListView.builder, avec un espace entre deux cartes.
    // itemBuilder est appelé seulement pour les cartes qui apparaissent à l'écran.
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),   // le geste « tirer » marche même avec 1 seul gala
      itemCount: galas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final gala = galas[index];
        return CarteGala(
          gala: gala,
          urlAffiche: widget.galaApi.urlFichier(gala.afficheUrl),
          // Un appui sur la carte ouvre la fiche du gala (nouvel écran par-dessus la liste).
          surAppui: () => EcranFicheGala.ouvrir(context,
              gala: gala, galaApi: widget.galaApi, lutteurApi: widget.lutteurApi),
        );
      },
    );
  }
}

/// Un ListView (et pas un simple Center) pour que le geste « tirer vers le bas » fonctionne.
class _ListeVide extends StatelessWidget {
  const _ListeVide({required this.enfant});

  final Widget enfant;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [const SizedBox(height: 80), enfant],
    );
  }
}

class _MessageVide extends StatelessWidget {
  const _MessageVide({required this.icone, required this.titre, required this.texte});

  final IconData icone;
  final String titre;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, size: 56, color: Couleurs.orTexte),
        const SizedBox(height: 16),
        Text(titre,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(texte, textAlign: TextAlign.center, style: const TextStyle(color: Couleurs.grisTexte)),
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