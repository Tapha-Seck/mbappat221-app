// Fichier : lib/ecrans/galas/ecran_fiche_gala.dart
// La fiche d'un gala : l'affiche en grand, les infos, les catégories (drapeaux), l'animation.
//
// Nouveaux concepts :
//  - Navigator.push : ouvrir un nouvel écran PAR-DESSUS l'actuel (avec la flèche retour en haut).
//    Les écrans forment une pile : push ajoute un écran, la flèche retour le retire (pop).
//    Comparaison web : un lien vers une nouvelle page, le bouton « Précédent » du navigateur.
//  - MaterialPageRoute : la « route » (l'écran + son animation d'ouverture).
//
// Le gala reçu de la liste contient déjà presque tout. Un seul appel réseau, et seulement si
// le gala a pu commencer : ses RÉSULTATS (vainqueur, perdant, gains de chaque finale).

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/ecran_affiche.dart';
import 'package:mbappat221_app/ecrans/galas/elements_gala.dart';
import 'package:mbappat221_app/ecrans/lutteurs/ecran_fiche_lutteur.dart';
import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/resultats_gala.dart';
import 'package:mbappat221_app/outils/dates_fr.dart';
import 'package:mbappat221_app/outils/montants_fr.dart';
import 'package:mbappat221_app/services/gala_api.dart';
import 'package:mbappat221_app/services/lutteur_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';

class EcranFicheGala extends StatelessWidget {
  const EcranFicheGala({super.key, required this.gala, required this.galaApi, this.lutteurApi});

  final Gala gala;
  final GalaApi galaApi;   // adresse des images, et résultats des finales

  /// Pour ouvrir la fiche d'un finaliste. Facultatif : sans lui, les noms ne sont pas cliquables.
  final LutteurApi? lutteurApi;

  /// Ouvre la fiche d'un gala. Méthode « static » : on l'appelle sans objet,
  /// EcranFicheGala.ouvrir(context, gala: g, galaApi: api), depuis la liste ou l'accueil.
  static Future<void> ouvrir(BuildContext context,
      {required Gala gala, required GalaApi galaApi, LutteurApi? lutteurApi}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
          builder: (context) => EcranFicheGala(gala: gala, galaApi: galaApi, lutteurApi: lutteurApi)),
    );
  }

  /// Un gala ne peut avoir de résultats que s'il est terminé, ou annoncé et déjà commencé
  /// (les finales d'un gala sur plusieurs jours sont saisies au fur et à mesure).
  bool get _peutAvoirDesResultats {
    if (gala.statut == StatutGala.termine) {
      return true;
    }
    // DateUtils.dateOnly : aujourd'hui à minuit (≈ LocalDate.now() en Java).
    final aujourdhui = DateUtils.dateOnly(DateTime.now());
    return gala.statut == StatutGala.annonce && !gala.dateDebut.isAfter(aujourdhui);
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

          if (gala.drapeaux.isNotEmpty)
            _SectionCategories(
              gala: gala,
              galaApi: galaApi,
              lutteurApi: lutteurApi,
              chargerResultats: _peutAvoirDesResultats,
            ),

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

/// Les catégories du gala, ou ses RÉSULTATS dès qu'au moins une finale est saisie.
///
/// StatefulWidget : le chargement (le Future) est créé UNE fois dans initState. Dans un
/// StatelessWidget, il serait relancé à chaque redessin de l'écran (une requête de trop à chaque fois).
class _SectionCategories extends StatefulWidget {
  const _SectionCategories({
    required this.gala,
    required this.galaApi,
    required this.lutteurApi,
    required this.chargerResultats,
  });

  final Gala gala;
  final GalaApi galaApi;
  final LutteurApi? lutteurApi;
  final bool chargerResultats;

  @override
  State<_SectionCategories> createState() => _SectionCategoriesState();
}

class _SectionCategoriesState extends State<_SectionCategories> {
  Future<ResultatsGala>? _resultats;   // null : aucun résultat possible, pas d'appel réseau

  @override
  void initState() {
    super.initState();
    if (widget.chargerResultats) {
      _resultats = widget.galaApi.resultats(widget.gala.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultats = _resultats;
    if (resultats == null) {
      return _categories();
    }
    return FutureBuilder<ResultatsGala>(
      future: resultats,
      builder: (context, etat) {
        final donnees = etat.data;
        // Pendant le chargement, en cas d'erreur ou sans aucune finale saisie : les catégories
        // simples (l'écran reste utile). Sinon : les résultats.
        if (donnees == null || !donnees.aDesResultats) {
          return _categories();
        }
        return _resultatsDuGala(donnees);
      },
    );
  }

  Widget _categories() {
    final drapeaux = widget.gala.drapeaux;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitreSection('Catégories (${drapeaux.length})'),
        _Bloc(children: [for (final drapeau in drapeaux) _LigneDrapeau(drapeau: drapeau)]),
      ],
    );
  }

  Widget _resultatsDuGala(ResultatsGala resultats) {
    final lutteurApi = widget.lutteurApi;

    /// Fonction locale : ce qu'il faut faire quand on touche un finaliste (null = pas cliquable).
    VoidCallback? ouvrirFiche(Finaliste lutteur) => lutteurApi == null
        ? null
        : () => EcranFicheLutteur.ouvrir(context,
        lutteurId: lutteur.id, titre: lutteur.nomAffiche, lutteurApi: lutteurApi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TitreSection('Résultats'),
        _Bloc(
          children: [
            for (final categorie in resultats.categories)
              _ResultatCategorie(
                categorie: categorie,
                pointsVainqueur: resultats.pointsVainqueur,
                pointsPerdant: resultats.pointsPerdant,
                ouvrirFiche: ouvrirFiche,
              ),
          ],
        ),
      ],
    );
  }
}

