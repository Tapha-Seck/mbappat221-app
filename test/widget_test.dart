// Fichier : test/widget_test.dart
// Tests de l'application entière : la navigation par onglets et l'onglet Galas.
//
// Repères Java : testWidgets ≈ @Test, expect(x, matcher) ≈ assertThat(x, matcher),
// group(...) ≈ une classe de test @Nested. GalaApiFactice ≈ un @Mock de GalaApi.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/app.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/gala_api.dart';

/// Une fausse GalaApi qui répond tout de suite, sans réseau.
/// « implements GalaApi » : en Dart, toute classe sert aussi d'interface (pas besoin d'écrire une interface à part).
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
    return PageResultats(
        contenu: galas, page: 0, taille: taille, totalElements: galas.length, totalPages: 1);
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
  drapeaux: const [DrapeauCalendrier(categorieNom: 'Poids lourds', categorieOrdre: 1)],
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
/// (Le mot « Galas » peut apparaître ailleurs : sans cette précision, le test trouverait
/// plusieurs « Galas » et ne saurait pas sur lequel appuyer.)
Finder ongletNomme(String libelle) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(libelle));

/// Lit l'onglet actuellement sélectionné dans la barre.
int ongletActif(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

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

  group('Onglet Galas', () {
    testWidgets('affiche les galas reçus, avec l\'étiquette des galas annulés', (tester) async {
      await tester.pumpWidget(
          Mbappat221App(galaApi: GalaApiFactice(galas: [_galaDeThies, _galaAnnule])));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      expect(find.text('Grand gala de Thiès'), findsOneWidget);
      expect(find.text('Samedi 21 novembre 2026'), findsOneWidget);
      expect(find.text('Stade Lat Dior · Thiès'), findsOneWidget);
      expect(find.text('Poids lourds'), findsOneWidget);
      expect(find.text('Gala de Fatick'), findsOneWidget);
      expect(find.text('ANNULÉ'), findsOneWidget);
    });

    testWidgets('liste vide : message « Aucun gala »', (tester) async {
      await tester.pumpWidget(Mbappat221App(galaApi: GalaApiFactice()));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      expect(find.text('Aucun gala annoncé pour le moment'), findsOneWidget);
    });

    testWidgets('serveur injoignable : message et bouton Réessayer', (tester) async {
      await tester.pumpWidget(Mbappat221App(
          galaApi: GalaApiFactice(erreur: const ApiException('Impossible de joindre le serveur.'))));

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();

      expect(find.text('Impossible de joindre le serveur.'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });
}