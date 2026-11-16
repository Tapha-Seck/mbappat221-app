// Fichier : lib/ecrans/lutteurs/ecran_lutteurs.dart
// Onglet « Lutteurs » : recherche (nom, surnom ou écurie), filtre par catégorie,
// et liste qui se charge page par page en descendant (« défilement infini »).
//
// Nouveaux concepts :
//  - TextEditingController : lit et modifie le texte d'un champ (≈ la valeur d'un <input>).
//  - ScrollController      : suit la position de défilement (pour charger la page suivante).
//  - Timer                 : attendre 400 ms après la dernière lettre tapée avant de chercher
//                            (« debounce ») : une requête par mot, pas une par lettre.
//  - dispose()             : libère les ressources quand l'écran disparaît (≈ @PreDestroy).
//  - mounted               : l'écran est-il toujours affiché ? (après un await, il a pu être fermé)

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/lutteurs/ecran_fiche_lutteur.dart';
import 'package:mbappat221_app/modeles/categorie.dart';
import 'package:mbappat221_app/modeles/lutteur.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/lutteur_api.dart';
import 'package:mbappat221_app/services/referentiel_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';
import 'package:mbappat221_app/widgets/avatar_photo.dart';
import 'package:mbappat221_app/widgets/filtres_categories.dart';

class EcranLutteurs extends StatefulWidget {
  const EcranLutteurs({super.key, required this.lutteurApi, required this.referentielApi});

  final LutteurApi lutteurApi;
  final ReferentielApi referentielApi;

  @override
  State<EcranLutteurs> createState() => _EcranLutteursState();
}

class _EcranLutteursState extends State<EcranLutteurs> {
  static const _taillePage = 20;

  final _champRecherche = TextEditingController();
  final _defilement = ScrollController();
  Timer? _minuterie;

  List<Categorie> _categories = const [];
  int? _categorieId;   // null = toutes les catégories

  final List<LutteurListe> _lutteurs = [];
  int _total = 0;
  int _pageSuivante = 0;
  bool _dernierePage = false;
  bool _enChargement = false;
  String? _erreur;

  /// Numéro de la recherche en cours. Si on tape « Fa » puis « Fass », la réponse pour « Fa »
  /// peut arriver APRÈS celle de « Fass » : grâce à ce numéro, on ignore la réponse dépassée.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _defilement.addListener(_surDefilement);
    _chargerCategories();
    _recommencer();
  }

  @override
  void dispose() {
    _minuterie?.cancel();          // « ?. » : seulement si une minuterie existe
    _champRecherche.dispose();
    _defilement.dispose();
    super.dispose();
  }

  String get _texte => _champRecherche.text.trim();

  Future<void> _chargerCategories() async {
    try {
      final categories = await widget.referentielApi.categories();
      if (!mounted) {
        return;
      }
      setState(() => _categories = categories);
    } on ApiException {
      // Sans catégories, pas de filtres : la recherche reste utilisable.
    }
  }

  /// Appelé à chaque lettre tapée : on relance la minuterie de 400 ms.
  void _surSaisie(String texte) {
    _minuterie?.cancel();
    _minuterie = Timer(const Duration(milliseconds: 400), () {
      if (_texte.length != 1) {   // une seule lettre : trop vague, on attend la suivante
        _recommencer();
      }
    });
    setState(() {});   // pour afficher ou masquer la croix « effacer »
  }

  void _effacer() {
    _champRecherche.clear();
    _minuterie?.cancel();
    _recommencer();
  }

  void _choisirCategorie(int? categorieId) {
    if (categorieId == _categorieId) {
      return;
    }
    setState(() => _categorieId = categorieId);
    _recommencer();
  }

  /// À 300 px de la fin de la liste, on charge la page suivante.
  void _surDefilement() {
    final position = _defilement.position;
    if (position.pixels > position.maxScrollExtent - 300) {
      _chargerSuite();
    }
  }

  /// Nouvelle recherche : on vide la liste et on charge la première page.
  Future<void> _recommencer() {
    _generation++;
    setState(() {
      _lutteurs.clear();
      _total = 0;
      _pageSuivante = 0;
      _dernierePage = false;
      _enChargement = false;
      _erreur = null;
    });
    return _chargerSuite();
  }

  Future<void> _chargerSuite() async {
    if (_enChargement || _dernierePage) {
      return;
    }
    final generation = _generation;
    setState(() {
      _enChargement = true;
      _erreur = null;
    });
    try {
      final page = await widget.lutteurApi.rechercher(
        recherche: _texte,
        categorieId: _categorieId,
        page: _pageSuivante,
        taille: _taillePage,
      );
      if (!mounted || generation != _generation) {
        return;   // l'écran est fermé, ou une autre recherche a commencé : réponse ignorée
      }
      setState(() {
        _lutteurs.addAll(page.contenu);
        _total = page.totalElements;
        _pageSuivante = page.page + 1;
        _dernierePage = page.estLaDerniere;
      });
    } on ApiException catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _erreur = e.message);
      }
    } finally {
      // finally : exécuté dans tous les cas, comme en Java.
      if (mounted && generation == _generation) {
        setState(() => _enChargement = false);
      }
    }
  }

  void _ouvrirFiche(LutteurListe lutteur) {
    EcranFicheLutteur.ouvrir(context, lutteurId: lutteur.id, titre: lutteur.nomAffiche,
        lutteurApi: widget.lutteurApi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lutteurs', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _ChampRecherche(
              controleur: _champRecherche,
              surSaisie: _surSaisie,
              surEffacer: _effacer,
            ),
          ),
          if (_categories.isNotEmpty)
            FiltresCategories(
              categories: _categories,
              categorieId: _categorieId,
              surChoix: _choisirCategorie,
              libelleToutes: 'Toutes',
            ),
          // Expanded : la liste prend toute la hauteur qui reste sous la recherche et les filtres.
          Expanded(child: _contenu()),
        ],
      ),
    );
  }

  Widget _contenu() {
    if (_lutteurs.isEmpty) {
      if (_enChargement) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_erreur != null) {
        return _Message(
          icone: Icons.wifi_off,
          titre: _erreur!,
          action: FilledButton.icon(
            onPressed: _recommencer,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        );
      }
      return const _Message(
        icone: Icons.person_search,
        titre: 'Aucun lutteur trouvé',
        texte: 'Essaie un autre nom, un surnom ou le nom d\'une écurie.',
      );
    }

    // 1 ligne de titre (le nombre de résultats) + les lutteurs + 1 ligne de bas de liste.
    return RefreshIndicator(
      onRefresh: _recommencer,
      color: Couleurs.noir,
      child: ListView.builder(
        controller: _defilement,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _lutteurs.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _total == 1 ? '1 lutteur' : '$_total lutteurs',
                style: const TextStyle(color: Couleurs.grisTexte, fontWeight: FontWeight.w600),
              ),
            );
          }
          if (index == _lutteurs.length + 1) {
            return _BasDeListe(
              enChargement: _enChargement,
              erreur: _erreur,
              surReessayer: _chargerSuite,
            );
          }
          final lutteur = _lutteurs[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LigneLutteur(
              lutteur: lutteur,
              urlPhoto: widget.lutteurApi.urlFichier(lutteur.photoUrl),
              surAppui: () => _ouvrirFiche(lutteur),
            ),
          );
        },
      ),
    );
  }
}

