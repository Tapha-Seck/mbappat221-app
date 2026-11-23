// Fichier : lib/ecrans/recherche/ecran_recherche.dart
// La recherche générale, ouverte par la loupe de l'accueil : on tape un nom, et on trouve
// en une fois les lutteurs, les galas et les animateurs (cantatrices, griots, Tv Tv).
//
// Mêmes techniques que l'onglet « Lutteurs » :
//  - Timer      : on attend 350 ms après la dernière lettre avant d'interroger le serveur ;
//  - _generation : seule la réponse de la DERNIÈRE recherche est affichée (une réponse lente
//                  d'une recherche précédente est ignorée).
//
// Nouveau concept :
//  - TextField dans l'AppBar, avec autofocus : le clavier s'ouvre tout de suite.
//  - « switch » sur des conditions pour choisir l'état à afficher (accueil, chargement, erreur...).

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/ecran_fiche_gala.dart';
import 'package:mbappat221_app/ecrans/lutteurs/ecran_fiche_lutteur.dart';
import 'package:mbappat221_app/ecrans/plus/ecran_profil_animateur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/lutteur.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/modeles/recherche.dart';
import 'package:mbappat221_app/outils/dates_fr.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/services_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';
import 'package:mbappat221_app/widgets/avatar_photo.dart';

class EcranRecherche extends StatefulWidget {
  const EcranRecherche({super.key, required this.services});

  /// Tous les services : la recherche, et ceux qui ouvrent les fiches (gala, lutteur, animateur).
  final ServicesApi services;

  static Future<void> ouvrir(BuildContext context, ServicesApi services) {
    return Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => EcranRecherche(services: services),
    ));
  }

  @override
  State<EcranRecherche> createState() => _EcranRechercheState();
}

class _EcranRechercheState extends State<EcranRecherche> {
  final _champ = TextEditingController();
  Timer? _minuterie;
  int _generation = 0;

  ResultatRecherche? _resultat;
  bool _enChargement = false;
  String? _erreur;

  String get _texte => _champ.text.trim();

  @override
  void dispose() {
    _minuterie?.cancel();   // sinon la minuterie pourrait se déclencher sur un écran fermé
    _champ.dispose();
    super.dispose();
  }

  /// À chaque lettre : on relance la minuterie. Moins de 2 lettres : on revient à l'écran d'accueil.
  void _surSaisie(String _) {
    _minuterie?.cancel();
    if (_texte.length < 2) {
      _generation++;   // une réponse encore en route sera ignorée
      setState(() {
        _resultat = null;
        _erreur = null;
        _enChargement = false;
      });
      return;
    }
    _minuterie = Timer(const Duration(milliseconds: 350), _rechercher);
    setState(() {});   // pour afficher la croix « effacer »
  }

  /// Touche « Rechercher » du clavier : on n'attend pas la fin de la minuterie.
  void _surValidation(String _) {
    _minuterie?.cancel();
    if (_texte.length >= 2) {
      _rechercher();
    }
  }

  void _effacer() {
    _champ.clear();
    _surSaisie('');
  }

