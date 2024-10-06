import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Model/objetTrouve.dart';

class ObjetsTrouvesProvider with ChangeNotifier {
  List<ObjetTrouve> _objetsTrouves = [];
  bool _enChargement = false;
  int _pageActuelle = 0;

  List<ObjetTrouve> get objetsTrouves => _objetsTrouves;
  bool get enChargement => _enChargement;

  // Méthode pour récupérer les objets trouvés avec pagination et filtres
  Future<void> recupererObjetsAvecFiltres(Map<String, String> filters) async {
    if (_enChargement) return;

    _enChargement = true;
    notifyListeners();

    String gareFilter = filters['gare']!.isNotEmpty ? '&gc_obo_gare_origine_r_name=${filters['gare']}' : '';
    String natureFilter = filters['nature']!.isNotEmpty ? '&gc_obo_nature_c=${filters['nature']}' : '';
    String typeFilter = filters['type']!.isNotEmpty ? '&gc_obo_type_c=${filters['type']}' : '';
    String dateFilter = filters['date']!.isNotEmpty ? '&date=${filters['date']}' : ''; // Ajout du filtre de date

    var url = Uri.parse(
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?limit=100&offset=${_pageActuelle * 100}$gareFilter$natureFilter$typeFilter$dateFilter'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('results')) {
        var results = jsonResponse['results'];
        List<ObjetTrouve> objets = results.map<ObjetTrouve>((json) {
          return ObjetTrouve.fromJson(json);
        }).toList();

        if (_pageActuelle == 0) {
          _objetsTrouves = objets; // Si c'est la première page, on remplace la liste
        } else {
          _objetsTrouves.addAll(objets); // Sinon, on ajoute à la liste
        }
        _pageActuelle += 1;
      }
    } else {
      print('Erreur de récupération des objets : ${response.statusCode}');
    }

    _enChargement = false;
    notifyListeners();
  }


  // Méthode pour récupérer les options distinctes (gares, types, etc.) avec pagination et tri par ordre alphabétique, et filtrage des valeurs nulles
  // Méthode pour récupérer les options distinctes (gares, types, etc.) avec pagination et tri par ordre alphabétique, et filtrage des valeurs nulles
// Méthode pour récupérer les options distinctes (gares, types, etc.) avec pagination et tri par ordre alphabétique, et filtrage des valeurs nulles
  Future<List<String>> getDistinctOptions(String field) async {
    List<String> options = [];
    int offset = 0;
    bool continuer = true;

    String baseUrl =
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?select=$field&group_by=$field&limit=100&offset=';

    // Ajout du where pour filtrer les valeurs nulles
    String whereClause = 'where=$field%20is%20not%20null';

    while (continuer) {
      var url = Uri.parse(baseUrl + '$offset&order_by=$field&$whereClause');

      print('Requête URL : $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Réponse complète de l\'API : $jsonResponse'); // Afficher toute la réponse de l'API

        if (jsonResponse != null && jsonResponse.containsKey('results')) {
          var results = jsonResponse['results'];

          if (results != null && results.isNotEmpty) {
            // Ajoute seulement les options valides qui ont la clé et ne sont pas nulles
            List<String> newOptions = results.where((json) =>
            json['gc_obo_gare_origine_r_name'] != null || json['gc_obo_nature_c'] != null || json['gc_obo_type_c'] != null
            ).map<String>((json) {
              if (field == 'gc_obo_gare_origine_r_name') {
                return json['gc_obo_gare_origine_r_name'].toString();
              } else if (field == 'gc_obo_nature_c') {
                return json['gc_obo_nature_c'].toString();
              } else {
                return json['gc_obo_type_c'].toString();
              }
            }).toList();

            // Ajout à la liste complète des options
            options.addAll(newOptions);
            offset += 100; // Incrémentation de l'offset pour la pagination
          } else {
            continuer = false; // Arrêter la boucle si aucun résultat supplémentaire
          }
        } else {
          continuer = false; // Si les résultats sont vides
        }
      } else {
        print('Erreur de récupération des filtres : ${response.statusCode}');
        continuer = false;
      }
    }

    print('Options récupérées pour $field : $options'); // Vérification finale des options collectées
    return options;
  }

}
