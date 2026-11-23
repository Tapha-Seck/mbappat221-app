// Fichier : test/factices.dart
// Faux services pour les tests : ils répondent tout de suite, sans réseau (≈ des @Mock Mockito).
// Ce fichier ne finit pas par « _test.dart » : ce n'est pas un test, seulement un outil partagé.
//
// « implements X » : en Dart, toute classe sert aussi d'interface ; le faux remplace le vrai.

import 'package:mbappat221_app/modeles/animateur.dart';
import 'package:mbappat221_app/modeles/categorie.dart';
import 'package:mbappat221_app/modeles/classement.dart';
import 'package:mbappat221_app/modeles/fiche_lutteur.dart';
import 'package:mbappat221_app/modeles/gala.dart';
import 'package:mbappat221_app/modeles/lutteur.dart';
import 'package:mbappat221_app/modeles/page_resultats.dart';
import 'package:mbappat221_app/modeles/recherche.dart';
import 'package:mbappat221_app/services/animateur_api.dart';
import 'package:mbappat221_app/services/classement_api.dart';
import 'package:mbappat221_app/services/client_api.dart';
import 'package:mbappat221_app/services/gala_api.dart';
import 'package:mbappat221_app/services/lutteur_api.dart';
import 'package:mbappat221_app/services/recherche_api.dart';
import 'package:mbappat221_app/services/referentiel_api.dart';
import 'package:mbappat221_app/services/services_api.dart';

/// Tous les services factices d'un coup ; chaque paramètre est facultatif.
ServicesApi servicesFactices({
  List<Gala> galas = const [],
  ApiException? erreurGalas,
  List<LutteurListe> lutteurs = const [],
  Map<int, FicheLutteur> fiches = const {},
  List<Categorie> categories = const [],
  Map<int, Classement> classements = const {},
  Podium? podium,
  List<AnimateurDetail> animateurs = const [],
  Map<int, ProfilAnimateur> profils = const {},
}) {
  return ServicesApi(
    galas: GalaApiFactice(galas: galas, erreur: erreurGalas),
    lutteurs: LutteurApiFactice(lutteurs: lutteurs, fiches: fiches),
    classements: ClassementApiFactice(classements: classements, podiumSaison: podium),
    animateurs: AnimateurApiFactice(animateurs: animateurs, profils: profils),
    referentiel: ReferentielApiFactice(liste: categories),
    recherche: RechercheApiFactice(galas: galas, lutteurs: lutteurs, animateurs: animateurs),
  );
}

class GalaApiFactice implements GalaApi {
  GalaApiFactice({this.galas = const [], this.erreur});

  final List<Gala> galas;
  final ApiException? erreur;

  @override
  Future<PageResultats<Gala>> galasAVenir({int page = 0, int taille = 20}) async {
    final e = erreur;
    if (e != null) {
      throw e;
    }
    final contenu = galas.take(taille).toList();   // respecte la taille demandée (1 pour l'accueil)
    return PageResultats(
        contenu: contenu, page: 0, taille: taille, totalElements: galas.length, totalPages: 1);
  }

  @override
  String? urlFichier(String? chemin) => null;   // pas d'image réseau pendant les tests
}

/// Filtre comme le vrai serveur : nom, surnom ou écurie, et catégorie.
class LutteurApiFactice implements LutteurApi {
  LutteurApiFactice({this.lutteurs = const [], this.fiches = const {}});

  final List<LutteurListe> lutteurs;
  final Map<int, FicheLutteur> fiches;   // fiche par identifiant de lutteur

  @override
  Future<FicheLutteur> fiche(int lutteurId) async {
    final fiche = fiches[lutteurId];
    if (fiche == null) {
      throw const ApiException('Lutteur introuvable');
    }
    return fiche;
  }

