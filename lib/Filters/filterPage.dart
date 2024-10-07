import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour la gestion des dates
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Package pour la sélection multiple
import 'package:shared_preferences/shared_preferences.dart'; // Pour stocker et récupérer la dernière connexion
import 'package:sncf_lookfor/Resultpage/resultPage.dart';
import '../Provider/objetTrouveProvider.dart';

class FiltersPage extends StatefulWidget {
  @override
  _FiltersPageState createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> with WidgetsBindingObserver {
  List<String> selectedGares = []; // Modifié pour permettre la sélection multiple
  List<String> selectedNatures = []; // Modifié pour permettre la sélection multiple
  List<String> selectedTypes = []; // Modifié pour permettre la sélection multiple
  DateTime? selectedDate;
  List<String> gares = [];
  List<String> natures = [];
  List<String> types = [];
  DateTime? lastLoginDate; // Dernière connexion de l'utilisateur

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Ajout de l'observateur pour surveiller le cycle de vie de l'application
    loadOptionsFromAPI();
    getLastLoginDate(); // Charger la dernière connexion au démarrage
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Retirer l'observateur lorsque la page est détruite
    super.dispose();
  }

  // Méthode pour écouter les changements de cycle de vie de l'application
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Lorsque l'application passe en arrière-plan, on enregistre la date de dernière connexion
      saveLastLoginDate(DateTime.now());
    }
  }

  // Charger les options de l'API
  Future<void> loadOptionsFromAPI() async {
    var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
    gares = await provider.getDistinctOptions('gc_obo_gare_origine_r_name');
    natures = await provider.getDistinctOptions('gc_obo_nature_c');
    types = await provider.getDistinctOptions('gc_obo_type_c');
    setState(() {}); // Met à jour l'interface après le chargement des options
  }

  // Récupérer la date de la dernière connexion
  Future<void> getLastLoginDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastLoginDateString = prefs.getString('lastLoginDate');
    if (lastLoginDateString != null) {
      lastLoginDate = DateTime.parse(lastLoginDateString);
      setState(() {});
    }
  }

  // Enregistrer la date de la dernière connexion
  Future<void> saveLastLoginDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastLoginDate', date.toIso8601String());
  }

  // Réinitialiser un filtre
  void resetFilter(String filter) {
    setState(() {
      if (filter == 'gare') selectedGares.clear();
      if (filter == 'nature') selectedNatures.clear();
      if (filter == 'type') selectedTypes.clear();
      if (filter == 'date') selectedDate = null;
    });
  }

  // Méthode pour organiser les options : les options sélectionnées apparaissent en haut
  List<MultiSelectItem<String>> organizeItems(
      List<String> options, List<String> selectedValues) {
    List<MultiSelectItem<String>> selectedItems = selectedValues
        .map((value) => MultiSelectItem<String>(value, value))
        .toList();
    List<MultiSelectItem<String>> unselectedItems = options
        .where((option) => !selectedValues.contains(option))
        .map((option) => MultiSelectItem<String>(option, option))
        .toList();
    return [
      ...selectedItems,
      ...unselectedItems,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(12, 19, 31, 1), // Arrière-plan
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(12, 19, 31, 1), // Même couleur que l'arrière-plan
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0), // Ajustement du padding pour positionner le logo plus haut
          child: Column(
            children: [
              // Logo centré
              Center(
                child: Image.asset(
                  'assets/images/lookfor-logo.png', // Assurez-vous que le logo est bien dans ce chemin
                  width: 150, // Ajustez la taille du logo
                  height: 150,
                ),
              ),
              // Espacement avant les filtres
// Espacement réduit après le logo

            // Sélection multiple pour les gares avec recherche intégrée
            _buildMultiSelect(
              context,
              'Gare d\'origine',
              selectedGares,
              gares,
                  () => resetFilter('gare'),
            ),
            SizedBox(height: 16),

            // Sélection multiple pour la nature des objets avec recherche intégrée
            _buildMultiSelect(
              context,
              'Nature de l\'objet',
              selectedNatures,
              natures,
                  () => resetFilter('nature'),
            ),
            SizedBox(height: 16),

            // Sélection multiple pour le type des objets
            _buildMultiSelect(
              context,
              'Type d\'objet',
              selectedTypes,
              types,
                  () => resetFilter('type'),
            ),
            SizedBox(height: 16),

            // Sélection de la date avec la croix pour réinitialiser
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Sélectionner une date',
                      hintText: selectedDate == null
                          ? 'Aucune date sélectionnée'
                          : null,
                      hintStyle: TextStyle(color: Colors.white), // Texte blanc
                      labelStyle: TextStyle(color: Colors.white), // Label en blanc
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(121, 201, 243, 1), // Couleur du contour
                        ),
                      ),
                    ),
                    style: TextStyle(color: Colors.white), // Texte blanc
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : '',
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Color.fromRGBO(121, 201, 243, 1), // Couleur du texte (sélection)
                                onPrimary: Colors.white, // Texte sur le bouton de sélection
                                surface: Color.fromRGBO(12, 19, 31, 1), // Arrière-plan du calendrier
                                onSurface: Colors.white, // Couleur du texte (jours)
                              ),
                              dialogBackgroundColor: Color.fromRGBO(12, 19, 31, 1), // Arrière-plan du calendrier
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                if (selectedDate != null) // Si une date est sélectionnée, on affiche une croix pour réinitialiser
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      resetFilter('date');
                    },
                  ),
              ],
            ),
            SizedBox(height: 20),

            // Boutons "Rechercher" et "Voir tous les objets" sur la même ligne
              // Boutons "Rechercher" et "Voir tous les objets" sur la même ligne
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Mettre à jour les filtres sélectionnés dans le provider
                        var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
                        provider.updateSelectedGares(selectedGares);
                        provider.updateSelectedNatures(selectedNatures);
                        provider.updateSelectedTypes(selectedTypes);
                        provider.updateSelectedDate(selectedDate);

                        // Appeler reinitialiserPagination ici avant la recherche
                        provider.reinitialiserPagination();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(filters: {}),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(121, 201, 243, 1),
                      ),
                      child: Text('Rechercher'),
                    ),
                  ),
                  SizedBox(width: 5), // Réduction de l'espacement entre les deux boutons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Réinitialisation des filtres avant de voir tous les objets
                        var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
                        provider.reinitialiserPagination();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(filters: {}), // On passe un objet vide
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(121, 201, 243, 1),
                      ),
                      child: Text('Voir tous les objets'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10), // Réduction de l'espacement entre les boutons et le bouton suivant
