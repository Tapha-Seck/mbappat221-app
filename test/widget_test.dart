// Fichier : test/widget_test.dart
// Tests de l'application entière : navigation par onglets, accueil, liste et fiche des galas.
//
// Repères Java : testWidgets ≈ @Test, expect(x, matcher) ≈ assertThat(x, matcher),
// group(...) ≈ une classe de test @Nested. GalaApiFactice ≈ un @Mock de GalaApi.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/app.dart';
import 'package:mbappat221_app/ecrans/accueil/ecran_accueil.dart';
import 'package:mbappat221_app/ecrans/galas/ecran_fiche_gala.dart';
import 'package:mbappat221_app/ecrans/galas/ecran_galas.dart';
import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/gala_api.dart';

/// Une fausse GalaApi qui répond tout de suite, sans réseau.
/// « implements GalaApi » : en Dart, toute classe sert aussi d'interface.
class GalaApiFactice implements GalaApi {
  GalaApiFactice({this.galas = const [], this.erreur});

  final List<Gala> galas;
  final ApiException? erreur;

  @override
  Future<PageResultats<Gala>> galasAVenir({int page = 0, int taille = 20}) async {
    final e = erreur;
    if (e != null) {
      throw e;
    }
    final contenu = galas.take(taille).toList();   // respecte la taille demandée (1 pour l'accueil)
    return PageResultats(
        contenu: contenu, page: 0, taille: taille, totalElements: galas.length, totalPages: 1);
  }

  @override
  String? urlFichier(String? chemin) => null;   // pas d'image réseau pendant les tests
}

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
      await tester.pumpWidget(Mbappat221App(galaApi: GalaApiFactice()));

      for (final libelle in ['Accueil', 'Galas', 'Lutteurs', 'Classement', 'Plus']) {
        expect(ongletNomme(libelle), findsOneWidget);
      }
      expect(ongletActif(tester), 0);
      expect(find.text('La lutte simple sénégalaise'), findsOneWidget);
    });

    testWidgets('un appui sur un onglet change l\'écran affiché', (tester) async {
      await tester.pumpWidget(Mbappat221App(galaApi: GalaApiFactice()));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();   // attend la fin des animations
      expect(ongletActif(tester), 1);

      await tester.tap(ongletNomme('Classement'));
      await tester.pumpAndSettle();
      expect(ongletActif(tester), 3);
    });

    testWidgets('l\'onglet Plus affiche un message au toucher', (tester) async {
      await tester.pumpWidget(Mbappat221App(galaApi: GalaApiFactice()));

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
          Mbappat221App(galaApi: GalaApiFactice(galas: [_galaDeThies, _galaAnnule])));
      await tester.pumpAndSettle();

      expect(texteDans(EcranAccueil, 'Grand gala de Thiès'), findsOneWidget);
      expect(texteDans(EcranAccueil, 'Gala de Fatick'), findsNothing);   // un seul gala demandé
    });

    testWidgets('sans gala annoncé : message', (tester) async {
      await tester.pumpWidget(Mbappat221App(galaApi: GalaApiFactice()));
      await tester.pumpAndSettle();

      expect(texteDans(EcranAccueil, 'Aucun gala annoncé pour le moment'), findsOneWidget);
    });
  });

  group('Onglet Galas', () {
    testWidgets('affiche les galas reçus, avec l\'étiquette des galas annulés', (tester) async {
      await tester.pumpWidget(
          Mbappat221App(galaApi: GalaApiFactice(galas: [_galaDeThies, _galaAnnule])));

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
      await tester.pumpWidget(Mbappat221App(galaApi: GalaApiFactice()));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      expect(texteDans(EcranGalas, 'Aucun gala annoncé pour le moment'), findsOneWidget);
    });

    testWidgets('serveur injoignable : message et bouton Réessayer', (tester) async {
      await tester.pumpWidget(Mbappat221App(
          galaApi: GalaApiFactice(erreur: const ApiException('Impossible de joindre le serveur.'))));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      expect(texteDans(EcranGalas, 'Impossible de joindre le serveur.'), findsOneWidget);
      expect(texteDans(EcranGalas, 'Réessayer'), findsOneWidget);
    });
  });

  group('Fiche d\'un gala', () {
    testWidgets('un appui sur la carte ouvre la fiche ; la flèche retour la ferme', (tester) async {
      ecranHaut(tester);
      await tester.pumpWidget(Mbappat221App(galaApi: GalaApiFactice(galas: [_galaDeThies])));
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
      await tester.pumpWidget(Mbappat221App(galaApi: GalaApiFactice(galas: [_galaDeThies])));
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
}