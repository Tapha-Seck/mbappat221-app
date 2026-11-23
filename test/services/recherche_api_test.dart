// Fichier : test/services/recherche_api_test.dart

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/recherche_api.dart';

http.Response _json(String corps) => http.Response.bytes(utf8.encode(corps), 200,
    headers: {'content-type': 'application/json'});

/// Une page JSON (même format que PageDto du backend).
String _page(String contenu, int total) =>
    '{"contenu": [$contenu], "page": 0, "taille": 5, "totalElements": $total, "totalPages": ${(total + 4) ~/ 5}}';

void main() {
  test('rechercher : un seul appel, les 3 rubriques et leurs totaux', () async {
    final urls = <String>[];
    final api = RechercheApi(ClientApi(
      client: MockClient((requete) async {
        urls.add(requete.url.toString());
        return _json('{"texte": "fass", '
            '"lutteurs": ${_page('{"id": 1, "nom": "Modou Sarr", "surnom": null, "categorieId": 4, '
                '"categorieNom": "Poids Lourds", "ecurieNom": "Fass", "region": "Dakar", "photoUrl": null}', 12)}, '
            '"galas": ${_page('', 0)}, '
            '"animateurs": ${_page('{"id": 4, "nom": "Fass Griot", "surnom": null, "role": "GRIOT", '
                '"region": null, "apercu": null, "biographie": null, "telephone": null, "youtubeUrl": null, '
                '"photoUrl": null, "photos": []}', 1)}}');
      }),
      urlBase: 'http://test',
    ));

    final resultat = await api.rechercher('  fass ');

    expect(urls.single, 'http://test/api/recherche?q=fass');   // espaces retirés
    expect(resultat.lutteurs.contenu.single.ecurieNom, 'Fass');
    expect(resultat.lutteurs.totalElements, 12);
    expect(resultat.galas.contenu, isEmpty);
    expect(resultat.animateurs.contenu.single.role, RoleAnimateur.griot);
    expect(resultat.estVide, isFalse);
  });
}
