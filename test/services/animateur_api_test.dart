// Fichier : test/services/animateur_api_test.dart

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/services/animateur_api.dart';
import 'package:mbappat221_app/services/client_api.dart';

http.Response _json(String corps) => http.Response.bytes(utf8.encode(corps), 200,
    headers: {'content-type': 'application/json'});

const _diva = '{"id": 3, "nom": "Ndèye Fatou", "surnom": "La Diva", "role": "CANTATRICE", "region": "Fatick", '
    '"apercu": null, "biographie": null, "telephone": "77 123 45 67", "photoUrl": null, "photos": []}';

void main() {
  test('lister : filtre par rôle envoyé en MAJUSCULES', () async {
    final urls = <String>[];
    final api = AnimateurApi(ClientApi(
      client: MockClient((requete) async {
        urls.add(requete.url.toString());
        return _json('[$_diva]');
      }),
      urlBase: 'http://test',
    ));

    final animateurs = await api.lister(role: RoleAnimateur.cantatrice);

    expect(urls.single, 'http://test/api/animateurs?role=CANTATRICE');
    expect(animateurs.single.nomAffiche, 'La Diva');
    expect(animateurs.single.roleEtRegion, 'Cantatrice · Fatick');
    expect(animateurs.single.telephone, '77 123 45 67');
  });

  test('profil : l\'animateur et ses galas', () async {
    final api = AnimateurApi(ClientApi(
      client: MockClient((requete) async => _json('{"animateur": $_diva, "galas": ['
          '{"id": 1, "nom": "LAMB CENTRE VILLE", "dateDebut": "2027-01-08", "dateFin": "2027-01-11", '
          '"lieu": "Fimela", "region": "Fatick", "statut": "ANNONCE"}]}')),
      urlBase: 'http://test',
    ));

    final profil = await api.profil(3);

    expect(profil.animateur.nom, 'Ndèye Fatou');
    expect(profil.galas.single.statut, StatutGala.annonce);
    expect(profil.galas.single.dateDebut, DateTime(2027, 1, 8));
  });

  test('une Tv Tv : rôle TV et lien de sa chaîne', () async {
    final api = AnimateurApi(ClientApi(
      client: MockClient((requete) async => _json('[{"id": 5, "nom": "Lamb Simple TV", "surnom": null, '
          '"role": "TV", "region": "Dakar", "apercu": null, "biographie": null, "telephone": null, '
          '"youtubeUrl": "https://www.youtube.com/@LambSimpleTV", "photoUrl": null, "photos": []}]')),
      urlBase: 'http://test',
    ));

    final tv = (await api.lister(role: RoleAnimateur.tv)).single;

    expect(tv.role, RoleAnimateur.tv);
    expect(tv.role.libelle, 'Tv Tv');
    expect(tv.youtubeUrl, 'https://www.youtube.com/@LambSimpleTV');
  });
}