// Fichier : lib/main.dart
// Point d'entrée de Mbappat 221 : crée les services, regarde si la présentation a déjà été vue,
// puis lance l'application.
//
// Nouveau concept : SharedPreferences, un petit stockage clé → valeur gardé sur le téléphone
// (et dans le navigateur pour la version web). Il survit à la fermeture de l'application.
// Équivalent Java : java.util.prefs.Preferences, ou un petit fichier de configuration.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbappat221_app/app.dart';
import 'package:mbappat221_app/services/services_api.dart';

/// La clé sous laquelle on retient que la présentation a été vue.
const _clePresentationVue = 'presentation_vue';

/// « async » : main peut attendre (await) la lecture des préférences avant d'afficher l'application.
Future<void> main() async {
  // Obligatoire avant d'utiliser un plugin (SharedPreferences) avant runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final dejaVue = preferences.getBool(_clePresentationVue) ?? false;   // null au premier lancement

  runApp(Mbappat221App(
    services: ServicesApi.reels(),
    afficherPresentation: !dejaVue,
    surPresentationVue: () => preferences.setBool(_clePresentationVue, true),
  ));
}