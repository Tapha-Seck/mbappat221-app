// Fichier : test/outils/telephone_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/outils/telephone.dart';

void main() {
  test('toutes les façons de saisir un numéro donnent la même forme', () {
    for (final saisie in ['77 123 45 67', '771234567', '+221 77 123 45 67', '00221 77-123-45-67']) {
      expect(Telephone.international(saisie), '221771234567', reason: saisie);
      expect(Telephone.affichage(saisie), '77 123 45 67', reason: saisie);
    }
  });

  test('liens d\'appel et WhatsApp', () {
    expect(Telephone.lienAppel('77 123 45 67').toString(), 'tel:+221771234567');
    expect(Telephone.lienWhatsApp('77 123 45 67').toString(), 'https://wa.me/221771234567');
  });

  test('un numéro étranger est affiché tel quel', () {
    expect(Telephone.affichage('+33 6 12 34 56 78'), '+33 6 12 34 56 78');
  });
}