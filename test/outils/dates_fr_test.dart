// Fichier : test/outils/dates_fr_test.dart
// Tests unitaires simples (sans écran) : test() ≈ @Test, expect ≈ assertEquals.

import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/outils/dates_fr.dart';

void main() {
  group('DatesFr.periode', () {
    test('un seul jour : jour de la semaine, date complète', () {
      final samedi = DateTime(2026, 11, 21);
      expect(DatesFr.periode(samedi, samedi), 'samedi 21 novembre 2026');
    });

    test('le 1er du mois s\'écrit « 1er »', () {
      final dimanche = DateTime(2026, 11, 1);
      expect(DatesFr.periode(dimanche, dimanche), 'dimanche 1er novembre 2026');
    });

    test('deux jours du même mois', () {
      expect(DatesFr.periode(DateTime(2026, 11, 21), DateTime(2026, 11, 22)),
          'du 21 au 22 novembre 2026');
    });

    test('à cheval sur deux mois', () {
      expect(DatesFr.periode(DateTime(2026, 11, 30), DateTime(2026, 12, 1)),
          'du 30 novembre au 1er décembre 2026');
    });

    test('à cheval sur deux années', () {
      expect(DatesFr.periode(DateTime(2026, 12, 31), DateTime(2027, 1, 1)),
          'du 31 décembre 2026 au 1er janvier 2027');
    });
  });

  test('majuscule et mois court', () {
    expect(DatesFr.majuscule('samedi 21 novembre 2026'), 'Samedi 21 novembre 2026');
    expect(DatesFr.majuscule(''), '');
    expect(DatesFr.moisCourt(DateTime(2026, 2, 3)), 'févr.');
  });
}