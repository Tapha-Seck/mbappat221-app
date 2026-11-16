// Fichier : lib/ecrans/classement/ecran_classement.dart
// Onglet « Classement » : le classement de la saison, catégorie par catégorie,
// avec un podium pour les 3 premiers. Un appui sur un lutteur ouvre sa fiche.
//
// Nouveaux concepts :
//  - Map<int, Future<...>> : un cache des classements déjà demandés. Revenir sur une catégorie
//    déjà vue ne refait pas d'appel réseau (≈ Map.computeIfAbsent en Java → putIfAbsent en Dart).
//  - crossAxisAlignment: end : aligner des colonnes de hauteurs différentes par le BAS (le podium).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/lutteurs/ecran_fiche_lutteur.dart';
import 'package:mbappat221_app/modeles/categorie.dart';
import 'package:mbappat221_app/modeles/classement.dart';
import 'package:mbappat221_app/outils/montants_fr.dart';
import 'package:mbappat221_app/services/classement_api.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/lutteur_api.dart';
import 'package:mbappat221_app/services/referentiel_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';
import 'package:mbappat221_app/widgets/filtres_categories.dart';

class EcranClassement extends StatefulWidget {
  const EcranClassement({
    super.key,
    required this.classementApi,
    required this.referentielApi,
    required this.lutteurApi,
  });

  final ClassementApi classementApi;
  final ReferentielApi referentielApi;
  final LutteurApi lutteurApi;   // pour ouvrir la fiche d'un lutteur

  @override
  State<EcranClassement> createState() => _EcranClassementState();
}

class _EcranClassementState extends State<EcranClassement> {
  late Future<List<Categorie>> _chargementCategories;
  int? _categorieId;

  /// Un classement par catégorie, demandé une seule fois.
  final Map<int, Future<Classement>> _classements = {};

  @override
  void initState() {
    super.initState();
    _chargementCategories = _chargerCategories();
  }

  /// Charge les catégories, puis sélectionne la première (ordre officiel).
  Future<List<Categorie>> _chargerCategories() async {
    final categories = await widget.referentielApi.categories();
    if (mounted && categories.isNotEmpty && _categorieId == null) {
      setState(() => _categorieId = categories.first.id);
    }
    return categories;
  }

  /// Le classement d'une catégorie : depuis le cache, sinon depuis le serveur.
  Future<Classement> _classementDe(int categorieId) =>
      _classements.putIfAbsent(categorieId, () => widget.classementApi.classement(categorieId));

