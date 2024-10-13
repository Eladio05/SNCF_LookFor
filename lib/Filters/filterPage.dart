import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sncf_lookfor/Resultpage/resultPage.dart';
import '../Provider/objetTrouveProvider.dart';
import 'datePicker.dart';
import 'multiSelect.dart';
import 'preferencesManager.dart';

class FiltersPage extends StatefulWidget {
  @override
  _FiltersPageState createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> with WidgetsBindingObserver {
  List<String> garesSelectionne = [];
  List<String> naturesSelectionne = [];
  List<String> typesSelectionne = [];
  DateTime? dateSelectionne;
  List<String> gares = [];
  List<String> natures = [];
  List<String> types = [];
  DateTime? dateDerniereConnexion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    chargerDonneesAPI();
    getDateDerniereConnexion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print('Application en pause. Sauvegarde de la date de dernière connexion...');
      PreferencesManager.sauvegardeDateDerniereConnexion(DateTime.now());
    } else if (state == AppLifecycleState.resumed) {
      print('Application restaurée. Dernière connexion : $dateDerniereConnexion');
    }
  }

  Future<void> chargerDonneesAPI() async {
    var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
    gares = await provider.getDistinctOptions('gc_obo_gare_origine_r_name');
    natures = await provider.getDistinctOptions('gc_obo_nature_c');
    types = await provider.getDistinctOptions('gc_obo_type_c');
    setState(() {});
  }

  Future<void> getDateDerniereConnexion() async {
    dateDerniereConnexion = await PreferencesManager.getDateDerniereConnexion();
    print('Date de dernière connexion récupérée : $dateDerniereConnexion');
    setState(() {});
  }

  void reinitialiserFiltres(String filter) {
    setState(() {
      if (filter == 'gare') garesSelectionne.clear();
      if (filter == 'nature') naturesSelectionne.clear();
      if (filter == 'type') typesSelectionne.clear();
      if (filter == 'date') dateSelectionne = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(12, 19, 31, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(12, 19, 31, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/lookfor-logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              SizedBox(height: 16),
              MultiSelectWidget(
                label: "Gare d'origine",
                valeurSelectionne: garesSelectionne,
                options: gares,
                onConfirm: (values) {
                  setState(() {
                    garesSelectionne = values;
                  });
                },
                onClear: () => reinitialiserFiltres('gare'),
              ),
              SizedBox(height: 16),
              MultiSelectWidget(
                label: "Nature de l'objet",
                valeurSelectionne: naturesSelectionne,
                options: natures,
                onConfirm: (values) {
                  setState(() {
                    naturesSelectionne = values;
                  });
                },
                onClear: () => reinitialiserFiltres('nature'),
              ),
              SizedBox(height: 16),
              MultiSelectWidget(
                label: "Type d'objet",
                valeurSelectionne: typesSelectionne,
                options: types,
                onConfirm: (values) {
                  setState(() {
                    typesSelectionne = values;
                  });
                },
                onClear: () => reinitialiserFiltres('type'),
              ),
              SizedBox(height: 16),
              DatePickerWidget(
                dateSelectionne: dateSelectionne,
                selectionDate: (pickedDate) {
                  setState(() {
                    dateSelectionne = pickedDate;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
                        provider.updateSelectedGares(garesSelectionne);
                        provider.updateSelectedNatures(naturesSelectionne);
                        provider.updateSelectedTypes(typesSelectionne);
                        provider.updateSelectedDate(dateSelectionne);
                        Map<String, String> filters = {};
                        if (dateSelectionne != null) {
                          filters['date'] = DateFormat('yyyy-MM-dd').format(dateSelectionne!);
                        }
                        provider.reinitialiserPagination();
                        provider.recupererObjetsAvecFiltres(filters);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(filters: {}),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromRGBO(121, 201, 243, 1),
                      ),
                      child: Text('Rechercher'),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
                        provider.reinitialiserPagination();
                        provider.recupererObjetsAvecFiltres({});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(filters: {}),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromRGBO(121, 201, 243, 1),
                      ),
                      child: Text('Voir tous les objets'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? lastConnectionDate = await PreferencesManager.getDateDerniereConnexion();
                  if (lastConnectionDate != null) {
                    var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
                    provider.reinitialiserPagination();
                    await provider.recupererObjetsDepuisDerniereConnexion(lastConnectionDate);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(filters: {}, isFromLastConnexion: true),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Aucune date de dernière connexion trouvée.'))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromRGBO(121, 201, 243, 1),
                ),
                child: Text('Rechercher les nouveaux objets'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
