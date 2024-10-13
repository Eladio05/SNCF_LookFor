import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Model/objetTrouve.dart';

class ObjetsTrouvesService {
  Future<List<ObjetTrouve>> fetchObjetsAvecFiltres(
      Map<String, String> filters,
      List<String> selectedGares,
      List<String> selectedNatures,
      List<String> selectedTypes,
      DateTime? selectedDate,
      int pageActuelle) async {
    String encodeQuery(String value) {
      return Uri.encodeComponent(value);
    }

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

    List<String> whereClauses = [];
    if (gareFilter.isNotEmpty) whereClauses.add(gareFilter);
    if (natureFilter.isNotEmpty) whereClauses.add(natureFilter);
    if (typeFilter.isNotEmpty) whereClauses.add(typeFilter);
    if (dateFilter.isNotEmpty) whereClauses.add(dateFilter);

    String where = whereClauses.isNotEmpty ? '&where=${whereClauses.join(' and ')}' : '';

    var url = Uri.parse(
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?limit=100&offset=${pageActuelle * 100}$where');

    print('Requête URL : $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('results')) {
        var results = jsonResponse['results'];
        return results.map<ObjetTrouve>((json) => ObjetTrouve.fromJson(json)).toList();
      }
    } else {
      print('Erreur de récupération des objets : ${response.statusCode}');
    }

    return [];
  }

  Future<List<ObjetTrouve>> fetchObjetsDepuisDerniereConnexion(
      DateTime derniereConnexion, int pageActuelle) async {
    String formattedLastConnection = DateFormat('yyyy-MM-dd').format(derniereConnexion);
    String formattedNow = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String dateFilter = 'date%3E%3D"${formattedLastConnection}T00:00:00"%20and%20date%3C%3D"${formattedNow}T23:59:59"';

    var url = Uri.parse(
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?limit=100&offset=${pageActuelle * 100}&where=$dateFilter');

    print('Requête URL pour les nouveaux objets : $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('results')) {
        var results = jsonResponse['results'];
        return results.map<ObjetTrouve>((json) => ObjetTrouve.fromJson(json)).toList();
      }
    } else {
      print('Erreur de récupération des nouveaux objets : ${response.statusCode}');
    }

    return [];
  }

  Future<List<String>> getDistinctOptions(String field) async {
    List<String> options = [];
    int offset = 0;
    bool continuer = true;

    String baseUrl =
        'https://data.sncf.com/api/explore/v2.1/catalog/datasets/objets-trouves-restitution/records?select=$field&group_by=$field&limit=100&offset=';

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
            offset += 100;
          } else {
            continuer = false;
          }
        } else {
          continuer = false;
        }
      } else {
        print('Erreur de récupération des filtres : ${response.statusCode}');
        continuer = false;
      }
    }

    print('Options récupérées pour $field : $options');
    return options;
  }
}
