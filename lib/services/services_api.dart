// Fichier : lib/services/services_api.dart
// Regroupe tous les services de l'application dans un seul objet, transmis aux écrans.
//
// Pourquoi ? Avec un service par sujet (galas, lutteurs, classement, animateurs, catégories, recherche...),
// passer chaque service séparément d'écran en écran devient lourd. On passe ce « sac » à la place.
// Équivalent Spring : un petit ApplicationContext écrit à la main (ici, pas d'injection automatique).

import 'package:mbappat221_app/services/animateur_api.dart';
import 'package:mbappat221_app/services/classement_api.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/gala_api.dart';
import 'package:mbappat221_app/services/lutteur_api.dart';
import 'package:mbappat221_app/services/recherche_api.dart';
import 'package:mbappat221_app/services/referentiel_api.dart';

class ServicesApi {
  const ServicesApi({
    required this.galas,
    required this.lutteurs,
    required this.classements,
    required this.animateurs,
    required this.referentiel,
    required this.recherche,
  });

  /// Les vrais services, branchés sur le serveur (utilisé par main.dart).
  /// Un seul ClientApi partagé : il réutilise les connexions HTTP.
  factory ServicesApi.reels() {
    final client = ClientApi();
    return ServicesApi(
      galas: GalaApi(client),
      lutteurs: LutteurApi(client),
      classements: ClassementApi(client),
      animateurs: AnimateurApi(client),
      referentiel: ReferentielApi(client),
      recherche: RechercheApi(client),
    );
  }

  final GalaApi galas;
  final LutteurApi lutteurs;
  final ClassementApi classements;
  final AnimateurApi animateurs;
  final ReferentielApi referentiel;
  final RechercheApi recherche;   // la loupe de l'accueil
}