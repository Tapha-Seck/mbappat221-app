// Fichier : lib/widgets/ecran_en_construction.dart
// Un écran générique « bientôt disponible », réutilisé par les onglets pas encore développés.
// Réutiliser un widget avec des paramètres = l'équivalent d'un fragment Thymeleaf avec arguments.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/theme/couleurs.dart';

class EcranEnConstruction extends StatelessWidget {
  // Paramètres « required » : obligatoires, passés par leur nom à l'appel :
  //   EcranEnConstruction(titre: 'Galas', icone: Icons.event, message: '...')
  // En Java, on aurait un constructeur à 3 arguments (ou un Builder).
  const EcranEnConstruction({
    super.key,
    required this.titre,
    required this.icone,
    required this.message,
  });

  // « final » : le champ ne change plus après la construction (comme en Java).
  final String titre;
  final IconData icone;
  final String message;

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) : lit le thème défini dans app.dart (comme une injection de dépendance).
    final textes = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,   // la colonne prend juste la hauteur de son contenu
            children: [
              // Un cercle doré avec l'icône au centre.
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(color: Couleurs.or, shape: BoxShape.circle),
                child: Icon(icone, size: 44, color: Couleurs.noir),
              ),
              const SizedBox(height: 24),
              // « ?. » : appel « null-safe ». titleLarge peut être null (type TextStyle?) ;
              // si c'est le cas, copyWith n'est pas appelé et le résultat vaut null.
              // C'est l'équivalent de Optional.ofNullable(x).map(...).orElse(null) en Java.
              Text('Bientôt disponible',
                  style: textes.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: textes.bodyMedium?.copyWith(color: Couleurs.grisTexte)),
            ],
          ),
        ),
      ),
    );
  }
}