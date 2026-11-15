// Fichier : test/outils/montants_fr_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/outils/montants_fr.dart';

void main() {
  test('groupe les chiffres par 3, comme le backend', () {
    expect(MontantsFr.fcfa(0), '0 FCFA');
    expect(MontantsFr.fcfa(700), '700 FCFA');
    expect(MontantsFr.fcfa(1000), '1 000 FCFA');
    expect(MontantsFr.fcfa(150000), '150 000 FCFA');
    expect(MontantsFr.fcfa(1500000), '1 500 000 FCFA');
    expect(MontantsFr.fcfa(-25000), '-25 000 FCFA');
  });
}