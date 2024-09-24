import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Model/objetTrouve.dart'; // Ton modèle ObjetTrouve

class ObjetsTrouvesProvider with ChangeNotifier {
  List<ObjetTrouve> _objetsTrouves = [];
  bool _enChargement = false; // Pour indiquer si le chargement est en cours
  int _pageActuelle = 0; // Pour gérer la pagination

  List<ObjetTrouve> get objetsTrouves => _objetsTrouves;
  bool get enChargement => _enChargement; // Indique si le chargement est en cours

  // Méthode pour récupérer les objets trouvés avec pagination
  Future<void> recupererObjets() async {
    if (_enChargement) return; // Empêche de déclencher plusieurs fois le chargement

    _enChargement = true;
    notifyListeners();

    // Mise à jour de l'URL avec la nouvelle structure API et paramètre `limit`
    var url = Uri.parse(
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?limit=100&offset=${_pageActuelle * 100}'
    );

    print('Requête envoyée : $url'); // Affiche l'URL utilisée pour déboguer

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print('Réponse de l\'API : $jsonResponse'); // Affiche la réponse pour analyse

      // Vérifier que la clé 'results' existe et n'est pas null
      if (jsonResponse != null && jsonResponse.containsKey('results')) {
        var results = jsonResponse['results'];

        // Si 'results' n'est pas vide, le transformer en liste d'objets
        if (results != null) {
          List<ObjetTrouve> objets = results.map<ObjetTrouve>((json) {
            return ObjetTrouve.fromJson(json);
          }).toList();

          // Ajouter les objets récupérés à la liste existante
          _objetsTrouves.addAll(objets);
        } else {
          print('Aucun enregistrement trouvé dans la réponse.');
        }

        // Incrémenter pour la page suivante
        _pageActuelle += 1;
      } else {
        print('La réponse ne contient pas de clé "results"');
      }
    } else {
      print('Erreur de récupération des objets : ${response.statusCode}');
    }

    _enChargement = false;
    notifyListeners();
  }

  // Test de pagination
  void testPagination(ObjetsTrouvesProvider provider) async {
    print('=== Test de la pagination ===');

    for (int i = 0; i < 5; i++) {
      print('Requête #${i + 1}');
      await provider.recupererObjets();

      // Afficher le nombre d'objets récupérés
      print('Nombre d\'objets récupérés : ${provider.objetsTrouves.length}');

      // Vérifier la dernière page
      print('Page actuelle : ${provider._pageActuelle}');
      print('------------------------------------');
    }

    print('Test terminé');
  }
}
