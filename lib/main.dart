// Fichier : lib/main.dart
// Point d'entrée de Mbappat 221 : crée les services, puis lance l'application.
// (Comme la classe LutteSimpleApiApplication du backend, sauf qu'ici on assemble les objets
//  nous-mêmes : il n'y a pas de conteneur Spring qui le fait automatiquement.)

import 'package:flutter/material.dart';

import 'package:mbappat221_app/app.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/gala_api.dart';

void main() {
  // Un seul client HTTP pour toute l'application : il réutilise les connexions (plus rapide).
  final clientApi = ClientApi();

  runApp(Mbappat221App(galaApi: GalaApi(clientApi)));
}