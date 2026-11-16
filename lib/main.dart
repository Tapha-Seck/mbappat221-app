// Fichier : lib/main.dart
// Point d'entrée de Mbappat 221 : crée les services, puis lance l'application.
// (Comme la classe LutteSimpleApiApplication du backend, sauf qu'ici on assemble les objets
//  nous-mêmes : il n'y a pas de conteneur Spring qui le fait automatiquement.)

import 'package:flutter/material.dart';

import 'package:mbappat221_app/app.dart';
import 'package:mbappat221_app/services/services_api.dart';

void main() {
  runApp(Mbappat221App(services: ServicesApi.reels()));
}