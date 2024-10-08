import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pour formater les dates
import '../Model/objetTrouve.dart';

class ObjetsTrouvesProvider with ChangeNotifier {
  List<ObjetTrouve> _objetsTrouves = [];
  bool _enChargement = false;
  int _pageActuelle = 0;
  bool _finPagination = false; // Pour indiquer quand la pagination est terminée
  Map<String, String> _currentFilters = {}; // Sauvegarde des filtres pour la pagination future
  DateTime? _derniereConnexion; // Variable pour stocker la date de dernière connexion
  bool _isSearchingByLastConnection = false; // Indicateur pour savoir si la recherche est basée sur la date de dernière connexion

  List<ObjetTrouve> get objetsTrouves => _objetsTrouves;
  bool get enChargement => _enChargement;
  bool get finPagination => _finPagination; // Getter pour finPagination

  // Liste des filtres sélectionnés
  List<String> selectedGares = [];
  List<String> selectedNatures = [];
  List<String> selectedTypes = [];
  DateTime? selectedDate;

  // Méthode pour récupérer les objets en fonction des filtres et gérer la pagination
  Future<void> recupererObjetsAvecFiltres(Map<String, String> filters) async {
    if (_enChargement || _finPagination) return; // Si déjà en chargement ou pagination finie, on ne continue pas

    _enChargement = true;
    _currentFilters = filters; // Sauvegarde des filtres pour la pagination future
    notifyListeners();

    // Encodage des valeurs des filtres
    String encodeQuery(String value) {
      return Uri.encodeComponent(value);
    }

    // Construction des différents filtres (gare, nature, type, date)
    String gareFilter = selectedGares.isNotEmpty
        ? 'gc_obo_gare_origine_r_name:("${selectedGares.map(encodeQuery).join('" or "')}")'
        : '';
    String natureFilter = selectedNatures.isNotEmpty
        ? 'gc_obo_nature_c:("${selectedNatures.map(encodeQuery).join('" or "')}")'
        : '';
    String typeFilter = selectedTypes.isNotEmpty
        ? 'gc_obo_type_c:("${selectedTypes.map(encodeQuery).join('" or "')}")'
        : '';
    String dateFilter = filters['date']?.isNotEmpty == true
        ? 'date%20%3E%3D%20%27${filters['date']}%2000%3A00%3A00%27%20AND%20date%20%3C%3D%20%27${filters['date']}%2023%3A59%3A59%27'
        : '';

    // Combine les clauses WHERE
    List<String> whereClauses = [];
    if (gareFilter.isNotEmpty) whereClauses.add(gareFilter);
    if (natureFilter.isNotEmpty) whereClauses.add(natureFilter);
    if (typeFilter.isNotEmpty) whereClauses.add(typeFilter);
    if (dateFilter.isNotEmpty) whereClauses.add(dateFilter);

    // Combine le tout avec `and` pour séparer les différents filtres
    String where = whereClauses.isNotEmpty ? '&where=${whereClauses.join(' and ')}' : '';

    // Construire l'URL pour appeler l'API avec la pagination
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
          _finPagination = true; // Indique qu'il n'y a plus de données à paginer
          print('Fin de la pagination');
        } else {
          if (_pageActuelle == 0) {
            _objetsTrouves = objets; // Remplacer la liste pour la première page
          } else {
            _objetsTrouves.addAll(objets); // Ajouter à la liste pour les pages suivantes
          }
          _pageActuelle += 1; // Incrémenter la page actuelle après chaque appel
        }
      } else {
        _finPagination = true; // Si pas de résultats, on stoppe la pagination
        print('Pas de résultats, fin de la pagination');
      }
    } else {
      print('Erreur de récupération des objets : ${response.statusCode}');
    }

    _enChargement = false;
    notifyListeners();
  }

  // Méthode pour récupérer les prochaines pages avec les mêmes filtres
  Future<void> recupererProchainesPages() async {
    await recupererObjetsAvecFiltres(_currentFilters); // Réutilise les filtres actuels pour la pagination
  }

  // Méthode pour récupérer les objets depuis la dernière connexion
  Future<void> recupererObjetsDepuisDerniereConnexion(DateTime derniereConnexion) async {
    if (_enChargement || _finPagination) return;

    _enChargement = true;
    _derniereConnexion = derniereConnexion; // Sauvegarde la date de dernière connexion
    _isSearchingByLastConnection = true; // Indicateur pour savoir si la recherche est basée sur la date de dernière connexion
    notifyListeners();

    await _recupererObjetsAvecDateConnexion(_derniereConnexion);

    _enChargement = false;
    notifyListeners();
  }

  // Méthode interne pour récupérer les objets avec la date de dernière connexion
  // Méthode interne pour récupérer les objets avec la date de dernière connexion
  Future<void> _recupererObjetsAvecDateConnexion(DateTime? dateConnexion) async {
    // Formater la date de dernière connexion à 00:00
    String formattedLastConnection = DateFormat('yyyy-MM-dd').format(dateConnexion!);

    // Obtenir la date actuelle et la formater à 23:59
    String formattedNow = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Requête pour récupérer les objets trouvés entre la date de dernière connexion à 00:00 et maintenant à 23:59
    String dateFilter = 'date%3E%3D"${formattedLastConnection}T00:00:00"%20and%20date%3C%3D"${formattedNow}T23:59:59"';

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
  }



  // Méthode pour récupérer les prochaines pages avec la date de dernière connexion
  // Méthode pour récupérer les prochaines pages avec la date de dernière connexion
  Future<void> recupererProchainesPagesAvecConnexion() async {
    if (_isSearchingByLastConnection && _derniereConnexion != null) {
      print("Chargement des prochaines pages avec la dernière connexion.");
      await _recupererObjetsAvecDateConnexion(_derniereConnexion);

      // Vérifier si la pagination est bien gérée et si les nouveaux objets sont bien ajoutés
      notifyListeners();
    }
  }


  // Méthode pour réinitialiser la pagination
  void reinitialiserPagination() {
    _pageActuelle = 0;
    _finPagination = false;
    _objetsTrouves = [];
    _isSearchingByLastConnection = false; // Réinitialiser l'indicateur
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
            List<String> newOptions = results.map<String>((json) {
              return json[field].toString();
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
