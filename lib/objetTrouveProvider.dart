import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'objetTrouve.dart'; // Ton modèle ObjetTrouve

class ObjetsTrouvesProvider with ChangeNotifier {
  List<ObjetTrouve> _objetsTrouves = [];
  String? _gareSelectionnee;
  String? _categorieSelectionnee;

  List<ObjetTrouve> get objetsTrouves => _objetsTrouves;
  String? get gareSelectionnee => _gareSelectionnee;
  String? get categorieSelectionnee => _categorieSelectionnee;

  // Méthodes pour mettre à jour les filtres
  void setGare(String gare) {
    _gareSelectionnee = gare;
    notifyListeners();
  }

  void setCategorie(String categorie) {
    _categorieSelectionnee = categorie;
    notifyListeners();
  }

  // Méthode pour récupérer les objets trouvés
  Future<void> recupererObjets() async {
    if (_gareSelectionnee != null && _categorieSelectionnee != null) {
      final response = await http.get(Uri.parse(
          'https://data.sncf.com/api/records/1.0/search/?dataset=objets-trouves-restitution&q=&rows=100&facet=gc_obo_gare_origine_r_name&facet=gc_obo_type_c&refine.gc_obo_gare_origine_r_name=$_gareSelectionnee&refine.gc_obo_type_c=$_categorieSelectionnee'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['records'];
        _objetsTrouves = data.map((json) => ObjetTrouve.fromJson(json['fields'])).toList();
      } else {
        throw Exception('Échec de la récupération des objets');
      }
      notifyListeners();
    }
  }
}