  /// Bouton actualiser : on oublie tout et on recommence (nouvelles finales saisies...).
  void _actualiser() {
    setState(() {
      _classements.clear();
      _chargementCategories = _chargerCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(tooltip: 'Actualiser', icon: const Icon(Icons.refresh), onPressed: _actualiser),
        ],
      ),
      body: FutureBuilder<List<Categorie>>(
        future: _chargementCategories,
        builder: (context, etat) {
          if (etat.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (etat.hasError) {
            return _Message(
              icone: Icons.wifi_off,
              titre: '${etat.error}',
              action: FilledButton.icon(
                onPressed: _actualiser,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            );
          }
          final categories = etat.requireData;
          final categorieId = _categorieId;
          if (categories.isEmpty || categorieId == null) {
            return const _Message(icone: Icons.category_outlined, titre: 'Aucune catégorie');
          }
          return Column(
            children: [
              const SizedBox(height: 8),
              FiltresCategories(
                categories: categories,
                categorieId: categorieId,
                // « ?? » : la pastille renvoie un int? ; sans « Toutes », il n'est jamais null.
                surChoix: (id) => setState(() => _categorieId = id ?? categorieId),
              ),
              Expanded(
                child: _ClassementCategorie(
                  // key : quand la catégorie change, Flutter crée un NOUVEAU widget au lieu de
                  // réutiliser l'ancien (sinon le FutureBuilder garderait l'ancien résultat un instant).
                  key: ValueKey(categorieId),
                  chargement: _classementDe(categorieId),
                  surActualiser: _actualiser,
                  surLutteur: (ligne) => EcranFicheLutteur.ouvrir(
                    context,
                    lutteurId: ligne.lutteurId,
                    titre: ligne.nomAffiche,
                    lutteurApi: widget.lutteurApi,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClassementCategorie extends StatelessWidget {
  const _ClassementCategorie({
    super.key,
    required this.chargement,
    required this.surActualiser,
    required this.surLutteur,
  });

  final Future<Classement> chargement;
  final VoidCallback surActualiser;
  final ValueChanged<LigneClassement> surLutteur;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Classement>(
      future: chargement,
      builder: (context, etat) {
        if (etat.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (etat.hasError) {
          final message = etat.error is ApiException ? '${etat.error}' : 'Classement indisponible.';
          return _Message(
            icone: Icons.wifi_off,
            titre: message,
            action: FilledButton.icon(
              onPressed: surActualiser,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          );
        }
        final classement = etat.requireData;
        final lignes = classement.lignes;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('Saison ${classement.saisonLibelle} · ${classement.categorieNom}',
                style: const TextStyle(color: Couleurs.grisTexte, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (lignes.isEmpty)
              const _Message(
                icone: Icons.emoji_events_outlined,
                titre: 'Pas encore de classement',
                texte: 'Il apparaîtra dès la première finale de la saison dans cette catégorie.',
              )
            else ...[
              // take(3) : les 3 premières lignes (≈ stream().limit(3)).
              _Podium(premiers: lignes.take(3).toList(), surLutteur: surLutteur),
              const SizedBox(height: 16),
              // skip(3) : toutes les lignes après les 3 premières (≈ stream().skip(3)).
              for (final ligne in lignes.skip(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LigneRang(ligne: ligne, surAppui: () => surLutteur(ligne)),
                ),
            ],
          ],
        );
      },
    );
  }
}

/// Le podium : 2e à gauche, 1er au centre (plus haut), 3e à droite.
class _Podium extends StatelessWidget {
  const _Podium({required this.premiers, required this.surLutteur});

  final List<LigneClassement> premiers;   // 1 à 3 lignes
  final ValueChanged<LigneClassement> surLutteur;

  static const _argent = Color(0xFFB8BCC2);
  static const _bronze = Color(0xFFC98A4B);

  @override
  Widget build(BuildContext context) {
    // L'ordre d'affichage : 2e, 1er, 3e (seulement ceux qui existent).
    final places = <(int, double, Color)>[   // un « record » Dart : (index, hauteur, couleur)
      (1, 84.0, _argent),
      (0, 116.0, Couleurs.or),
      (2, 64.0, _bronze),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      decoration: BoxDecoration(
        color: Couleurs.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,   // les marches sont alignées par le bas
        children: [
          // Déstructuration d'un record : « final (index, hauteur, couleur) = place ».
          for (final (index, hauteur, couleur) in places)
            Expanded(
              child: index < premiers.length
                  ? _Marche(
                ligne: premiers[index],
                hauteur: hauteur,
                couleur: couleur,
                surAppui: () => surLutteur(premiers[index]),
              )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _Marche extends StatelessWidget {
  const _Marche({required this.ligne, required this.hauteur, required this.couleur, required this.surAppui});

  final LigneClassement ligne;
  final double hauteur;
  final Color couleur;
  final VoidCallback surAppui;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: surAppui,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(ligne.nomAffiche,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 2),
            Text('${ligne.points} pts',
                style: const TextStyle(color: Couleurs.orTexte, fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              height: hauteur,
              decoration: BoxDecoration(
                color: couleur,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              alignment: Alignment.center,
              child: Text('${ligne.rang}',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Couleurs.noir)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une ligne du classement à partir de la 4e place.
class _LigneRang extends StatelessWidget {
  const _LigneRang({required this.ligne, required this.surAppui});

  final LigneClassement ligne;
  final VoidCallback surAppui;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Couleurs.blanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Couleurs.bordure),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: surAppui,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text('${ligne.rang}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ligne.nomAffiche,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${ligne.bilanCourt} · ${MontantsFr.fcfa(ligne.totalGagne)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Couleurs.grisTexte)),
                  ],
                ),
              ),
              Text('${ligne.points} pts',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Couleurs.orTexte)),
            ],
          ),
        ),
      ),
    );
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