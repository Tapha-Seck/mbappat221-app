// Fichier : lib/ecrans/plus/ecran_animateurs.dart
// La liste des cantatrices, griots et Tv Tv, avec un filtre par rôle. Un appui ouvre le profil.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/ecrans/plus/ecran_profil_animateur.dart';
import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/services/animateur_api.dart';
import 'package:mbappat221_app/theme/couleurs.dart';
import 'package:mbappat221_app/widgets/avatar_photo.dart';

class EcranAnimateurs extends StatefulWidget {
  const EcranAnimateurs({super.key, required this.animateurApi});

  final AnimateurApi animateurApi;

  static Future<void> ouvrir(BuildContext context, AnimateurApi animateurApi) {
    return Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => EcranAnimateurs(animateurApi: animateurApi),
    ));
  }

  @override
  State<EcranAnimateurs> createState() => _EcranAnimateursState();
}

class _EcranAnimateursState extends State<EcranAnimateurs> {
  RoleAnimateur? _role;   // null = tous

  /// Une liste par filtre, demandée une seule fois (la clé null = « Tous »).
  final Map<RoleAnimateur?, Future<List<AnimateurDetail>>> _listes = {};

  Future<List<AnimateurDetail>> get _liste =>
      _listes.putIfAbsent(_role, () => widget.animateurApi.lister(role: _role));

  void _actualiser() => setState(() => _listes.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animateurs et Tv Tv', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(tooltip: 'Actualiser', icon: const Icon(Icons.refresh), onPressed: _actualiser),
        ],
      ),
      body: Column(
        children: [
          // Les filtres : Tous, Cantatrices, Griots, Tv Tv. « [null, ...RoleAnimateur.values] » = null suivi des rôles.
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              children: [
                for (final role in [null, ...RoleAnimateur.values])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(role?.libellePluriel ?? 'Tous'),
                      selected: _role == role,
                      onSelected: (_) => setState(() => _role = role),
                      showCheckmark: false,
                      selectedColor: Couleurs.or,
                      backgroundColor: Couleurs.blanc,
                      side: BorderSide(color: _role == role ? Couleurs.or : Couleurs.bordure),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AnimateurDetail>>(
              future: _liste,
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
                          onPressed: _actualiser,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                final animateurs = etat.requireData;
                if (animateurs.isEmpty) {
                  return const Center(
                    child: Text('Aucun animateur pour le moment.',
                        style: TextStyle(color: Couleurs.grisTexte)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: animateurs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final animateur = animateurs[index];
                    return _LigneAnimateur(
                      animateur: animateur,
                      urlPhoto: widget.animateurApi.urlFichier(animateur.photoUrl),
                      surAppui: () => EcranProfilAnimateur.ouvrir(
                        context,
                        animateurId: animateur.id,
                        titre: animateur.nomAffiche,
                        animateurApi: widget.animateurApi,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneAnimateur extends StatelessWidget {
  const _LigneAnimateur({required this.animateur, required this.surAppui, this.urlPhoto});

  final AnimateurDetail animateur;
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: surAppui,
        leading: AvatarPhoto(nom: animateur.nomAffiche, url: urlPhoto, rayon: 24),
        title: Text(animateur.nomAffiche, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(animateur.roleEtRegion),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Petit lecteur rouge : il a une chaîne YouTube.
            if (animateur.youtubeUrl != null)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.smart_display, size: 18, color: Color(0xFFE62117)),
              ),
            // Petit téléphone vert : cet animateur accepte d'être contacté pour une réservation.
            if (animateur.telephone != null)
              const Icon(Icons.phone_in_talk, size: 18, color: Couleurs.vert),
            const Icon(Icons.chevron_right, color: Couleurs.grisTexte),
          ],
        ),
      ),
    );
  }
}