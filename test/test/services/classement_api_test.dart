// Fichier : test/services/classement_api_test.dart

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mbappat221_app/services/classement_api.dart';
import 'package:mbappat221_app/services/client_api.dart';

void main() {
  test('classement : lignes, rangs ex aequo et lutteur', () async {
    final api = ClassementApi(ClientApi(
      client: MockClient((requete) async {
        expect(requete.url.toString(), 'http://test/api/classements?categorieId=4');
        return http.Response.bytes(utf8.encode('''
{
  "categorieId": 4, "categorieNom": "Poids Légers", "saisonId": 1, "saisonLibelle": "2026-2027",
  "lignes": [
    {"rang": 1, "lutteur": {"id": 5, "nom": "Moussa Ndiaye", "surnom": "Lion de Fimela"},
     "points": 8, "victoires": 1, "defaites": 1, "finales": 2, "totalGagne": 150000},
    {"rang": 1, "lutteur": {"id": 6, "nom": "Moussa Sarr", "surnom": null},
     "points": 8, "victoires": 1, "defaites": 1, "finales": 2, "totalGagne": 150000}
  ]
}'''), 200, headers: {'content-type': 'application/json'});
      }),
      urlBase: 'http://test',
    ));

    final classement = await api.classement(4);

    expect(classement.categorieNom, 'Poids Légers');
    expect(classement.lignes.map((l) => l.rang), [1, 1]);   // égalité parfaite : même rang
    expect(classement.leader?.nomAffiche, 'Lion de Fimela');
    expect(classement.lignes.last.nomAffiche, 'Moussa Sarr');
    expect(classement.lignes.first.bilanCourt, '1 V · 1 D');
  });
}