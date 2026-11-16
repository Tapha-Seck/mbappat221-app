// Fichier : lib/ecrans/lutteurs/ecran_fiche_lutteur.dart
// La fiche d'un lutteur : ses photos (on les fait glisser), son profil, son bilan de la saison
// et l'historique de ses finales.
//
// Nouveaux concepts :
//  - PageView      : des pages qu'on fait glisser du doigt (ici, la galerie de photos).
//  - AnimatedContainer : un conteneur qui s'anime tout seul quand ses dimensions changent
//                        (les petits points sous la galerie).
//  - Wrap + Expanded en Row : une grille simple de chiffres, sans GridView.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/ecran_affiche.dart';
import 'package:mbappat221_app/ecrans/galas/elements_gala.dart';
import 'package:mbappat221_app/modeles/fiche_lutteur.dart';
import 'package:mbappat221_app/outils/dates_fr.dart';
import 'package:mbappat221_app/outils/montants_fr.dart';
import 'package:mbappat221_app/services/lutteur_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';
import 'package:mbappat221_app/widgets/avatar_photo.dart';

class EcranFicheLutteur extends StatefulWidget {
  const EcranFicheLutteur({
    super.key,
    required this.lutteurId,
    required this.titre,
    required this.lutteurApi,
  });

  final int lutteurId;
  final String titre;   // affiché tout de suite dans la barre, pendant le chargement
  final LutteurApi lutteurApi;

  static Future<void> ouvrir(BuildContext context,
      {required int lutteurId, required String titre, required LutteurApi lutteurApi}) {
    return Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) =>
          EcranFicheLutteur(lutteurId: lutteurId, titre: titre, lutteurApi: lutteurApi),
    ));
  }

  @override
  State<EcranFicheLutteur> createState() => _EcranFicheLutteurState();
}

class _EcranFicheLutteurState extends State<EcranFicheLutteur> {
  late Future<FicheLutteur> _chargement;

  @override
  void initState() {
    super.initState();
    _chargement = widget.lutteurApi.fiche(widget.lutteurId);
  }

