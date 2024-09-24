import 'dart:convert'; // Pour décoder les réponses JSON
import 'package:http/http.dart' as http;

void main() async {
  int objetsParPage = 100;
  int pageActuelle = 0;
  bool continuer = true;
  int i = 1; // Pour numéroter les objets

  while (continuer) {
    // URL de l'API avec le paramètre `start` pour la pagination
    var url = Uri.parse(
      'https://data.sncf.com/api/records/1.0/search/?dataset=objets-trouves-restitution&q=&rows=$objetsParPage&start=${pageActuelle * objetsParPage}&facet=gc_obo_gare_origine_r_name&facet=gc_obo_type_c',
    );

    // Effectuer une requête HTTP GET
    var response = await http.get(url);

    // Si la requête est réussie, afficher les données
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body); // Décoder la réponse JSON
      var records = jsonResponse['records'];

      // Si aucun objet n'est récupéré, arrêter la boucle
      if (records.isEmpty) {
        continuer = false;
      }

      // Afficher chaque objet trouvé dans la réponse
      for (var record in records) {
        print('Objet numéro $i');
        print('Gare: ${record['fields']['gc_obo_gare_origine_r_name']}');
        print('Catégorie: ${record['fields']['gc_obo_type_c']}');
        print('Nature: ${record['fields']['gc_obo_nature_c']}');
        print('Date: ${record['fields']['date']}');
        print('-------------------------');
        i += 1;
      }

      // Passer à la page suivante
      pageActuelle += 1;
    } else {
      print('Échec de la récupération des objets : ${response.statusCode}');
      continuer = false; // Arrêter la boucle si la requête échoue
    }
  }

  print('Test terminé, $i objets récupérés.');
}
