// Fichier : lib/ecrans/presentation/ecran_presentation.dart
// La présentation de l'application en 3 pages, affichée UNE SEULE FOIS après l'installation.
// « Passer » ou « Commencer » appelle [surTerminer] : main.dart retient alors qu'elle a été vue.
//
// Chaque page peut avoir une PHOTO en plein écran, assombrie vers le bas par un dégradé
// pour que le texte blanc reste lisible quelle que soit l'image.
//
// Nouveaux concepts :
//  - PageController     : pilote un PageView depuis le code (le bouton « Suivant »).
//  - Stack + Positioned : superposer la photo, le dégradé, le texte et les boutons.
//  - LinearGradient     : un dégradé de couleurs (≈ linear-gradient en CSS).
//  - precacheImage      : charger les photos à l'avance, pour un défilement sans saccade.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/theme/couleurs.dart';

/// Le contenu d'une page : un « record » nommé Dart ({...}) ≈ un petit record Java à champs nommés.
///  - fond  : la photo en plein écran (null = fond noir avec une grande icône) ;
///  - voile : où le dégradé noir commence (0 = tout en haut, 1 = tout en bas) : plus petit = plus sombre.
typedef _Page = ({String? fond, double voile, IconData? icone, bool logo, String titre, String texte});

class EcranPresentation extends StatefulWidget {
  const EcranPresentation({super.key, required this.surTerminer});

  /// Appelée quand l'utilisateur termine (ou passe) la présentation.
  final VoidCallback surTerminer;

  static const List<_Page> pages = [
    (
    fond: 'assets/images/presentation/accueil.jpg',
    voile: 0.45,
    icone: null,
    logo: true,
    titre: 'Bienvenue sur Mbappat 221',
    texte: 'Toute la lutte simple sénégalaise dans ta poche : galas, lutteurs, résultats et classements.',
    ),
    (
    fond: null,   // en attendant les captures de l'application
    voile: 0,
    icone: Icons.emoji_events,
    logo: false,
    titre: 'Galas et classement',
    texte: 'Le calendrier des galas avec leurs affiches, les résultats des finales et le classement '
        'de chaque catégorie, calculé selon le barème officiel de la saison.',
    ),
    (
    fond: 'assets/images/presentation/animateurs.jpg',
    // Photo rognée en haut (le fond sombre) : le griot remonte. Dégradé plus bas pour le laisser voir.
    voile: 0.45,
    icone: null,
    logo: false,
    titre: 'Lutteurs, animateurs et Tv Tv',
    texte: 'Les fiches des lutteurs, les cantatrices, griots et Tv Tv de la lutte simple. '
        'Bientôt : la billetterie et les galas en pay-per-view.',
    ),
  ];

  @override
  State<EcranPresentation> createState() => _EcranPresentationState();
}

class _EcranPresentationState extends State<EcranPresentation> {
  final _pages = PageController();
  int _pageActive = 0;

  bool get _derniere => _pageActive == EcranPresentation.pages.length - 1;

