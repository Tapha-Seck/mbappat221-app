// Fichier : test/widget_test.dart
// Tests de l'application entière : navigation, accueil, galas (liste et fiche), lutteurs.
//
// Repères Java : testWidgets ≈ @Test, expect(x, matcher) ≈ assertThat(x, matcher),
// group(...) ≈ une classe de test @Nested. Les « factices » (test/factices.dart) ≈ des @Mock.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/app.dart';
import 'package:mbappat221_app/ecrans/accueil/ecran_accueil.dart';
import 'package:mbappat221_app/ecrans/classement/ecran_classement.dart';
import 'package:mbappat221_app/ecrans/galas/ecran_fiche_gala.dart';
import 'package:mbappat221_app/ecrans/galas/ecran_galas.dart';
import 'package:mbappat221_app/ecrans/lutteurs/ecran_fiche_lutteur.dart';
import 'package:mbappat221_app/ecrans/lutteurs/ecran_lutteurs.dart';
import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/categorie.dart';
import 'package:mbappat221_app/modeles/classement.dart';
import 'package:mbappat221_app/modeles/fiche_lutteur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/lutteur.dart';
import 'package:mbappat221_app/services/client_api.dart';

import 'factices.dart';

final _galaDeThies = Gala(
  id: 1,
  nom: 'Grand gala de Thiès',
  dateDebut: DateTime(2026, 11, 21),
  dateFin: DateTime(2026, 11, 21),
  lieu: 'Stade Lat Dior',
  region: 'Thiès',
  statut: StatutGala.annonce,
  mise: '1 500 000 FCFA',
  organisateur: 'Écurie Fass',
  animateurs: const [
    AnimateurResume(id: 3, nom: 'Ndèye Fatou', surnom: 'La Diva', role: RoleAnimateur.cantatrice),
  ],
  drapeaux: const [
    DrapeauCalendrier(categorieNom: 'Poids lourds', categorieOrdre: 1, montantAnnonce: 1000000),
  ],
);

final _galaAnnule = Gala(
  id: 2,
  nom: 'Gala de Fatick',
  dateDebut: DateTime(2026, 11, 28),
  dateFin: DateTime(2026, 11, 28),
  lieu: 'Arène de Fatick',
  region: 'Fatick',
  statut: StatutGala.annule,
  mise: '10 bœufs',
);

const _lutteurs = [
  LutteurListe(id: 1, nom: 'Modou Sarr', categorieId: 1, categorieNom: 'Poids Lourds',
      ecurieNom: 'Écurie Fass'),
  LutteurListe(id: 2, nom: 'Moussa Ndiaye', surnom: 'Lion de Fimela', categorieId: 2,
      categorieNom: 'Poids Légers'),
];

final _ficheLion = FicheLutteur(
  lutteur: const LutteurDetail(id: 2, nom: 'Moussa Ndiaye', surnom: 'Lion de Fimela',
      categorieNom: 'Poids Légers', retraite: false, region: 'Fatick'),
  photos: const [],
  saisonLibelle: '2026-2027',
  bilan: const BilanSaison(finalesDisputees: 2, victoires: 1, defaites: 1, points: 8,
      totalGagne: 150000, lotsRecus: ['1 bœuf']),
  historique: [
    FinaleHistorique(finaleId: 9, galaNom: 'LAMB CENTRE VILLE', categorieNom: 'Poids Légers',
        victoire: true, adversaire: 'Olympique', points: 5, date: DateTime(2027, 1, 10),
        gainRecu: '150 000 FCFA'),
  ],
);

const _categories = [
  Categorie(id: 1, nom: 'Poids Lourds', ordre: 1),
  Categorie(id: 2, nom: 'Poids Légers', ordre: 2),
];

LigneClassement _ligne(int rang, int id, String nom, int points) => LigneClassement(
    rang: rang, lutteurId: id, nom: nom, points: points, victoires: 2, defaites: 1,
    finales: 3, totalGagne: 300000);

final _classementLourds = Classement(
  categorieId: 1,
  categorieNom: 'Poids Lourds',
  saisonLibelle: '2026-2027',
  lignes: [
    _ligne(1, 11, 'Bombardier Junior', 15),
    _ligne(2, 12, 'Tonnerre de Joal', 10),
    _ligne(3, 13, 'Petit Lion', 8),
    _ligne(4, 14, 'Roc de Sine', 5),
  ],
);

