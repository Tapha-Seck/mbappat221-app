// Fichier : test/services/lutteur_api_test.dart
// LutteurApi et ReferentielApi sans serveur (MockClient joue le rôle du backend).

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/lutteur_api.dart';
import 'package:mbappat221_app/services/referentiel_api.dart';

http.Response _json(String corps) => http.Response.bytes(utf8.encode(corps), 200,
    headers: {'content-type': 'application/json'});

const _pageLutteurs = r'''
{
  "contenu": [
    {"id": 5, "nom": "Moussa Ndiaye", "surnom": "Lion de Fimela", "categorieId": 2,
     "categorieNom": "Poids Légers", "ecurieNom": null, "region": "Fatick", "photoUrl": null}
  ],
  "page": 0, "taille": 20, "totalElements": 1, "totalPages": 1
}
''';

void main() {
  test('rechercher : envoie le texte et la catégorie, lit la page', () async {
    final urls = <String>[];   // les adresses appelées (≈ un ArgumentCaptor)
    final api = LutteurApi(ClientApi(
      client: MockClient((requete) async {
        urls.add(requete.url.toString());
        return _json(_pageLutteurs);
      }),
      urlBase: 'http://test',
    ));

    final page = await api.rechercher(recherche: ' lion ', categorieId: 2);

    expect(urls.single, 'http://test/api/lutteurs?recherche=lion&categorieId=2&page=0&taille=20');
    final lutteur = page.contenu.single;
    expect(lutteur.nomAffiche, 'Lion de Fimela');
    expect(lutteur.categorieEtEcurie, 'Poids Légers · Sans écurie');
  });

  test('rechercher : une seule lettre n\'est pas envoyée (trop vague)', () async {
    final urls = <String>[];
    final api = LutteurApi(ClientApi(
      client: MockClient((requete) async {
        urls.add(requete.url.toString());
        return _json(_pageLutteurs);
      }),
      urlBase: 'http://test',
    ));

    await api.rechercher(recherche: 'l');

    expect(urls.single, 'http://test/api/lutteurs?page=0&taille=20');
  });

  test('catégories : lues une seule fois, puis gardées en mémoire', () async {
    var appels = 0;
    final api = ReferentielApi(ClientApi(
      client: MockClient((requete) async {
        appels++;
        return _json('[{"id": 1, "nom": "Poids Lourds", "ordre": 1}, '
            '{"id": 2, "nom": "Poids Légers", "ordre": 2}]');
      }),
      urlBase: 'http://test',
    ));

    final premieres = await api.categories();
    final secondes = await api.categories();

    expect(premieres.map((c) => c.nom), ['Poids Lourds', 'Poids Légers']);
    expect(secondes, same(premieres));   // même liste, sans nouvel appel
    expect(appels, 1);
  });
}