class _ChampRecherche extends StatelessWidget {
  const _ChampRecherche({required this.controleur, required this.surSaisie, required this.surEffacer});

  final TextEditingController controleur;
  final ValueChanged<String> surSaisie;   // ValueChanged<String> = fonction (String) → void (≈ Consumer<String>)
  final VoidCallback surEffacer;

  @override
  Widget build(BuildContext context) {
    final bordure = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: Couleurs.bordure),
    );
    return TextField(
      controller: controleur,
      onChanged: surSaisie,
      textInputAction: TextInputAction.search,   // touche « Rechercher » sur le clavier du téléphone
      decoration: InputDecoration(
        hintText: 'Nom, surnom ou écurie',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controleur.text.isEmpty
            ? null
            : IconButton(tooltip: 'Effacer', icon: const Icon(Icons.close), onPressed: surEffacer),
        filled: true,
        fillColor: Couleurs.blanc,
        contentPadding: EdgeInsets.zero,
        border: bordure,
        enabledBorder: bordure,
        focusedBorder: bordure.copyWith(borderSide: const BorderSide(color: Couleurs.noir, width: 1.5)),
      ),
    );
  }
}

class _LigneLutteur extends StatelessWidget {
  const _LigneLutteur({required this.lutteur, required this.surAppui, this.urlPhoto});

  final LutteurListe lutteur;
  final String? urlPhoto;
  final VoidCallback surAppui;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Couleurs.blanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Couleurs.bordure),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: surAppui,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AvatarPhoto(nom: lutteur.nomAffiche, url: urlPhoto, rayon: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lutteur.nomAffiche,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    // Le vrai nom en petit, seulement si le lutteur a un surnom.
                    if (lutteur.surnom != null)
                      Text(lutteur.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: Couleurs.grisTexte)),
                    const SizedBox(height: 2),
                    Text(lutteur.categorieEtEcurie,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Couleurs.orTexte, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Couleurs.grisTexte),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sous le dernier lutteur : roue pendant le chargement de la page suivante, ou bouton Réessayer.
class _BasDeListe extends StatelessWidget {
  const _BasDeListe({required this.enChargement, required this.surReessayer, this.erreur});

  final bool enChargement;
  final String? erreur;
  final Future<void> Function() surReessayer;

  @override
  Widget build(BuildContext context) {
    if (enChargement) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (erreur != null) {
      return Center(
        child: TextButton.icon(
          onPressed: surReessayer,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      );
    }
    return const SizedBox(height: 8);
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icone, required this.titre, this.texte, this.action});

  final IconData icone;
  final String titre;
  final String? texte;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
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
              Text(texte!, textAlign: TextAlign.center, style: const TextStyle(color: Couleurs.grisTexte)),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}