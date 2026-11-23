// Fichier : test/services/gala_api_test.dart
// Teste GalaApi SANS serveur : MockClient (fourni par le package http) joue le rôle du backend.
// Équivalent Spring : MockRestServiceServer, ou un @Mock du RestClient avec Mockito.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/gala_api.dart';

/// Une réponse identique à celle de GET /api/galas/a-venir (PageDto<GalaCalendrierDto>).
/// Chaîne « raw » r'''...''' : les $ et \ ne sont pas interprétés (pratique pour du JSON).
const _jsonCalendrier = r'''
{
  "contenu": [
    {
      "id": 7,
      "nom": "Grand gala de Thiès",
      "dateDebut": "2026-11-21",
      "dateFin": "2026-11-22",
      "lieu": "Stade Lat Dior",
      "region": "Thiès",
      "organisateur": "Écurie Fass",
      "animateurs": [
        {"id": 3, "nom": "Ndèye Fatou", "surnom": "La Diva", "role": "CANTATRICE", "photoUrl": null}
      ],
      "infosComplementaires": null,
      "statut": "ANNONCE",
      "mise": "1 500 000 FCFA",
      "miseTotale": 1500000,
      "afficheUrl": "/fichiers/galas/7/affiche.jpg",
      "drapeaux": [
        {"categorieNom": "Poids lourds", "categorieOrdre": 1, "date": "2026-11-22", "heure": "17:00:00", "montantAnnonce": 1000000},
        {"categorieNom": "Poids légers", "categorieOrdre": 3, "date": null, "heure": null, "montantAnnonce": null}
      ]
    }
  ],
  "page": 0,
  "taille": 20,
  "totalElements": 1,
  "totalPages": 1
}
''';

void main() {
  test('lit la page de galas à venir, accents compris', () async {
    // Le faux serveur vérifie la requête reçue, puis renvoie le JSON en UTF-8
    // SANS préciser le jeu de caractères (le cas piège pour les accents).
    final faux = MockClient((requete) async {
      expect(requete.url.toString(), 'http://test/api/galas/a-venir?page=0&taille=20');
      return http.Response.bytes(utf8.encode(_jsonCalendrier), 200,
          headers: {'content-type': 'application/json'});
    });
    final api = GalaApi(ClientApi(client: faux, urlBase: 'http://test'));

    final page = await api.galasAVenir();

    expect(page.totalElements, 1);
    expect(page.estLaDerniere, isTrue);
    final gala = page.contenu.single;
    expect(gala.nom, 'Grand gala de Thiès');
    expect(gala.region, 'Thiès');
    expect(gala.statut, StatutGala.annonce);
    expect(gala.dateDebut, DateTime(2026, 11, 21));
    expect(gala.mise, '1 500 000 FCFA');
    expect(gala.animateurs.single.role, RoleAnimateur.cantatrice);
    expect(gala.animateurs.single.nomAffiche, 'Ndèye Fatou « La Diva »');
    expect(gala.drapeaux.first.montantAnnonce, 1000000);
    expect(gala.drapeaux.first.heureCourte, '17:00');
    expect(gala.drapeaux.last.date, isNull);
    expect(api.urlFichier(gala.afficheUrl), 'http://test/fichiers/galas/7/affiche.jpg');
  });

  test('une erreur du serveur devient une ApiException lisible', () async {
    final faux = MockClient((requete) async => http.Response('panne', 500));
    final api = GalaApi(ClientApi(client: faux, urlBase: 'http://test'));

    // throwsA(isA<ApiException>()) ≈ assertThrows(ApiException.class, ...) en JUnit.
    await expectLater(api.galasAVenir(), throwsA(isA<ApiException>()));
  });

  test('pas d\'affiche : pas d\'URL', () {
    final api = GalaApi(ClientApi(client: MockClient((_) async => http.Response('', 200))));
    expect(api.urlFichier(null), isNull);
  });

  test('galas terminés : la bonne adresse', () async {
    final faux = MockClient((requete) async {
      expect(requete.url.toString(), 'http://test/api/galas/resultats?page=0&taille=20');
      return http.Response.bytes(utf8.encode(_jsonCalendrier), 200,
          headers: {'content-type': 'application/json'});
    });
    final api = GalaApi(ClientApi(client: faux, urlBase: 'http://test'));

    final page = await api.galasTermines();

    expect(page.contenu.single.nom, 'Grand gala de Thiès');
  });

  test('résultats d\'un gala : points, finale saisie ou non', () async {
    // Extrait de GET /api/galas/7 (GalaPublicDto) : seuls les champs lus par ResultatsGala comptent.
    const json = r'''
    {
      "id": 7, "nom": "Grand gala de Thiès", "statut": "TERMINE",
      "pointsVainqueur": 30, "pointsPerdant": 12,
      "categories": [
        {"categorieNom": "Poids légers", "categorieOrdre": 3, "date": null, "heure": null,
         "montantAnnonce": null, "finale": null},
        {"categorieNom": "Poids lourds", "categorieOrdre": 4, "date": "2026-11-22", "heure": "17:00:00",
         "montantAnnonce": 1000000,
         "finale": {
           "vainqueur": {"id": 2, "nom": "Moussa Ndiaye", "surnom": "Lion de Fimela"},
           "gainVainqueur": "700 000 FCFA + 1 cheval",
           "perdant": {"id": 1, "nom": "Modou Sarr", "surnom": null},
           "gainPerdant": "—"
         }}
      ]
    }
    ''';
    final faux = MockClient((requete) async {
      expect(requete.url.toString(), 'http://test/api/galas/7');
      return http.Response.bytes(utf8.encode(json), 200, headers: {'content-type': 'application/json'});
    });
    final api = GalaApi(ClientApi(client: faux, urlBase: 'http://test'));

    final resultats = await api.resultats(7);

    expect(resultats.pointsVainqueur, 30);
    expect(resultats.aDesResultats, isTrue);
    expect(resultats.categories.first.finale, isNull);
    final finale = resultats.categories.last.finale!;   // « ! » : on affirme qu'il n'est pas null
    expect(finale.vainqueur.nomAffiche, 'Lion de Fimela');
    expect(finale.perdant.nomAffiche, 'Modou Sarr');
    expect(finale.gainVainqueur, '700 000 FCFA + 1 cheval');
    expect(resultats.categories.last.drapeau.heureCourte, '17:00');
  });
}