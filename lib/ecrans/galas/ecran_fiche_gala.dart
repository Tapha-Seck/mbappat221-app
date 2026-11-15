// Fichier : lib/ecrans/galas/ecran_fiche_gala.dart
// La fiche d'un gala : l'affiche en grand, les infos, les catégories (drapeaux), l'animation.
//
// Nouveaux concepts :
//  - Navigator.push : ouvrir un nouvel écran PAR-DESSUS l'actuel (avec la flèche retour en haut).
//    Les écrans forment une pile : push ajoute un écran, la flèche retour le retire (pop).
//    Comparaison web : un lien vers une nouvelle page, le bouton « Précédent » du navigateur.
//  - MaterialPageRoute : la « route » (l'écran + son animation d'ouverture).
//
// Pas d'appel réseau ici : le gala reçu de la liste contient déjà tout ce qu'on affiche.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/ecran_affiche.dart';
import 'package:mbappat221_app/ecrans/galas/elements_gala.dart';
import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/outils/dates_fr.dart';
import 'package:mbappat221_app/outils/montants_fr.dart';
import 'package:mbappat221_app/services/gala_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class EcranFicheGala extends StatelessWidget {
  const EcranFicheGala({super.key, required this.gala, required this.galaApi});

  final Gala gala;
  final GalaApi galaApi;   // seulement pour construire l'adresse des images

  /// Ouvre la fiche d'un gala. Méthode « static » : on l'appelle sans objet,
  /// EcranFicheGala.ouvrir(context, gala: g, galaApi: api), depuis la liste ou l'accueil.
  static Future<void> ouvrir(BuildContext context, {required Gala gala, required GalaApi galaApi}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => EcranFicheGala(gala: gala, galaApi: galaApi)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textes = Theme.of(context).textTheme;
    final urlAffiche = galaApi.urlFichier(gala.afficheUrl);

    return Scaffold(
      appBar: AppBar(
        // La flèche retour est ajoutée AUTOMATIQUEMENT, parce que l'écran a été ouvert avec push.
        title: Text(gala.nom, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (urlAffiche != null)
            _AfficheCliquable(url: urlAffiche, titre: gala.nom, tagHero: 'affiche-gala-${gala.id}')
          else
            Center(child: BlocDate(date: gala.dateDebut, largeur: 110, hauteur: 140)),
          const SizedBox(height: 16),

          if (gala.estAnnule) const EtiquetteAnnule(),
          Text(
            gala.nom,
            style: textes.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              decoration: gala.estAnnule ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 12),

          LigneInfo(
            icone: Icons.calendar_today_outlined,
            texte: DatesFr.majuscule(DatesFr.periode(gala.dateDebut, gala.dateFin)),
            taille: 15,
            uneSeuleLigne: false,
          ),
          LigneInfo(
            icone: Icons.place_outlined,
            texte: '${gala.lieu} · ${gala.region}',
            taille: 15,
            uneSeuleLigne: false,
          ),
          // « collection if » : la ligne n'apparaît que si l'organisateur est connu.
          if (gala.organisateur != null)
            LigneInfo(
              icone: Icons.campaign_outlined,
              texte: 'Organisé par ${gala.organisateur}',
              taille: 15,
              uneSeuleLigne: false,
            ),
          LigneInfo(
            icone: Icons.payments_outlined,
            texte: 'Mise : ${gala.mise}',
            taille: 15,
            uneSeuleLigne: false,
          ),

          if (gala.drapeaux.isNotEmpty) ...[
            TitreSection('Catégories (${gala.drapeaux.length})'),
            _Bloc(
              children: [
                for (final drapeau in gala.drapeaux) _LigneDrapeau(drapeau: drapeau),
              ],
            ),
          ],

          if (gala.animateurs.isNotEmpty) ...[
            const TitreSection('Animation'),
            _Bloc(
              children: [
                for (final animateur in gala.animateurs)
                  _LigneAnimateur(
                    animateur: animateur,
                    urlPhoto: galaApi.urlFichier(animateur.photoUrl),
                  ),
              ],
            ),
          ],

          if (gala.infosComplementaires != null && gala.infosComplementaires!.trim().isNotEmpty) ...[
            const TitreSection('Informations'),
            _Bloc(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(gala.infosComplementaires!, style: const TextStyle(height: 1.4)),
                ),
              ],
            ),
          ],

          // Bouton « Retour » en bas de la fiche : pas besoin de remonter jusqu'à la flèche du haut.
          // Navigator.pop ferme l'écran actuel et revient au précédent (le contraire de push).
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Couleurs.noir,
              side: const BorderSide(color: Couleurs.noir),
              minimumSize: const Size.fromHeight(48),   // toute la largeur, 48 px de haut (facile à toucher)
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// L'affiche en grand ; un appui l'ouvre en plein écran (zoom).
class _AfficheCliquable extends StatelessWidget {
  const _AfficheCliquable({required this.url, required this.titre, required this.tagHero});

  final String url;
  final String titre;
  final String tagHero;

  void _ouvrirEnGrand(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => EcranAffiche(url: url, titre: titre, tagHero: tagHero),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector : détecte les gestes (appui, double appui...) sur n'importe quel widget.
    return GestureDetector(
      onTap: () => _ouvrirEnGrand(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Couleurs.noir,
          constraints: const BoxConstraints(minHeight: 220, maxHeight: 440),
          width: double.infinity,   // toute la largeur disponible
          // Stack : superpose ses enfants (l'image, puis la pastille « Agrandir » par-dessus).
          child: Stack(
            alignment: Alignment.center,
            children: [
              Hero(
                tag: tagHero,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, erreur, pile) => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Icon(Icons.broken_image_outlined, color: Couleurs.blanc, size: 48),
                  ),
                ),
              ),
              // Positioned : place un enfant de Stack à un endroit précis (ici en bas à droite).
              const Positioned(
                right: 10,
                bottom: 10,
                child: _PastilleAgrandir(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastilleAgrandir extends StatelessWidget {
  const _PastilleAgrandir();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Couleurs.or, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.zoom_in, size: 16, color: Couleurs.noir),
          SizedBox(width: 4),
          Text('Agrandir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Un bloc blanc arrondi qui regroupe des lignes, séparées par un trait fin.
class _Bloc extends StatelessWidget {
  const _Bloc({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Couleurs.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Couleurs.bordure),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Une catégorie : nom, date et heure de la finale, montant annoncé.
class _LigneDrapeau extends StatelessWidget {
  const _LigneDrapeau({required this.drapeau});

  final DrapeauCalendrier drapeau;

  /// « Samedi 12 décembre 2026 · 17:00 », ou « Date à préciser ».
  String get _quand {
    final date = drapeau.date;
    if (date == null) {
      return 'Date à préciser';
    }
    final heure = drapeau.heureCourte;
    final jour = DatesFr.majuscule(DatesFr.complete(date));
    return heure == null ? jour : '$jour · $heure';
  }

  @override
  Widget build(BuildContext context) {
    final montant = drapeau.montantAnnonce;
    // ListTile : ligne prête à l'emploi (titre, sous-titre, élément à droite).
    return ListTile(
      leading: const Icon(Icons.flag_outlined, color: Couleurs.orTexte),
      title: Text(drapeau.categorieNom, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(_quand),
      trailing: montant == null
          ? null
          : Text(MontantsFr.fcfa(montant),
          style: const TextStyle(fontWeight: FontWeight.w800, color: Couleurs.orTexte)),
    );
  }
}

/// Une cantatrice ou un griot : photo ronde (ou initiale), nom, rôle.
class _LigneAnimateur extends StatelessWidget {
  const _LigneAnimateur({required this.animateur, this.urlPhoto});

  final AnimateurResume animateur;
  final String? urlPhoto;

  @override
  Widget build(BuildContext context) {
    final url = urlPhoto;
    return ListTile(
      // CircleAvatar : un cercle avec une image, ou à défaut un texte (ici l'initiale du nom).
      leading: CircleAvatar(
        backgroundColor: Couleurs.or,
        foregroundColor: Couleurs.noir,
        backgroundImage: url == null ? null : NetworkImage(url),
        // Obligatoire avec une image réseau : que faire si elle ne se charge pas (ici, rien).
        onBackgroundImageError: url == null ? null : (erreur, pile) {},
        child: url == null
            ? Text(animateur.nom.isEmpty ? '?' : animateur.nom[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800))
            : null,
      ),
      title: Text(animateur.nomAffiche, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(animateur.role.libelle),
    );
  }
}