  /// Appelée après initState, quand le « context » est prêt : on précharge toutes les photos,
  /// pour qu'elles s'affichent tout de suite en faisant glisser les pages.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final page in EcranPresentation.pages) {
      final fond = page.fond;
      if (fond != null) {
        precacheImage(AssetImage(fond), context);
      }
    }
  }

  @override
  void dispose() {
    _pages.dispose();   // un contrôleur se libère toujours dans dispose() (≈ @PreDestroy)
    super.dispose();
  }

  void _suivant() {
    if (_derniere) {
      widget.surTerminer();
      return;
    }
    _pages.animateToPage(
      _pageActive + 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,   // ralentit en fin de mouvement : plus naturel
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.noir,
      // Stack : les pages (photo + texte) en dessous, les boutons fixes par-dessus.
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: EcranPresentation.pages.length,
            onPageChanged: (index) => setState(() => _pageActive = index),
            itemBuilder: (context, index) => _ContenuPage(page: EcranPresentation.pages[index]),
          ),
          // « Passer », en haut à droite (caché sur la dernière page).
          if (!_derniere)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(   // SafeArea : évite l'encoche et la barre d'état du téléphone
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextButton(
                    onPressed: widget.surTerminer,
                    style: TextButton.styleFrom(
                      foregroundColor: Couleurs.blanc,
                      backgroundColor: const Color(0x55000000),   // pastille sombre : lisible sur la photo
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Passer'),
                  ),
                ),
              ),
            ),
          // En bas : les petits points et le bouton.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < EcranPresentation.pages.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _pageActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _pageActive ? Couleurs.or : const Color(0x88FFFFFF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _suivant,
                      style: FilledButton.styleFrom(
                        backgroundColor: Couleurs.or,
                        foregroundColor: Couleurs.noir,
                        minimumSize: const Size.fromHeight(52),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      child: Text(_derniere ? 'Commencer' : 'Suivant'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContenuPage extends StatelessWidget {
  const _ContenuPage({required this.page});

  final _Page page;

  /// Espace laissé en bas pour les points et le bouton (qui sont posés par-dessus).
  static const double _espaceBoutons = 150;

  /// Une légère ombre noire sous les lettres : le texte reste lisible même sur une zone claire
  /// de la photo (≈ text-shadow en CSS).
  static const List<Shadow> _ombre = [Shadow(color: Color(0xCC000000), blurRadius: 8, offset: Offset(0, 1))];

  @override
  Widget build(BuildContext context) {
    final fond = page.fond;
    final icone = page.icone;

    final textes = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(page.titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Couleurs.blanc, fontSize: 28, fontWeight: FontWeight.w900, height: 1.15, shadows: _ombre)),
        const SizedBox(height: 14),
        Text(page.texte,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFE6E1D6), fontSize: 16, height: 1.5, shadows: _ombre)),
      ],
    );

    // StackFit.expand : chaque enfant non positionné prend toute la place (la photo, le dégradé).
    return Stack(
      fit: StackFit.expand,
      children: [
        if (fond != null) ...[
          // BoxFit.cover : la photo remplit l'écran sans se déformer (les bords sont rognés si besoin).
          // Alignment.topCenter : on garde toujours le HAUT de la photo, là où sont les personnes.
          Image.asset(fond, fit: BoxFit.cover, alignment: Alignment.topCenter),
          // Le dégradé : transparent en haut, de plus en plus opaque vers le bas, noir tout en bas
          // (≈ linear-gradient(transparent, black) en CSS). 4 paliers : il commence un peu AVANT
          // le texte et il est déjà sombre (≈ 50 %, puis 90 %) derrière le titre et la description.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Color(0x00000000), Color(0x80000000), Color(0xE6000000), Color(0xFF000000)],
                // clamp(0, 1) : une position de dégradé doit rester entre 0 (haut) et 1 (bas)
                // (≈ Math.max(0, Math.min(1, x)) en Java).
                stops: [
                  (page.voile - 0.15).clamp(0.0, 1.0),
                  (page.voile + 0.08).clamp(0.0, 1.0),
                  (page.voile + 0.28).clamp(0.0, 1.0),
                  (page.voile + 0.45).clamp(0.0, 1.0),
                ],
              ),
            ),
          ),
        ],
        if (fond == null && icone != null)
        // Sans photo : la grande icône dorée, un peu au-dessus du centre.
          Align(
            alignment: const Alignment(0, -0.35),
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(color: Couleurs.or, shape: BoxShape.circle),
              child: Icon(icone, size: 72, color: Couleurs.noir),
            ),
          ),
        if (page.logo)
        // Le logo en petit, en haut à gauche de la première page.
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 0, 0),
                child: Image.asset('assets/images/logo_mbappat221.png', height: 64),
              ),
            ),
          ),
        // Le titre et le texte, en bas, au-dessus des boutons.
        Positioned(
          left: 32,
          right: 32,
          bottom: _espaceBoutons + MediaQuery.paddingOf(context).bottom,
          child: textes,
        ),
      ],
    );
  }
}