/// Une catégorie dans les résultats : son nom, puis le vainqueur et le perdant de la finale.
class _ResultatCategorie extends StatelessWidget {
  const _ResultatCategorie({
    required this.categorie,
    required this.pointsVainqueur,
    required this.pointsPerdant,
    required this.ouvrirFiche,
  });

  final CategorieGala categorie;
  final int? pointsVainqueur;
  final int? pointsPerdant;

  /// Une fonction qui RENVOIE une fonction (ou null) : pour chaque finaliste, l'action au toucher.
  final VoidCallback? Function(Finaliste) ouvrirFiche;

  @override
  Widget build(BuildContext context) {
    final finale = categorie.finale;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 18, color: Couleurs.orTexte),
              const SizedBox(width: 8),
              Text(categorie.drapeau.categorieNom,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          if (finale == null)
            const Padding(
              padding: EdgeInsets.only(left: 26, bottom: 8),
              child: Text('Résultat pas encore saisi', style: TextStyle(color: Couleurs.grisTexte)),
            )
          else ...[
            _LigneFinaliste(
              lutteur: finale.vainqueur,
              role: 'Vainqueur',
              gain: finale.gainVainqueur,
              points: pointsVainqueur,
              vainqueur: true,
              surAppui: ouvrirFiche(finale.vainqueur),
            ),
            _LigneFinaliste(
              lutteur: finale.perdant,
              role: 'Finaliste',
              gain: finale.gainPerdant,
              points: pointsPerdant,
              vainqueur: false,
              surAppui: ouvrirFiche(finale.perdant),
            ),
          ],
        ],
      ),
    );
  }
}

/// Un finaliste : trophée (vainqueur) ou silhouette, nom, rôle et gain, points gagnés à droite.
class _LigneFinaliste extends StatelessWidget {
  const _LigneFinaliste({
    required this.lutteur,
    required this.role,
    required this.gain,
    required this.points,
    required this.vainqueur,
    required this.surAppui,
  });

  final Finaliste lutteur;
  final String role;
  final String gain;
  final int? points;
  final bool vainqueur;
  final VoidCallback? surAppui;

  @override
  Widget build(BuildContext context) {
    final points = this.points;
    // Le gain "—" (rien reçu) n'est pas affiché.
    final detail = gain == '—' ? role : '$role · $gain';
    return InkWell(
      onTap: surAppui,   // null : pas d'effet au toucher
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: vainqueur ? Couleurs.or : Couleurs.fond,
                shape: BoxShape.circle,
              ),
              child: Icon(vainqueur ? Icons.emoji_events : Icons.person_outline,
                  size: 18, color: vainqueur ? Couleurs.noir : Couleurs.grisTexte),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lutteur.nomAffiche,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: vainqueur ? FontWeight.w800 : FontWeight.w600)),
                  Text(detail, style: const TextStyle(fontSize: 13, color: Couleurs.grisTexte)),
                ],
              ),
            ),
            if (points != null)
              Text('+$points pts',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: vainqueur ? Couleurs.vert : Couleurs.grisTexte)),
            if (surAppui != null) const Icon(Icons.chevron_right, color: Couleurs.grisTexte),
          ],
        ),
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