// Bouton "Rechercher les nouveaux objets"
              ElevatedButton(
                onPressed: () async {
                  // Récupérer la date de la dernière connexion
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? lastConnectionDateStr = prefs.getString('derniereConnexion');
                  if (lastConnectionDateStr != null) {
                    DateTime derniereConnexion = DateTime.parse(lastConnectionDateStr);

                    var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
                    // Rechercher les objets trouvés après la dernière connexion
                    provider.reinitialiserPagination();
                    await provider.recupererObjetsDepuisDerniereConnexion(derniereConnexion);

                    // Naviguer vers la page de résultats avec les objets trouvés
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(filters: {}), // Rediriger vers la page de résultats
                      ),
                    );
                  } else {
                    // Si aucune connexion précédente n'est enregistrée, afficher un message
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
              SizedBox(height: 20), // Espacement avant le nouveau bouton

                    // Bouton "Rechercher les nouveaux objets"
                    ElevatedButton(
                      onPressed: () async {
                        // Récupérer la date de la dernière connexion
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? lastConnectionDateStr = prefs.getString('derniereConnexion');
                        if (lastConnectionDateStr != null) {
                          DateTime derniereConnexion = DateTime.parse(lastConnectionDateStr);

                          var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
                          // Rechercher les objets trouvés après la dernière connexion
                          provider.reinitialiserPagination();
                          await provider.recupererObjetsDepuisDerniereConnexion(derniereConnexion);

                          // Naviguer vers la page de résultats avec les objets trouvés
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultPage(filters: {}),
                            ),
                          );
                        } else {
                          // Si aucune connexion précédente n'est enregistrée, afficher un message
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
                  ],
              ),
            ),
        ),
    );
  }

  // Méthode pour construire la sélection multiple sans recherche
  Widget _buildMultiSelect(
      BuildContext context,
      String label,
      List<String> selectedValues,
      List<String> options,
      VoidCallback onClear,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiSelectDialogField<String>(
          items: organizeItems(options, selectedValues),
          title: Text(label, style: TextStyle(color: Colors.white)),
          selectedColor: Color.fromRGBO(121, 201, 243, 1),
          selectedItemsTextStyle: TextStyle(color: Color.fromRGBO(121, 201, 243, 1)),
          backgroundColor: Color.fromRGBO(12, 19, 31, 1),
          itemsTextStyle: TextStyle(color: Colors.white),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Color.fromRGBO(121, 201, 243, 1), width: 1),
          ),
          buttonIcon: Icon(Icons.arrow_drop_down, color: Colors.white),
          buttonText: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          initialValue: List.from(selectedValues),
          onConfirm: (values) {
            setState(() {
              selectedValues.clear();
              selectedValues.addAll(values);
            });
          },
          chipDisplay: MultiSelectChipDisplay.none(),
        ),
        if (selectedValues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: selectedValues.length > 2
                  ? [
                Chip(
                  label: Text('Filtre multiple sélectionné'),
                  onDeleted: onClear,
                  backgroundColor: Colors.white,
                )
              ]
                  : selectedValues
                  .map(
                    (value) => Chip(
                  label: Text(value),
                  onDeleted: () {
                    setState(() {
                      selectedValues.remove(value);
                    });
                  },
                ),
              )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