final _ficheRoc = FicheLutteur(
  lutteur: const LutteurDetail(id: 14, nom: 'Roc de Sine', categorieNom: 'Poids Lourds', retraite: false),
  photos: const [],
  saisonLibelle: '2026-2027',
  bilan: const BilanSaison(finalesDisputees: 3, victoires: 2, defaites: 1, points: 5, totalGagne: 300000),
  historique: const [],
);

/// Trouve un libellé DANS la barre d'onglets uniquement.
Finder ongletNomme(String libelle) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(libelle));

/// Trouve un texte à l'intérieur d'un écran précis (le même gala apparaît sur l'accueil ET dans la liste).
Finder texteDans(Type ecran, String texte) =>
    find.descendant(of: find.byType(ecran), matching: find.text(texte));

/// Lit l'onglet actuellement sélectionné dans la barre.
int ongletActif(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

/// Un écran de test très haut : toute la fiche est visible sans défiler.
void ecranHaut(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);   // remet la taille normale après le test (≈ @AfterEach)
}

void main() {
  group('Navigation principale', () {
    testWidgets('affiche les 5 onglets et démarre sur Accueil', (tester) async {
      await tester.pumpWidget(Mbappat221App(services: servicesFactices()));

      for (final libelle in ['Accueil', 'Galas', 'Lutteurs', 'Classement', 'Plus']) {
        expect(ongletNomme(libelle), findsOneWidget);
      }
      expect(ongletActif(tester), 0);
      expect(find.text('La lutte simple sénégalaise'), findsOneWidget);
    });

    testWidgets('un appui sur un onglet change l\'écran affiché', (tester) async {
      await tester.pumpWidget(Mbappat221App(services: servicesFactices()));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();   // attend la fin des animations
      expect(ongletActif(tester), 1);

      await tester.tap(ongletNomme('Classement'));
      await tester.pumpAndSettle();
      expect(ongletActif(tester), 3);
    });

    testWidgets('l\'onglet Plus affiche un message au toucher', (tester) async {
      await tester.pumpWidget(Mbappat221App(services: servicesFactices()));

      await tester.tap(ongletNomme('Plus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nous contacter'));
      await tester.pump();   // le SnackBar apparaît

      expect(find.text('Cette rubrique arrive bientôt.'), findsOneWidget);
    });
  });

  group('Accueil', () {
    testWidgets('affiche le prochain gala', (tester) async {
      await tester.pumpWidget(
          Mbappat221App(services: servicesFactices(galas: [_galaDeThies, _galaAnnule])));
      await tester.pumpAndSettle();

      expect(texteDans(EcranAccueil, 'Grand gala de Thiès'), findsOneWidget);
      expect(texteDans(EcranAccueil, 'Gala de Fatick'), findsNothing);   // un seul gala demandé
    });

    testWidgets('sans gala annoncé : message', (tester) async {
      await tester.pumpWidget(Mbappat221App(services: servicesFactices()));
      await tester.pumpAndSettle();

      expect(texteDans(EcranAccueil, 'Aucun gala annoncé pour le moment'), findsOneWidget);
    });
  });

  group('Onglet Galas', () {
    testWidgets('affiche les galas reçus, avec l\'étiquette des galas annulés', (tester) async {
      await tester.pumpWidget(
          Mbappat221App(services: servicesFactices(galas: [_galaDeThies, _galaAnnule])));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      expect(texteDans(EcranGalas, 'Grand gala de Thiès'), findsOneWidget);
      expect(texteDans(EcranGalas, 'Samedi 21 novembre 2026'), findsOneWidget);
      expect(texteDans(EcranGalas, 'Stade Lat Dior · Thiès'), findsOneWidget);
      expect(texteDans(EcranGalas, 'Poids lourds'), findsOneWidget);
      expect(texteDans(EcranGalas, 'Gala de Fatick'), findsOneWidget);
      expect(texteDans(EcranGalas, 'ANNULÉ'), findsOneWidget);
    });

    testWidgets('liste vide : message « Aucun gala »', (tester) async {
      await tester.pumpWidget(Mbappat221App(services: servicesFactices()));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      expect(texteDans(EcranGalas, 'Aucun gala annoncé pour le moment'), findsOneWidget);
    });

    testWidgets('serveur injoignable : message et bouton Réessayer', (tester) async {
      await tester.pumpWidget(Mbappat221App(
          services: servicesFactices(erreurGalas: const ApiException('Impossible de joindre le serveur.'))));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      expect(texteDans(EcranGalas, 'Impossible de joindre le serveur.'), findsOneWidget);
      expect(texteDans(EcranGalas, 'Réessayer'), findsOneWidget);
    });
  });

  group('Fiche d\'un gala', () {
    testWidgets('un appui sur la carte ouvre la fiche ; la flèche retour la ferme', (tester) async {
      ecranHaut(tester);
      await tester.pumpWidget(Mbappat221App(services: servicesFactices(galas: [_galaDeThies])));
      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      await tester.tap(texteDans(EcranGalas, 'Grand gala de Thiès'));
      await tester.pumpAndSettle();   // attend la fin de l'animation d'ouverture

      expect(find.byType(EcranFicheGala), findsOneWidget);
      expect(texteDans(EcranFicheGala, 'Organisé par Écurie Fass'), findsOneWidget);
      expect(texteDans(EcranFicheGala, 'Mise : 1 500 000 FCFA'), findsOneWidget);
      expect(texteDans(EcranFicheGala, 'Catégories (1)'), findsOneWidget);
      expect(texteDans(EcranFicheGala, 'Poids lourds'), findsOneWidget);
      expect(texteDans(EcranFicheGala, 'Date à préciser'), findsOneWidget);
      expect(texteDans(EcranFicheGala, '1 000 000 FCFA'), findsOneWidget);
      expect(texteDans(EcranFicheGala, 'Ndèye Fatou « La Diva »'), findsOneWidget);
      expect(texteDans(EcranFicheGala, 'Cantatrice'), findsOneWidget);

      await tester.pageBack();        // appuie sur la flèche retour (≈ Navigator.pop)
      await tester.pumpAndSettle();
      expect(find.byType(EcranFicheGala), findsNothing);
    });

    testWidgets('le prochain gala de l\'accueil ouvre aussi la fiche', (tester) async {
      ecranHaut(tester);
      await tester.pumpWidget(Mbappat221App(services: servicesFactices(galas: [_galaDeThies])));
      await tester.pumpAndSettle();

      await tester.tap(texteDans(EcranAccueil, 'Grand gala de Thiès'));
      await tester.pumpAndSettle();
      expect(find.byType(EcranFicheGala), findsOneWidget);

      // Le bouton « Retour » en bas de la fiche ramène à l'accueil.
      await tester.tap(texteDans(EcranFicheGala, 'Retour'));
      await tester.pumpAndSettle();
      expect(find.byType(EcranFicheGala), findsNothing);
      expect(ongletActif(tester), 0);
    });
  });

  group('Onglet Lutteurs', () {
    Future<void> ouvrirLutteurs(WidgetTester tester) async {
      await tester.pumpWidget(
          Mbappat221App(services: servicesFactices(
              lutteurs: _lutteurs, fiches: {2: _ficheLion}, categories: _categories)));
      await tester.tap(ongletNomme('Lutteurs'));
      await tester.pumpAndSettle();
    }

    testWidgets('liste les lutteurs : surnom en gros, catégorie et écurie', (tester) async {
      await ouvrirLutteurs(tester);

      expect(texteDans(EcranLutteurs, '2 lutteurs'), findsOneWidget);
      expect(texteDans(EcranLutteurs, 'Modou Sarr'), findsOneWidget);
      expect(texteDans(EcranLutteurs, 'Poids Lourds · Écurie Fass'), findsOneWidget);
      expect(texteDans(EcranLutteurs, 'Lion de Fimela'), findsOneWidget);   // surnom
      expect(texteDans(EcranLutteurs, 'Moussa Ndiaye'), findsOneWidget);    // vrai nom en dessous
      expect(texteDans(EcranLutteurs, 'Poids Légers · Sans écurie'), findsOneWidget);
    });

    testWidgets('la recherche trouve aussi par écurie (après 400 ms sans frappe)', (tester) async {
      await ouvrirLutteurs(tester);

      await tester.enterText(
          find.descendant(of: find.byType(EcranLutteurs), matching: find.byType(TextField)), 'fass');
      await tester.pump(const Duration(milliseconds: 450));   // la minuterie de 400 ms se déclenche
      await tester.pumpAndSettle();

      expect(texteDans(EcranLutteurs, '1 lutteur'), findsOneWidget);
      expect(texteDans(EcranLutteurs, 'Modou Sarr'), findsOneWidget);
      expect(texteDans(EcranLutteurs, 'Lion de Fimela'), findsNothing);
    });

    testWidgets('le filtre par catégorie', (tester) async {
      await ouvrirLutteurs(tester);

      await tester.tap(texteDans(EcranLutteurs, 'Poids Légers'));   // la pastille du filtre
      await tester.pumpAndSettle();

      expect(texteDans(EcranLutteurs, '1 lutteur'), findsOneWidget);
      expect(texteDans(EcranLutteurs, 'Lion de Fimela'), findsOneWidget);
      expect(texteDans(EcranLutteurs, 'Modou Sarr'), findsNothing);
    });

    testWidgets('un appui sur un lutteur ouvre sa fiche : bilan et finales', (tester) async {
      ecranHaut(tester);
      await ouvrirLutteurs(tester);

      await tester.tap(texteDans(EcranLutteurs, 'Lion de Fimela'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranFicheLutteur), findsOneWidget);
      expect(texteDans(EcranFicheLutteur, 'Saison 2026-2027'), findsOneWidget);
      expect(texteDans(EcranFicheLutteur, '8'), findsOneWidget);              // points
      expect(texteDans(EcranFicheLutteur, '150 000 FCFA'), findsOneWidget);   // total gagné
      expect(texteDans(EcranFicheLutteur, '1 bœuf'), findsOneWidget);
      expect(texteDans(EcranFicheLutteur, 'Victoire contre Olympique'), findsOneWidget);
      expect(texteDans(EcranFicheLutteur, '+5 pts'), findsOneWidget);

      await tester.tap(texteDans(EcranFicheLutteur, 'Retour'));
      await tester.pumpAndSettle();
      expect(find.byType(EcranFicheLutteur), findsNothing);
    });
  });

  group('Onglet Classement', () {
    Future<void> ouvrirClassement(WidgetTester tester) async {
      ecranHaut(tester);
      await tester.pumpWidget(Mbappat221App(services: servicesFactices(
        categories: _categories,
        classements: {1: _classementLourds},
        fiches: {14: _ficheRoc},
      )));
      await tester.tap(ongletNomme('Classement'));
      await tester.pumpAndSettle();
    }

    testWidgets('la première catégorie : podium puis les suivants', (tester) async {
      await ouvrirClassement(tester);

      expect(texteDans(EcranClassement, 'Saison 2026-2027 · Poids Lourds'), findsOneWidget);
      expect(texteDans(EcranClassement, 'Bombardier Junior'), findsOneWidget);   // podium
      expect(texteDans(EcranClassement, '15 pts'), findsOneWidget);
      expect(texteDans(EcranClassement, 'Roc de Sine'), findsOneWidget);         // 4e place
      expect(texteDans(EcranClassement, '2 V · 1 D · 300 000 FCFA'), findsOneWidget);
    });

    testWidgets('une catégorie sans finale : message', (tester) async {
      await ouvrirClassement(tester);

      await tester.tap(texteDans(EcranClassement, 'Poids Légers'));
      await tester.pumpAndSettle();

      expect(texteDans(EcranClassement, 'Pas encore de classement'), findsOneWidget);
    });

    testWidgets('un appui sur un lutteur ouvre sa fiche', (tester) async {
      await ouvrirClassement(tester);

      await tester.tap(texteDans(EcranClassement, 'Roc de Sine'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranFicheLutteur), findsOneWidget);
    });
  });

  testWidgets('Accueil : le leader de chaque catégorie', (tester) async {
    await tester.pumpWidget(Mbappat221App(services: servicesFactices(
      podium: Podium(saisonLibelle: '2026-2027', categories: [
        _classementLourds,
        const Classement(categorieId: 2, categorieNom: 'Poids Légers', saisonLibelle: '2026-2027',
            lignes: []),
      ]),
    )));
    await tester.pumpAndSettle();

    expect(texteDans(EcranAccueil, 'Leaders de la saison'), findsOneWidget);
    expect(texteDans(EcranAccueil, 'Bombardier Junior'), findsOneWidget);
    expect(texteDans(EcranAccueil, '15 pts'), findsOneWidget);
    expect(texteDans(EcranAccueil, 'Poids Légers'), findsNothing);   // pas encore de leader
  });
}