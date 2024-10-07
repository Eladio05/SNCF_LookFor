import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pour formater les dates
import '../Model/objetTrouve.dart';

class ObjetsTrouvesProvider with ChangeNotifier {
  List<ObjetTrouve> _objetsTrouves = [];
  bool _enChargement = false;
  int _pageActuelle = 0;
  bool _finPagination = false; // To indicate when pagination has ended

  List<ObjetTrouve> get objetsTrouves => _objetsTrouves;
  bool get enChargement => _enChargement;
  bool get finPagination => _finPagination; // Getter pour finPagination

  // Liste des filtres sélectionnés
  List<String> selectedGares = [];
  List<String> selectedNatures = [];
  List<String> selectedTypes = [];
  DateTime? selectedDate;

  Future<void> recupererObjetsAvecFiltres(Map<String, String> filters) async {
    if (_enChargement || _finPagination) return; // Si déjà en chargement ou pagination finie, on ne continue pas

    _enChargement = true;
    notifyListeners();

    // Encodage des valeurs des filtres
    String encodeQuery(String value) {
      return Uri.encodeComponent(value);
    }

    // Construction du filtre pour la gare
    String gareFilter = selectedGares.isNotEmpty
        ? 'gc_obo_gare_origine_r_name:("${selectedGares.map(encodeQuery).join('" or "')}")'
        : '';

    // Construction du filtre pour la nature
    String natureFilter = selectedNatures.isNotEmpty
        ? 'gc_obo_nature_c:("${selectedNatures.map(encodeQuery).join('" or "')}")'
        : '';

    // Construction du filtre pour le type
    String typeFilter = selectedTypes.isNotEmpty
        ? 'gc_obo_type_c:("${selectedTypes.map(encodeQuery).join('" or "')}")'
        : '';

    // Construction du filtre de date si nécessaire avec le format "yyyy-MM-dd"
    String dateFilter = selectedDate != null
        ? 'date%3E%3D"${DateFormat('yyyy-MM-dd').format(selectedDate!)}T00:00:00"%20and%20date%3C%3D"${DateFormat('yyyy-MM-dd').format(selectedDate!)}T23:59:59"'
        : '';

    // Combine les clauses WHERE
    List<String> whereClauses = [];
    if (gareFilter.isNotEmpty) whereClauses.add(gareFilter);
    if (natureFilter.isNotEmpty) whereClauses.add(natureFilter);
    if (typeFilter.isNotEmpty) whereClauses.add(typeFilter);
    if (dateFilter.isNotEmpty) whereClauses.add(dateFilter);

    // Combine le tout avec `and` pour séparer les différents filtres
    String where = whereClauses.isNotEmpty ? '&where=${whereClauses.join(' and ')}' : '';

    var url = Uri.parse(
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?limit=100&offset=${_pageActuelle * 100}$where'
    );

    print('Requête URL : $url'); // Log pour inspecter l'URL générée

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('results')) {
        var results = jsonResponse['results'];
        List<ObjetTrouve> objets = results.map<ObjetTrouve>((json) {
          return ObjetTrouve.fromJson(json);
        }).toList();

        if (objets.isEmpty) {
          _finPagination = true;
          print('Fin de la pagination');
        } else {
          if (_pageActuelle == 0) {
            _objetsTrouves = objets; // Remplacer la liste pour la première page
          } else {
            _objetsTrouves.addAll(objets); // Ajouter à la liste pour les pages suivantes
          }
          _pageActuelle += 1;
        }
      } else {
        _finPagination = true;
        print('Pas de résultats, fin de la pagination');
      }
    } else {
      print('Erreur de récupération des objets : ${response.statusCode}');
    }

    _enChargement = false;
    notifyListeners();
  }

  // Method to reset pagination and objects (called when starting a new search)
  void reinitialiserPagination() {
    _pageActuelle = 0;
    _finPagination = false;
    _objetsTrouves = [];
    notifyListeners();
  }

  // Ajout de la méthode getDistinctOptions pour récupérer les options uniques
  Future<List<String>> getDistinctOptions(String field) async {
    List<String> options = [];
    int offset = 0;
    bool continuer = true;

    String baseUrl =
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?select=$field&group_by=$field&limit=100&offset=';

    // Ajouter une clause WHERE pour filtrer les valeurs nulles
    String whereClause = 'where=$field is not null';

    while (continuer) {
      var url = Uri.parse(baseUrl + '$offset&order_by=$field&$whereClause');

      print('Requête URL : $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse != null && jsonResponse.containsKey('results')) {
          var results = jsonResponse['results'];

          if (results != null && results.isNotEmpty) {
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

            options.addAll(newOptions);
            offset += 100; // Incrémenter l'offset pour la pagination
          } else {
            continuer = false; // Arrêter la boucle si aucun résultat
          }
        } else {
          continuer = false; // Arrêter si pas de résultats
        }
      } else {
        print('Erreur de récupération des filtres : ${response.statusCode}');
        continuer = false;
      }
    }

    print('Options récupérées pour $field : $options'); // Vérifier les options récupérées
    return options;
  }

  Future<void> recupererObjetsDepuisDerniereConnexion(DateTime derniereConnexion) async {
    if (_enChargement || _finPagination) return;

    _enChargement = true;
    notifyListeners();

    String formattedDate = DateFormat('yyyy-MM-dd').format(derniereConnexion);

    // Requête pour récupérer les objets trouvés après la date de la dernière connexion
    String dateFilter = 'date%3E%3D"${formattedDate}T00:00:00"';

    var url = Uri.parse(
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?limit=100&offset=${_pageActuelle * 100}&where=$dateFilter'
    );

    print('Requête URL pour les nouveaux objets : $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('results')) {
        var results = jsonResponse['results'];
        List<ObjetTrouve> objets = results.map<ObjetTrouve>((json) {
          return ObjetTrouve.fromJson(json);
        }).toList();

        if (objets.isEmpty) {
          _finPagination = true;
          print('Fin de la pagination');
        } else {
          if (_pageActuelle == 0) {
            _objetsTrouves = objets; // Remplacer la liste pour la première page
          } else {
            _objetsTrouves.addAll(objets); // Ajouter à la liste pour les pages suivantes
          }
          _pageActuelle += 1;
        }
      } else {
        _finPagination = true;
        print('Pas de résultats, fin de la pagination');
      }
    } else {
      print('Erreur de récupération des nouveaux objets : ${response.statusCode}');
    }

    _enChargement = false;
    notifyListeners();
  }

  // Méthodes pour mettre à jour les filtres sélectionnés
  void updateSelectedGares(List<String> gares) {
    selectedGares = gares;
    notifyListeners();
  }

  void updateSelectedNatures(List<String> natures) {
    selectedNatures = natures;
    notifyListeners();
  }

  void updateSelectedTypes(List<String> types) {
    selectedTypes = types;
    notifyListeners();
  }

  void updateSelectedDate(DateTime? date) {
    selectedDate = date;
    notifyListeners();
  }
}
