// Fichier : lib/services/client_api.dart
// Le client HTTP commun à toutes les API (galas, lutteurs, classement...).
// Équivalent Spring : un RestClient configuré une fois (URL de base, délai, erreurs),
// puis réutilisé par chaque service.
//
// Nouveaux concepts :
//  - Future<T>   : un résultat qui arrivera plus tard (comme CompletableFuture<T> en Java).
//  - async/await : écrire du code asynchrone comme du code normal (await « attend » le Future
//                  SANS bloquer l'écran : l'application reste fluide pendant l'appel réseau).

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;   // « as http » : préfixe, pour écrire http.get, http.Client...

import 'package:mbappat221_app/config/config_api.dart';

/// Erreur d'appel à l'API, avec un message lisible par l'utilisateur.
/// « implements Exception » ≈ « extends RuntimeException » en Java.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ClientApi {
  /// Les paramètres entre { } sont facultatifs et nommés :
  ///   ClientApi()                                         → vrai réseau, URL de ConfigApi
  ///   ClientApi(client: clientDeTest, urlBase: 'http://test') → dans les tests
  /// « ?? » : « si c'est null, prends la valeur de droite » (comme Objects.requireNonNullElse).
  ClientApi({http.Client? client, this.urlBase = ConfigApi.urlBase})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String urlBase;

  /// Au-delà, on considère que le serveur ne répond pas (connexion mobile faible).
  static const _delaiMaximal = Duration(seconds: 15);

  /// GET [chemin] quand la réponse est un objet JSON { ... } : renvoie une Map.
  /// Lance une [ApiException] si le serveur est injoignable ou répond une erreur.
  Future<Map<String, dynamic>> lireJson(String chemin, {Map<String, String>? parametres}) async {
    return await _lire(chemin, parametres) as Map<String, dynamic>;
  }

  /// GET [chemin] quand la réponse est une liste JSON [ ... ] (ex. /api/categories).
  Future<List<dynamic>> lireJsonListe(String chemin, {Map<String, String>? parametres}) async {
    return await _lire(chemin, parametres) as List<dynamic>;
  }

  /// L'appel commun aux deux méthodes ci-dessus. « Object? » : n'importe quel résultat JSON
  /// (Map, List, texte, nombre...) ; chaque méthode publique le « caste » vers le bon type.
  Future<Object?> _lire(String chemin, Map<String, String>? parametres) async {
    final uri = Uri.parse('$urlBase$chemin').replace(queryParameters: parametres);

    // « final http.Response reponse; » sans valeur : Dart vérifie qu'elle sera affectée
    // avant d'être lue (dans le try, ou bien une exception est lancée).
    final http.Response reponse;
    try {
      reponse = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_delaiMaximal);
    } on TimeoutException {
      throw const ApiException('Le serveur met trop de temps à répondre. Vérifie ta connexion.');
    } on http.ClientException {
      // Pas de réseau, serveur arrêté, ou appel refusé par le navigateur (CORS).
      throw const ApiException('Impossible de joindre le serveur. Vérifie ta connexion.');
    }

    if (reponse.statusCode != 200) {
      throw ApiException('Le serveur a répondu une erreur (code ${reponse.statusCode}).');
    }

    // bodyBytes + utf8.decode : on décode nous-mêmes en UTF-8. Sinon, si le serveur
    // n'indique pas le jeu de caractères, « Thiès » pourrait s'afficher « ThiÃ¨s ».
    return jsonDecode(utf8.decode(reponse.bodyBytes));
  }

  /// Les photos et affiches ont une adresse relative (« /fichiers/galas/3/x.jpg ») :
  /// on ajoute l'adresse du serveur. Renvoie null si [chemin] est null.
  String? urlFichier(String? chemin) {
    if (chemin == null || chemin.isEmpty) {
      return null;
    }
    return chemin.startsWith('http') ? chemin : '$urlBase$chemin';
  }
}