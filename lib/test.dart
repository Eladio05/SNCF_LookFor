import 'dart:convert'; // Pour décoder les réponses JSON
import 'package:http/http.dart' as http;

void main() async {
  // URL de l'API SNCF avec quelques filtres par défaut
  var url = Uri.parse(
      'https://data.sncf.com/api/records/1.0/search/?dataset=objets-trouves-restitution&q=&rows=5&facet=gc_obo_gare_origine_r_name&facet=gc_obo_type_c');

  // Effectuer une requête HTTP GET
  var response = await http.get(url);

  // Si la requête est réussie, afficher les données
  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body); // Décoder la réponse JSON
    var records = jsonResponse['records'];

    // Afficher chaque objet trouvé dans la réponse
    for (var record in records) {
      print('Gare: ${record['fields']['gc_obo_gare_origine_r_name']}');
      print('Catégorie: ${record['fields']['gc_obo_type_c']}');
      print('Nature: ${record['fields']['gc_obo_nature_c']}');
      print('Date: ${record['fields']['date']}');
      print('-------------------------');
    }
  } else {
    print('Échec de la récupération des objets : ${response.statusCode}');
  }
}
