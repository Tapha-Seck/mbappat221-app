// Fichier : lib/ecrans/plus/ecran_profil_animateur.dart
// Le profil d'une cantatrice, d'un griot ou d'une Tv Tv : photos, présentation, chaîne YouTube
// (Voir la chaîne / S'abonner), contact pour réservation (seulement avec son accord),
// biographie et galas animés.
//
// Les liens s'ouvrent avec url_launcher (voir lib/outils/liens.dart) :
// « tel: » → composeur d'appel, wa.me → WhatsApp, youtube.com → l'application YouTube.
// On ouvre YouTube plutôt que de lire les vidéos ici : la Tv Tv y gagne des ABONNÉS.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/galas/elements_gala.dart';
import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/outils/dates_fr.dart';
import 'package:mbappat221_app/outils/liens.dart';
import 'package:mbappat221_app/outils/telephone.dart';
import 'package:mbappat221_app/outils/youtube.dart';
import 'package:mbappat221_app/services/animateur_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';
import 'package:mbappat221_app/widgets/avatar_photo.dart';
import 'package:mbappat221_app/widgets/galerie_photos.dart';

class EcranProfilAnimateur extends StatefulWidget {
  const EcranProfilAnimateur({
    super.key,
    required this.animateurId,
    required this.titre,
    required this.animateurApi,
  });

  final int animateurId;
  final String titre;
  final AnimateurApi animateurApi;

  static Future<void> ouvrir(BuildContext context,
      {required int animateurId, required String titre, required AnimateurApi animateurApi}) {
    return Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) =>
          EcranProfilAnimateur(animateurId: animateurId, titre: titre, animateurApi: animateurApi),
    ));
  }

  @override
  State<EcranProfilAnimateur> createState() => _EcranProfilAnimateurState();
}

class _EcranProfilAnimateurState extends State<EcranProfilAnimateur> {
  late Future<ProfilAnimateur> _chargement;

