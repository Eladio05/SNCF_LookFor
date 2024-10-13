import 'package:flutter/material.dart';
import '../Model/objetTrouve.dart';
import '../Services/objetTrouvesService.dart';

class ObjetsTrouvesProvider with ChangeNotifier {
  final ObjetsTrouvesService _service = ObjetsTrouvesService();

  List<ObjetTrouve> _objetsTrouves = [];
  bool _enChargement = false;
  int _pageActuelle = 0;
  bool _finPagination = false;
  Map<String, String> _currentFilters = {};
  DateTime? _derniereConnexion;
  bool _isSearchingByLastConnection = false;

  List<ObjetTrouve> get objetsTrouves => _objetsTrouves;
  bool get enChargement => _enChargement;
  bool get finPagination => _finPagination;

  List<String> selectedGares = [];
  List<String> selectedNatures = [];
  List<String> selectedTypes = [];
  DateTime? selectedDate;

  Future<void> recupererObjetsAvecFiltres(Map<String, String> filters) async {
    if (_enChargement || _finPagination) return;

    _enChargement = true;
    _currentFilters = filters;
    notifyListeners();

    List<ObjetTrouve> objets = await _service.fetchObjetsAvecFiltres(
      filters,
      selectedGares,
      selectedNatures,
      selectedTypes,
      selectedDate,
      _pageActuelle,
    );

    if (objets.isEmpty) {
      _finPagination = true;
    } else {
      if (_pageActuelle == 0) {
        _objetsTrouves = objets;
      } else {
        _objetsTrouves.addAll(objets);
      }
      _pageActuelle += 1;
    }

    _enChargement = false;
    notifyListeners();
  }

  Future<void> recupererProchainesPages() async {
    await recupererObjetsAvecFiltres(_currentFilters);
  }

  Future<void> recupererObjetsDepuisDerniereConnexion(DateTime derniereConnexion) async {
    if (_enChargement || _finPagination) return;

    _enChargement = true;
    _derniereConnexion = derniereConnexion;
    _isSearchingByLastConnection = true;
    notifyListeners();

    List<ObjetTrouve> objets = await _service.fetchObjetsDepuisDerniereConnexion(
      _derniereConnexion!,
      _pageActuelle,
    );

    if (objets.isEmpty) {
      _finPagination = true;
    } else {
      if (_pageActuelle == 0) {
        _objetsTrouves = objets;
      } else {
        _objetsTrouves.addAll(objets);
      }
      _pageActuelle += 1;
    }

    _enChargement = false;
    notifyListeners();
  }

  Future<void> recupererProchainesPagesAvecConnexion() async {
    if (_isSearchingByLastConnection && _derniereConnexion != null) {
      await recupererObjetsDepuisDerniereConnexion(_derniereConnexion!);
    }
  }

  void reinitialiserPagination() {
    _pageActuelle = 0;
    _finPagination = false;
    _objetsTrouves = [];
    _isSearchingByLastConnection = false;
    notifyListeners();
  }

  Future<List<String>> getDistinctOptions(String field) async {
    return await _service.getDistinctOptions(field);
  }

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
