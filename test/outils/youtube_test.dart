// Fichier : test/outils/youtube_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:mbappat221_app/outils/youtube.dart';

void main() {
  test('reconnaît une adresse de chaîne', () {
    expect(YouTube.estUneChaine('https://www.youtube.com/@SerereRefoum'), isTrue);
    expect(YouTube.estUneChaine('https://youtube.com/channel/UC1234'), isTrue);
    expect(YouTube.estUneChaine('https://m.youtube.com/c/LambSimple'), isTrue);
    expect(YouTube.estUneChaine('https://youtu.be/abcd'), isFalse);                     // une vidéo
    expect(YouTube.estUneChaine('https://www.youtube.com/watch?v=abcd'), isFalse);      // une vidéo
  });

  test('le lien « S\'abonner » ajoute sub_confirmation=1 et garde les autres paramètres', () {
    expect(YouTube.lienAbonnement('https://www.youtube.com/@SerereRefoum').toString(),
        'https://www.youtube.com/@SerereRefoum?sub_confirmation=1');
    expect(YouTube.lienAbonnement('https://www.youtube.com/@SerereRefoum?si=x').toString(),
        'https://www.youtube.com/@SerereRefoum?si=x&sub_confirmation=1');
  });
}