  void _recharger() {
    setState(() => _chargement = widget.lutteurApi.fiche(widget.lutteurId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titre, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: FutureBuilder<FicheLutteur>(
        future: _chargement,
        builder: (context, etat) {
          if (etat.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (etat.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 56, color: Couleurs.rouge),
                    const SizedBox(height: 16),
                    Text('${etat.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _recharger,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _ContenuFiche(fiche: etat.requireData, lutteurApi: widget.lutteurApi);
        },
      ),
    );
  }
}

class _ContenuFiche extends StatelessWidget {
  const _ContenuFiche({required this.fiche, required this.lutteurApi});

  final FicheLutteur fiche;
  final LutteurApi lutteurApi;

  @override
  Widget build(BuildContext context) {
    final lutteur = fiche.lutteur;
    final textes = Theme.of(context).textTheme;
    // Les adresses complètes des photos ; « whereType<String>() » retire les éventuels null.
    final photos = fiche.photos.map(lutteurApi.urlFichier).whereType<String>().toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (photos.isNotEmpty)
          _Galerie(photos: photos, titre: lutteur.nomAffiche, lutteurId: lutteur.id)
        else
          Center(
            child: AvatarPhoto(
              nom: lutteur.nomAffiche,
              url: lutteurApi.urlFichier(lutteur.photoUrl),
              rayon: 64,
            ),
          ),
        const SizedBox(height: 16),

        if (lutteur.retraite) const _Etiquette(texte: 'RETRAITÉ', couleur: Couleurs.grisTexte),
        Text(lutteur.nomAffiche,
            style: textes.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        if (lutteur.surnom != null)
          Text(lutteur.nom, style: const TextStyle(fontSize: 15, color: Couleurs.grisTexte)),
        const SizedBox(height: 12),

        LigneInfo(icone: Icons.emoji_events_outlined, texte: lutteur.categorieNom, taille: 15),
        LigneInfo(
            icone: Icons.groups_outlined, texte: lutteur.ecurieNom ?? 'Sans écurie', taille: 15),
        if (lutteur.region != null)
          LigneInfo(icone: Icons.place_outlined, texte: lutteur.region!, taille: 15),

        if (lutteur.apercu != null && lutteur.apercu!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(lutteur.apercu!,
              style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, height: 1.4)),
        ],

        TitreSection('Saison ${fiche.saisonLibelle}'),
        _Bilan(bilan: fiche.bilan),

        if (lutteur.biographie != null && lutteur.biographie!.trim().isNotEmpty) ...[
          const TitreSection('Biographie'),
          _Bloc(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(lutteur.biographie!, style: const TextStyle(height: 1.5)),
            ),
          ),
        ],

        TitreSection('Finales (${fiche.historique.length})'),
        if (fiche.historique.isEmpty)
          const Text('Aucune finale enregistrée pour le moment.',
              style: TextStyle(color: Couleurs.grisTexte))
        else
          _Bloc(
            child: Column(
              children: [
                for (var i = 0; i < fiche.historique.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Couleurs.bordure),
                  _LigneFinale(finale: fiche.historique[i]),
                ],
              ],
            ),
          ),

        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Retour'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Couleurs.noir,
            side: const BorderSide(color: Couleurs.noir),
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Les photos du lutteur : on les fait glisser du doigt ; un appui l'ouvre en plein écran (zoom).
/// StatefulWidget : il retient la photo affichée, pour allumer le bon petit point.
class _Galerie extends StatefulWidget {
  const _Galerie({required this.photos, required this.titre, required this.lutteurId});

  final List<String> photos;
  final String titre;
  final int lutteurId;

  @override
  State<_Galerie> createState() => _GalerieState();
}

class _GalerieState extends State<_Galerie> {
  int _photoActive = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 340,
            color: Couleurs.noir,
            // PageView.builder : une page par photo, construite seulement quand elle apparaît.
            child: PageView.builder(
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _photoActive = index),
              itemBuilder: (context, index) {
                final url = widget.photos[index];
                final tag = 'photo-lutteur-${widget.lutteurId}-$index';
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => EcranAffiche(url: url, titre: widget.titre, tagHero: tag),
                  )),
                  child: Hero(
                    tag: tag,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, erreur, pile) => const Center(
                        child: Icon(Icons.broken_image_outlined, color: Couleurs.blanc, size: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.photos.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.photos.length; i++)
              // Le point actif s'allonge en douceur (200 ms) : AnimatedContainer anime le changement.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _photoActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _photoActive ? Couleurs.or : Couleurs.bordure,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Le bilan de la saison : 4 chiffres, le nombre de finales et les lots reçus.
class _Bilan extends StatelessWidget {
  const _Bilan({required this.bilan});

  final BilanSaison bilan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _Chiffre(valeur: '${bilan.points}', libelle: 'Points', enAvant: true)),
            const SizedBox(width: 8),
            Expanded(child: _Chiffre(valeur: MontantsFr.fcfa(bilan.totalGagne), libelle: 'Gagné')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _Chiffre(
                    valeur: '${bilan.victoires}', libelle: 'Victoires', couleur: Couleurs.vert)),
            const SizedBox(width: 8),
            Expanded(
                child: _Chiffre(
                    valeur: '${bilan.defaites}', libelle: 'Défaites', couleur: Couleurs.rouge)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          bilan.finalesDisputees == 1
              ? '1 finale disputée cette saison'
              : '${bilan.finalesDisputees} finales disputées cette saison',
          style: const TextStyle(color: Couleurs.grisTexte),
        ),
        if (bilan.lotsRecus.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final lot in bilan.lotsRecus)
                Chip(
                  avatar: const Icon(Icons.card_giftcard, size: 16, color: Couleurs.orTexte),
                  label: Text(lot),
                  backgroundColor: Couleurs.blanc,
                  side: const BorderSide(color: Couleurs.bordure),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Chiffre extends StatelessWidget {
  const _Chiffre({required this.valeur, required this.libelle, this.couleur, this.enAvant = false});

  final String valeur;
  final String libelle;
  final Color? couleur;
  final bool enAvant;   // la case des points : fond noir, chiffre en or

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: enAvant ? Couleurs.noir : Couleurs.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: enAvant ? Couleurs.noir : Couleurs.bordure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FittedBox : réduit le texte s'il est trop large (« 12 500 000 FCFA » sur un petit écran).
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valeur,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: enAvant ? Couleurs.or : (couleur ?? Couleurs.noir),
                )),
          ),
          Text(libelle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enAvant ? Couleurs.blanc : Couleurs.grisTexte,
              )),
        ],
      ),
    );
  }
}

/// Une finale : V ou D en couleur, adversaire, gala, date, points et gain.
class _LigneFinale extends StatelessWidget {
  const _LigneFinale({required this.finale});

  final FinaleHistorique finale;

  @override
  Widget build(BuildContext context) {
    final couleur = finale.victoire ? Couleurs.vert : Couleurs.rouge;
    final date = finale.date;
    // Les morceaux non vides, réunis par « · » (≈ String.join(" · ", ...) en Java).
    final details = [
      if (date != null) DatesFr.majuscule(DatesFr.complete(date)),
      finale.galaNom,
      finale.categorieNom,
    ].join(' · ');

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: couleur,
        foregroundColor: Couleurs.blanc,
        child: Text(finale.victoire ? 'V' : 'D', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      title: Text(
        '${finale.victoire ? 'Victoire' : 'Défaite'} contre ${finale.adversaire}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        finale.gainRecu == null ? details : '$details\nGain : ${finale.gainRecu}',
        style: const TextStyle(height: 1.4),
      ),
      isThreeLine: finale.gainRecu != null,
      trailing: Text('+${finale.points} pts',
          style: TextStyle(fontWeight: FontWeight.w800, color: couleur)),
    );
  }
}

class _Bloc extends StatelessWidget {
  const _Bloc({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Couleurs.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: child,
    );
  }
}

class _Etiquette extends StatelessWidget {
  const _Etiquette({required this.texte, required this.couleur});

  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(6)),
        child: Text(texte,
            style: const TextStyle(color: Couleurs.blanc, fontSize: 11, fontWeight: FontWeight.w800)),
      ),
    );
  }
}