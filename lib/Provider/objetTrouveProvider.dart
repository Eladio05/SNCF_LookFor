import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Model/objetTrouve.dart';

class ObjetsTrouvesProvider with ChangeNotifier {
  List<ObjetTrouve> _objetsTrouves = [];
  bool _enChargement = false;
  int _pageActuelle = 0;
  bool _finPagination = false; // Ajout pour savoir si la pagination est terminée

  List<ObjetTrouve> get objetsTrouves => _objetsTrouves;
  bool get enChargement => _enChargement;

  Future<void> recupererObjetsAvecFiltres(Map<String, String> filters) async {
    if (_enChargement) return;

    // Réinitialisation des données avant chaque nouvelle recherche
    _objetsTrouves = [];
    _pageActuelle = 0;

    _enChargement = true;
    notifyListeners();

    // Construction des filtres
    String gareFilter = filters['gare']!.isNotEmpty
        ? filters['gare']!.split(',').map((gare) => 'gc_obo_gare_origine_r_name%3D"$gare"').join('%20or%20')
        : '';
    String natureFilter = filters['nature']!.isNotEmpty
        ? filters['nature']!.split(',').map((nature) => 'gc_obo_nature_c%3D"$nature"').join('%20or%20')
        : '';
    String typeFilter = filters['type']!.isNotEmpty
        ? filters['type']!.split(',').map((type) => 'gc_obo_type_c%3D"$type"').join('%20or%20')
        : '';

    // Filtre sur la date en utilisant une plage allant de 00:00 à 23:59
    String dateFilter = filters['date']!.isNotEmpty
        ? 'date%3E%3D"${filters['date']}T00:00:00"%20and%20date%3C%3D"${filters['date']}T23:59:59"'
        : '';

    // Construction de la chaîne WHERE en combinant les filtres avec l'option OR et AND
    List<String> whereClauses = [];
    if (gareFilter.isNotEmpty) whereClauses.add('($gareFilter)');
    if (natureFilter.isNotEmpty) whereClauses.add('($natureFilter)');
    if (typeFilter.isNotEmpty) whereClauses.add('($typeFilter)');
    if (dateFilter.isNotEmpty) whereClauses.add(dateFilter);

    // Les différents filtres sont combinés avec "and"
    String where = whereClauses.isNotEmpty ? '&where=${whereClauses.join('%20and%20')}' : '';

    var url = Uri.parse(
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?limit=100&offset=${_pageActuelle * 100}$where'
    );

    print('Requête URL : $url'); // Ajoutez ce log pour inspecter l'URL générée

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

  // Méthode pour réinitialiser la pagination et les objets (appelée lors d'une nouvelle recherche)
  void reinitialiserPagination() {
    _pageActuelle = 0;
    _finPagination = false;
    _objetsTrouves = [];
    notifyListeners();
  }

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
            json['gc_obo_gare_origine_r_name'] != null ||
                json['gc_obo_nature_c'] != null ||
                json['gc_obo_type_c'] != null
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
