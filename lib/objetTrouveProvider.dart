import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'objetTrouve.dart'; // Ton modèle ObjetTrouve

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

    var url = Uri.parse(
        'https://data.sncf.com/api/records/1.0/search/?dataset=objets-trouves-restitution&rows=100'
    );

    print('Requête envoyée : $url'); // Affiche l'URL utilisée pour déboguer

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var records = jsonResponse['records'];

      // Transformation correcte de chaque élément de 'records' en ObjetTrouve
      List<ObjetTrouve> objets = records.map<ObjetTrouve>((json) {
        return ObjetTrouve.fromJson(json['fields']);
      }).toList();

      // Ajouter les objets récupérés à la liste existante
      _objetsTrouves.addAll(objets);
      _pageActuelle += 1; // Incrémenter pour la page suivante
    } else {
      print('Erreur de récupération des objets : ${response.statusCode}');
    }

    _enChargement = false;
    notifyListeners();
  }
}
