// Fichier : lib/main.dart
// Point d'entrée de Mbappat 221. Il ne fait plus qu'une chose : lancer l'application.
// (Comme la classe LutteSimpleApiApplication du backend : un main() court, la configuration est ailleurs.)

import 'package:flutter/material.dart';

// Import « package: » = chemin depuis le dossier lib/ du projet.
// C'est l'équivalent d'un import Java complet : import sn.lutte.config.MaClasse;
import 'package:mbappat221_app/app.dart';

void main() {
  runApp(const Mbappat221App());
}