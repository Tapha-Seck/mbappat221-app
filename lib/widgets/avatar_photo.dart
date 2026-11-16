// Fichier : lib/widgets/avatar_photo.dart
// Une photo ronde (lutteur, animateur), ou à défaut l'initiale du nom sur fond doré.

import 'package:flutter/material.dart';

import 'package:mbappat221_app/theme/couleurs.dart';

class AvatarPhoto extends StatelessWidget {
  const AvatarPhoto({super.key, required this.nom, this.url, this.rayon = 24});

  final String nom;
  final String? url;     // adresse complète, ou null
  final double rayon;

  @override
  Widget build(BuildContext context) {
    final adresse = url;
    return CircleAvatar(
      radius: rayon,
      backgroundColor: Couleurs.noir,
      foregroundColor: Couleurs.or,
      backgroundImage: adresse == null ? null : NetworkImage(adresse),
      // Obligatoire avec une image réseau : si elle ne se charge pas, on n'affiche rien de plus.
      onBackgroundImageError: adresse == null ? null : (erreur, pile) {},
      child: adresse == null
          ? Text(
        nom.isEmpty ? '?' : nom[0].toUpperCase(),
        style: TextStyle(fontSize: rayon * 0.8, fontWeight: FontWeight.w900),
      )
          : null,
    );
  }
}