  Future<void> _rechercher() async {
    final generation = ++_generation;   // « ++x » : incrémente PUIS renvoie la nouvelle valeur (comme en Java)
    setState(() {
      _enChargement = true;
      _erreur = null;
    });
    try {
      final resultat = await widget.services.recherche.rechercher(_texte);
      if (!mounted || generation != _generation) {
        return;   // écran fermé, ou l'utilisateur a continué à taper : réponse périmée
      }
      setState(() {
        _resultat = resultat;
        _enChargement = false;
      });
    } on ApiException catch (e) {
      if (mounted && generation == _generation) {
        setState(() {
          _erreur = e.message;
          _enChargement = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        titleSpacing: 0,   // le champ commence juste après la flèche de retour
        title: TextField(
          controller: _champ,
          autofocus: true,   // le clavier s'ouvre dès l'arrivée sur l'écran
          onChanged: _surSaisie,
          onSubmitted: _surValidation,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Lutteur, écurie, gala, animateur…',
            border: InputBorder.none,   // pas de cadre : le champ se fond dans la barre
          ),
        ),
        actions: [
          if (_champ.text.isNotEmpty)
            IconButton(tooltip: 'Effacer', icon: const Icon(Icons.close), onPressed: _effacer),
        ],
      ),
      body: _corps(),
    );
  }

  /// Choisit ce qu'on affiche selon l'état de la recherche.
  Widget _corps() {
    final resultat = _resultat;
    final erreur = _erreur;

    if (_enChargement && resultat == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (erreur != null) {
      return _Message(
        icone: Icons.wifi_off,
        titre: 'Recherche impossible',
        texte: erreur,
        action: FilledButton.icon(
          onPressed: _rechercher,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      );
    }
    if (resultat == null) {
      return const _Message(
        icone: Icons.search,
        titre: 'Rechercher dans Mbappat 221',
        texte: 'Un lutteur, une écurie, un gala, un lieu, une cantatrice, un griot ou une Tv Tv.',
      );
    }
    if (resultat.estVide) {
      return _Message(
        icone: Icons.search_off,
        titre: 'Aucun résultat pour « ${resultat.texte} »',
        texte: 'Vérifiez l\'orthographe ou essayez un autre nom.',
      );
    }

    final services = widget.services;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // « ...[ ] » (spread) : insère tous les éléments de la liste ici, à plat.
            // Une rubrique vide n'est pas affichée du tout.
            if (resultat.lutteurs.contenu.isNotEmpty) ...[
              _TitreRubrique(titre: 'Lutteurs', page: resultat.lutteurs),
              for (final lutteur in resultat.lutteurs.contenu)
                _Ligne(
                  image: AvatarPhoto(
                      nom: lutteur.nomAffiche, url: services.lutteurs.urlFichier(lutteur.photoUrl), rayon: 22),
                  titre: lutteur.nomAffiche,
                  sousTitre: _sousTitreLutteur(lutteur),
                  surAppui: () => EcranFicheLutteur.ouvrir(context,
                      lutteurId: lutteur.id, titre: lutteur.nomAffiche, lutteurApi: services.lutteurs),
                ),
            ],
            if (resultat.galas.contenu.isNotEmpty) ...[
              _TitreRubrique(titre: 'Galas', page: resultat.galas),
              for (final gala in resultat.galas.contenu)
                _Ligne(
                  image: _DateGala(gala: gala),
                  titre: gala.nom,
                  sousTitre: _sousTitreGala(gala),
                  surAppui: () => EcranFicheGala.ouvrir(context, gala: gala, galaApi: services.galas),
                ),
            ],
            if (resultat.animateurs.contenu.isNotEmpty) ...[
              _TitreRubrique(titre: 'Animateurs et Tv Tv', page: resultat.animateurs),
              for (final animateur in resultat.animateurs.contenu)
                _Ligne(
                  image: AvatarPhoto(
                      nom: animateur.nomAffiche,
                      url: services.animateurs.urlFichier(animateur.photoUrl),
                      rayon: 22),
                  titre: animateur.nomAffiche,
                  sousTitre: animateur.roleEtRegion,
                  icone: iconeRole(animateur.role),
                  surAppui: () => EcranProfilAnimateur.ouvrir(context,
                      animateurId: animateur.id,
                      titre: animateur.nomAffiche,
                      animateurApi: services.animateurs),
                ),
            ],
          ],
        ),
        // Pendant une nouvelle recherche, on garde les anciens résultats et une fine barre en haut.
        if (_enChargement) const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }

  static String _sousTitreLutteur(LutteurListe lutteur) {
    // Le vrai nom d'abord si le lutteur est connu sous un surnom.
    final debut = lutteur.surnom == null ? '' : '${lutteur.nom} · ';
    return '$debut${lutteur.categorieEtEcurie}';
  }

  static String _sousTitreGala(Gala gala) {
    final lieu = '${gala.lieu} · ${gala.region}';
    // switch « expression » : renvoie une valeur (≈ le switch avec -> de Java 21).
    return switch (gala.statut) {
      StatutGala.annule => 'Annulé · $lieu',
      StatutGala.termine => 'Terminé · $lieu',
      _ => lieu,   // « _ » : tous les autres cas (≈ default)
    };
  }
}

/// « Lutteurs » à gauche, et « 5 sur 23 » à droite s'il y a plus de résultats que ceux affichés.
class _TitreRubrique extends StatelessWidget {
  const _TitreRubrique({required this.titre, required this.page});

  final String titre;
  final PageResultats<Object> page;   // Object : le titre n'a pas besoin de connaître le type des éléments

  @override
  Widget build(BuildContext context) {
    final affiches = page.contenu.length;
    final total = page.totalElements;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(titre.toUpperCase(),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Couleurs.orTexte)),
          ),
          Text(total > affiches ? '$affiches sur $total' : '$total',
              style: const TextStyle(fontSize: 12, color: Couleurs.grisTexte)),
        ],
      ),
    );
  }
}

/// Une ligne de résultat : image à gauche, titre et sous-titre, flèche à droite.
class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.image,
    required this.titre,
    required this.sousTitre,
    required this.surAppui,
    this.icone,
  });

  final Widget image;
  final String titre;
  final String sousTitre;
  final VoidCallback surAppui;
  final IconData? icone;   // petite icône avant le sous-titre (rôle de l'animateur)

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Couleurs.blanc,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Couleurs.bordure),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: surAppui,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                image,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (icone != null) ...[
                            Icon(icone, size: 14, color: Couleurs.orTexte),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(sousTitre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: Couleurs.grisTexte)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Couleurs.grisTexte),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Le petit carré date d'un gala (« 21 / nov. »), noir et or comme sur les cartes du calendrier.
class _DateGala extends StatelessWidget {
  const _DateGala({required this.gala});

  final Gala gala;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: gala.estAnnule ? Couleurs.rouge : Couleurs.noir,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${gala.dateDebut.day}',
              style: const TextStyle(
                  color: Couleurs.or, fontSize: 17, fontWeight: FontWeight.w900, height: 1.1)),
          Text(DatesFr.moisCourt(gala.dateDebut),
              style: const TextStyle(color: Couleurs.blanc, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Un message centré : icône, titre, texte et éventuellement un bouton.
class _Message extends StatelessWidget {
  const _Message({required this.icone, required this.titre, this.texte, this.action});

  final IconData icone;
  final String titre;
  final String? texte;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final texte = this.texte;
    final action = this.action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Couleurs.orTexte),
            const SizedBox(height: 16),
            Text(titre,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (texte != null) ...[
              const SizedBox(height: 8),
              Text(texte, textAlign: TextAlign.center, style: const TextStyle(color: Couleurs.grisTexte)),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
