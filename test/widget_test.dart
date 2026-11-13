// Fichier : test/widget_test.dart
// Tests de la structure F1 : la barre de 5 onglets et la navigation entre eux.
//
// Repères Java : testWidgets ≈ @Test, expect(x, matcher) ≈ assertThat(x, matcher),
// group(...) ≈ une classe de test @Nested qui regroupe des tests liés.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/app.dart';

/// Trouve un libellé DANS la barre d'onglets uniquement.
/// (Le mot « Galas » apparaît aussi comme titre de l'écran Galas : sans cette précision,
/// le test trouverait plusieurs « Galas » et ne saurait pas sur lequel appuyer.)
Finder ongletNomme(String libelle) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(libelle));

/// Lit l'onglet actuellement sélectionné dans la barre.
int ongletActif(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

void main() {
  group('Navigation principale', () {
    testWidgets('affiche les 5 onglets et démarre sur Accueil', (tester) async {
      await tester.pumpWidget(const Mbappat221App());

      for (final libelle in ['Accueil', 'Galas', 'Lutteurs', 'Classement', 'Plus']) {
        expect(ongletNomme(libelle), findsOneWidget);
      }
      expect(ongletActif(tester), 0);
      expect(find.text('La lutte simple sénégalaise'), findsOneWidget);
    });

    testWidgets('un appui sur un onglet change l\'écran affiché', (tester) async {
      await tester.pumpWidget(const Mbappat221App());

      await tester.tap(ongletNomme('Galas'));
      await tester.pumpAndSettle();   // attend la fin des animations
      expect(ongletActif(tester), 1);

      await tester.tap(ongletNomme('Classement'));
      await tester.pumpAndSettle();
      expect(ongletActif(tester), 3);
    });

    testWidgets('l\'onglet Plus affiche un message au toucher', (tester) async {
      await tester.pumpWidget(const Mbappat221App());

      await tester.tap(ongletNomme('Plus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nous contacter'));
      await tester.pump();   // le SnackBar apparaît

      expect(find.text('Cette rubrique arrive bientôt.'), findsOneWidget);
    });
  });
}