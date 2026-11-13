// Fichier : lib/main.dart
// Point d'entrée de l'application Mbappat 221 (étape F0 : un premier écran pour apprendre).
//
// Repères pour un développeur Java :
//  - Dart ressemble beaucoup à Java : classes, types, ; en fin de ligne, // pour les commentaires.
//  - Pas besoin de « public » : tout est public, sauf ce qui commence par _ (privé au fichier).
//  - import 'package:...' joue le rôle de import java.util.... ;

import 'package:flutter/material.dart';   // les composants visuels « Material » (boutons, textes...)

/// Comme « public static void main(String[] args) » en Java : c'est ici que tout commence.
/// runApp() affiche le widget racine de l'application.
void main() {
  runApp(const Mbappat221App());
}

/// Les couleurs de Mbappat 221 (les mêmes que le back-office).
/// « abstract final class » + champs « static const » : l'équivalent d'une classe de constantes Java.
abstract final class Couleurs {
  static const or = Color(0xFFFAB724);        // 0xFF = opaque, puis FAB724 (le jaune or du logo)
  static const noir = Color(0xFF050301);
  static const orTexte = Color(0xFF8A6100);
  static const fond = Color(0xFFF6F3EC);
}

/// En Flutter, TOUT est un « widget » : l'application, un écran, un texte, une marge...
/// Un StatelessWidget n'a pas d'état qui change : il se dessine à partir de ses paramètres.
/// (Comparaison : un composant « immuable », un peu comme un record Java.)
class Mbappat221App extends StatelessWidget {
  // « const » : le widget peut être créé une seule fois à la compilation (plus rapide).
  // {super.key} : un paramètre NOMMÉ ; en Dart, les paramètres entre { } se passent par leur nom.
  const Mbappat221App({super.key});

  /// build() décrit ce qu'il faut afficher. Flutter l'appelle à chaque fois que l'écran doit être redessiné.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mbappat 221',
      debugShowCheckedModeBanner: false,      // enlève le bandeau « DEBUG » en haut à droite
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Couleurs.or, surface: Couleurs.fond),
        scaffoldBackgroundColor: Couleurs.fond,
        useMaterial3: true,
      ),
      home: const EcranBienvenue(),            // le premier écran affiché
    );
  }
}

/// Un écran avec un état qui change : le nombre de « Allez ! » encouragés.
/// StatefulWidget = le widget (immuable) + un objet State (qui, lui, garde les données qui changent).
class EcranBienvenue extends StatefulWidget {
  const EcranBienvenue({super.key});

  @override
  State<EcranBienvenue> createState() => _EcranBienvenueState();
// « => expression » : raccourci pour { return expression; } (comme une lambda Java).
}

/// Le _ au début du nom : classe PRIVÉE à ce fichier (l'équivalent de « private » en Java).
class _EcranBienvenueState extends State<EcranBienvenue> {
  int _encouragements = 0;   // champ privé, comme « private int encouragements = 0; »

  void _encourager() {
    // setState() prévient Flutter que l'état a changé : il rappelle build() pour redessiner.
    // Sans setState, la variable change mais l'écran ne bouge pas !
    setState(() {
      _encouragements++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold = la « charpente » d'un écran : barre du haut, contenu, bouton flottant...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mbappat 221', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
      ),
      // Center centre son enfant ; Column empile ses enfants verticalement (comme un BoxLayout vertical).
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,   // centré verticalement
          children: [
            const Text('La lutte simple sénégalaise',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),                       // un espace vide de 8 pixels
            const Text('par Sérère Réfoum', style: TextStyle(color: Couleurs.orTexte)),
            const SizedBox(height: 32),
            // Interpolation de chaîne : '$variable' dans le texte (comme String.format en Java, en plus simple).
            Text('$_encouragements « Allez ! »',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _encourager,              // on passe la MÉTHODE elle-même (comme this::encourager en Java)
        backgroundColor: Couleurs.or,
        foregroundColor: Couleurs.noir,
        icon: const Icon(Icons.sports_kabaddi),
        label: const Text('Allez !'),
      ),
    );
  }
}