  @override
  Future<PageResultats<LutteurListe>> rechercher({
    String recherche = '',
    int? categorieId,
    int page = 0,
    int taille = 20,
  }) async {
    final texte = recherche.trim().toLowerCase();
    final trouves = lutteurs.where((l) {
      final bonneCategorie = categorieId == null || l.categorieId == categorieId;
      final cherche = '${l.nom} ${l.surnom ?? ''} ${l.ecurieNom ?? ''}'.toLowerCase();
      return bonneCategorie && (texte.length < 2 || cherche.contains(texte));
    }).toList();
    return PageResultats(
        contenu: trouves, page: 0, taille: taille, totalElements: trouves.length, totalPages: 1);
  }

  @override
  String? urlFichier(String? chemin) => null;
}

class ReferentielApiFactice implements ReferentielApi {
  ReferentielApiFactice({this.liste = const []});

  final List<Categorie> liste;

  @override
  Future<List<Categorie>> categories() async => liste;
}

class ClassementApiFactice implements ClassementApi {
  ClassementApiFactice({this.classements = const {}, this.podiumSaison});

  final Map<int, Classement> classements;   // classement par identifiant de catégorie
  final Podium? podiumSaison;

  @override
  Future<Classement> classement(int categorieId) async {
    // Une catégorie inconnue : classement vide (aucune finale).
    return classements[categorieId] ??
        Classement(categorieId: categorieId, categorieNom: 'Catégorie $categorieId',
            saisonLibelle: '2026-2027', lignes: const []);
  }

  @override
  Future<Podium> podium() async =>
      podiumSaison ?? const Podium(saisonLibelle: '2026-2027', categories: []);
}

class AnimateurApiFactice implements AnimateurApi {
  AnimateurApiFactice({this.animateurs = const [], this.profils = const {}});

  final List<AnimateurDetail> animateurs;
  final Map<int, ProfilAnimateur> profils;   // profil par identifiant d'animateur

  @override
  Future<List<AnimateurDetail>> lister({RoleAnimateur? role}) async =>
      animateurs.where((a) => role == null || a.role == role).toList();

  @override
  Future<ProfilAnimateur> profil(int animateurId) async {
    final profil = profils[animateurId];
    if (profil == null) {
      throw const ApiException('Animateur introuvable');
    }
    return profil;
  }

  @override
  String? urlFichier(String? chemin) => null;
}

/// Cherche dans les mêmes listes que les autres faux services, comme le vrai serveur :
/// lutteurs (nom, surnom, écurie), galas (nom, lieu, région, organisateur), animateurs (nom, surnom).
class RechercheApiFactice implements RechercheApi {
  RechercheApiFactice({this.galas = const [], this.lutteurs = const [], this.animateurs = const []});

  final List<Gala> galas;
  final List<LutteurListe> lutteurs;
  final List<AnimateurDetail> animateurs;

  @override
  Future<ResultatRecherche> rechercher(String texte) async {
    final t = texte.trim().toLowerCase();
    bool contient(String champs) => champs.toLowerCase().contains(t);   // fonction locale (≈ une lambda nommée)

    return ResultatRecherche(
      texte: texte.trim(),
      lutteurs: _page(lutteurs.where((l) => contient('${l.nom} ${l.surnom ?? ''} ${l.ecurieNom ?? ''}'))),
      galas: _page(galas.where((g) => contient('${g.nom} ${g.lieu} ${g.region} ${g.organisateur ?? ''}'))),
      animateurs: _page(animateurs.where((a) => contient('${a.nom} ${a.surnom ?? ''}'))),
    );
  }

  /// <T> : méthode générique, comme « private static <T> PageDto<T> page(...) » en Java.
  static PageResultats<T> _page<T>(Iterable<T> trouves) {
    final contenu = trouves.take(5).toList();
    return PageResultats(contenu: contenu, page: 0, taille: 5, totalElements: trouves.length, totalPages: 1);
  }

  @override
  String? urlFichier(String? chemin) => null;
}