  @override
  void initState() {
    super.initState();
    _chargement = widget.animateurApi.profil(widget.animateurId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titre, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: FutureBuilder<ProfilAnimateur>(
        future: _chargement,
        builder: (context, etat) {
          if (etat.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (etat.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 56, color: Couleurs.rouge),
                  const SizedBox(height: 16),
                  Text('${etat.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => setState(
                            () => _chargement = widget.animateurApi.profil(widget.animateurId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return _Profil(profil: etat.requireData, animateurApi: widget.animateurApi);
        },
      ),
    );
  }
}

class _Profil extends StatelessWidget {
  const _Profil({required this.profil, required this.animateurApi});

  final ProfilAnimateur profil;
  final AnimateurApi animateurApi;

  @override
  Widget build(BuildContext context) {
    final animateur = profil.animateur;
    final textes = Theme.of(context).textTheme;
    final photos = animateur.photos.map(animateurApi.urlFichier).whereType<String>().toList();
    final telephone = animateur.telephone;
    final youtube = animateur.youtubeUrl;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (photos.isNotEmpty)
          GaleriePhotos(
            photos: photos,
            titre: animateur.nomAffiche,
            prefixeHero: 'photo-animateur-${animateur.id}',
          )
        else
          Center(
            child: AvatarPhoto(
              nom: animateur.nomAffiche,
              url: animateurApi.urlFichier(animateur.photoUrl),
              rayon: 64,
            ),
          ),
        const SizedBox(height: 16),

        Text(animateur.nomAffiche, style: textes.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        if (animateur.surnom != null)
          Text(animateur.nom, style: const TextStyle(fontSize: 15, color: Couleurs.grisTexte)),
        const SizedBox(height: 12),
        LigneInfo(icone: iconeRole(animateur.role), texte: animateur.role.libelle, taille: 15),
        if (animateur.region != null)
          LigneInfo(icone: Icons.place_outlined, texte: animateur.region!, taille: 15),

        if (animateur.apercu != null && animateur.apercu!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(animateur.apercu!,
              style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, height: 1.4)),
        ],

        // La chaîne YouTube (surtout pour les Tv Tv).
        if (youtube != null) ...[
          const TitreSection('Chaîne YouTube'),
          _ChaineYoutube(adresse: youtube),
        ],

        // Le contact n'apparaît QUE si l'animateur a accepté qu'on publie son numéro.
        if (telephone != null) ...[
          TitreSection(animateur.role == RoleAnimateur.tv ? 'Contact' : 'Réservation'),
          _Contact(telephone: telephone),
        ],

        if (animateur.biographie != null && animateur.biographie!.trim().isNotEmpty) ...[
          const TitreSection('Biographie'),
          _Bloc(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(animateur.biographie!, style: const TextStyle(height: 1.5)),
            ),
          ),
        ],

        // Les galas animés : seulement pour les cantatrices et les griots (les Tv Tv n'animent pas les galas).
        if (animateur.role != RoleAnimateur.tv) ...[
          TitreSection('Galas animés (${profil.galas.length})'),
          if (profil.galas.isEmpty)
            const Text('Aucun gala pour le moment.', style: TextStyle(color: Couleurs.grisTexte))
          else
            _Bloc(
              child: Column(
                children: [
                  for (var i = 0; i < profil.galas.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: Couleurs.bordure),
                    _LigneGala(gala: profil.galas[i]),
                  ],
                ],
              ),
            ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}

/// Le numéro, et deux boutons : Appeler et WhatsApp.
class _Contact extends StatelessWidget {
  const _Contact({required this.telephone});

  final String telephone;

  @override
  Widget build(BuildContext context) {
    return _Bloc(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, color: Couleurs.orTexte),
                const SizedBox(width: 8),
                Text(Telephone.affichage(telephone),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => ouvrirLien(context, Telephone.lienAppel(telephone)),
                    icon: const Icon(Icons.call),
                    label: const Text('Appeler'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => ouvrirLien(context, Telephone.lienWhatsApp(telephone)),
                    style: FilledButton.styleFrom(backgroundColor: Couleurs.vert),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// La chaîne YouTube : « Voir la chaîne » et, si c'est bien une chaîne, « S'abonner ».
class _ChaineYoutube extends StatelessWidget {
  const _ChaineYoutube({required this.adresse});

  final String adresse;

  static const _rougeYoutube = Color(0xFFE62117);

  @override
  Widget build(BuildContext context) {
    return _Bloc(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Retrouve ses vidéos sur la lutte simple et abonne-toi pour ne rien manquer.',
                style: TextStyle(color: Couleurs.grisTexte, height: 1.4)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => ouvrirLien(context, YouTube.lienChaine(adresse)),
                    style: FilledButton.styleFrom(backgroundColor: _rougeYoutube),
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text('Voir la chaîne'),
                  ),
                ),
                // « S'abonner » seulement pour une adresse de chaîne (pas pour une vidéo).
                if (YouTube.estUneChaine(adresse)) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ouvrirLien(context, YouTube.lienAbonnement(adresse)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _rougeYoutube,
                        side: const BorderSide(color: _rougeYoutube),
                      ),
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('S\'abonner'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// L'icône de chaque rôle (partagée avec la liste des animateurs).
IconData iconeRole(RoleAnimateur role) => switch (role) {
  RoleAnimateur.cantatrice => Icons.mic_none,
  RoleAnimateur.griot => Icons.music_note_outlined,
  RoleAnimateur.tv => Icons.live_tv_outlined,
};

class _LigneGala extends StatelessWidget {
  const _LigneGala({required this.gala});

  final GalaAnime gala;

  @override
  Widget build(BuildContext context) {
    // Un « switch expression » (Dart 3) : chaque cas renvoie une valeur (≈ switch -> de Java 14+).
    final (libelle, couleur) = switch (gala.statut) {
      StatutGala.annonce => ('À venir', Couleurs.orTexte),
      StatutGala.termine => ('Terminé', Couleurs.grisTexte),
      StatutGala.annule => ('Annulé', Couleurs.rouge),
      StatutGala.brouillon => ('Brouillon', Couleurs.grisTexte),
    };
    return ListTile(
      title: Text(gala.nom, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        '${DatesFr.majuscule(DatesFr.periode(gala.dateDebut, gala.dateFin))}\n${gala.lieu} · ${gala.region}',
        style: const TextStyle(height: 1.4),
      ),
      isThreeLine: true,
      trailing: Text(libelle, style: TextStyle(color: couleur, fontWeight: FontWeight.w700)),
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