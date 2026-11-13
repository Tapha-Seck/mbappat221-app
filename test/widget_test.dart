// Fichier : test/widget_test.dart
// Premier test Flutter : vérifie l'écran de bienvenue de Mbappat 221.
//
// Repères pour un développeur Java :
//  - test/ joue le rôle de src/test/java ; on lance les tests avec « flutter test » (comme « mvn test »).
//  - testWidgets(...) ≈ une méthode @Test de JUnit.
//  - expect(valeur, matcher) ≈ assertThat(valeur, matcher) d'AssertJ / Hamcrest.
//  - « async / await » : le test attend que Flutter ait fini de dessiner (comme un Future.get() en Java).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/main.dart';   // la classe testée (comme un import de sn.lutte...)

void main() {
  testWidgets('Le bouton « Allez ! » fait monter le compteur', (WidgetTester tester) async {
    // 1. Afficher l'application dans un écran virtuel (pas besoin de téléphone ni de Chrome).
    await tester.pumpWidget(const Mbappat221App());

    // 2. Vérifier l'état de départ : find.text cherche un widget Text avec ce contenu exact.
    expect(find.text('Mbappat 221'), findsOneWidget);
    expect(find.text('0 « Allez ! »'), findsOneWidget);

    // 3. Appuyer sur le bouton (trouvé grâce à son icône), puis redessiner l'écran.
    await tester.tap(find.byIcon(Icons.sports_kabaddi));
    await tester.pump();   // pump() = « dessine l'image suivante » (setState a demandé un nouveau build)

    // 4. Le compteur est passé à 1.
    expect(find.text('0 « Allez ! »'), findsNothing);
    expect(find.text('1 « Allez ! »'), findsOneWidget);
  });
}