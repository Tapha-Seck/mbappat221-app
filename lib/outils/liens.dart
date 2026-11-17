// Fichier : lib/outils/liens.dart
// Ouvrir un lien avec l'application du téléphone qui sait le traiter :
// « tel: » → composeur d'appel, « https://wa.me/... » → WhatsApp, « https://youtube.com/... » → YouTube.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre [lien] ; en cas d'échec, un petit message en bas de l'écran.
Future<void> ouvrirLien(BuildContext context, Uri lien) async {
  // On récupère le ScaffoldMessenger AVANT l'await : après, l'écran a pu être fermé.
  final messages = ScaffoldMessenger.of(context);
  var ouvert = false;
  try {
    // externalApplication : ouvre l'application YouTube / WhatsApp si elle est installée.
    ouvert = await launchUrl(lien, mode: LaunchMode.externalApplication);
  } catch (_) {
    ouvert = false;
  }
  if (!ouvert) {
    messages.showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir ce lien sur cet appareil.')));
  }
}
