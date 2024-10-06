import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour la gestion des dates
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Package pour la sélection multiple
import '../Provider/objetTrouveProvider.dart';
import '../Resultpage/resultPage.dart'; // Importer la HomePage

class FiltersPage extends StatefulWidget {
  @override
  _FiltersPageState createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  List<String> selectedGares = []; // Modifié pour permettre la sélection multiple
  List<String> selectedNatures = []; // Modifié pour permettre la sélection multiple
  List<String> selectedTypes = []; // Modifié pour permettre la sélection multiple
  DateTime? selectedDate;
  List<String> gares = [];
  List<String> natures = [];
  List<String> types = [];

  @override
  void initState() {
    super.initState();
    loadOptionsFromAPI();
  }

  Future<void> loadOptionsFromAPI() async {
    var provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
    gares = await provider.getDistinctOptions('gc_obo_gare_origine_r_name');
    natures = await provider.getDistinctOptions('gc_obo_nature_c');
    types = await provider.getDistinctOptions('gc_obo_type_c');
    setState(() {}); // Met à jour l'interface après le chargement des options
  }

  // Réinitialise le filtre sélectionné
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo centré
              SizedBox(height: 30),
              Center(
                child: Image.asset(
                  'assets/images/lookfor-logo.png', // Assurez-vous que le logo est bien dans ce chemin
                  width: 150, // Ajustez la taille du logo
                  height: 150,
                ),
              ),
              SizedBox(height: 30), // Espacement avant les filtres

              // Sélection multiple pour les gares avec recherche intégrée
              _buildMultiSelectWithSearch(
                context,
                'Gare d\'origine',
                selectedGares,
                gares,
                    () => resetFilter('gare'),
              ),
              SizedBox(height: 16),

              // Sélection multiple pour la nature des objets avec recherche intégrée
              _buildMultiSelectWithSearch(
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
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData(
                                colorScheme: ColorScheme.dark(
                                  primary: Color.fromRGBO(121, 201, 243, 1), // Couleur de sélection
                                  onPrimary: Colors.white, // Texte sur la couleur de sélection
                                  surface: Color.fromRGBO(12, 19, 31, 1), // Couleur de fond du calendrier
                                  onSurface: Color.fromRGBO(121, 201, 243, 1), // Texte du calendrier
                                ),
                                dialogBackgroundColor: Color.fromRGBO(12, 19, 31, 1), // Arrière-plan du dialogue
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

              // Bouton Rechercher
              ElevatedButton(
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
                  foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(121, 201, 243, 1), // Couleur du texte
                ),
                child: Text('Rechercher'),
              ),

              // Bouton Voir tous les objets
              ElevatedButton(
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
                  foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(121, 201, 243, 1), // Couleur du texte
                ),
                child: Text('Voir tous les objets'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour construire la sélection multiple avec recherche intégrée dans la liste déroulante
  Widget _buildMultiSelectWithSearch(
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
          title: Text(label, style: TextStyle(color: Colors.white)), // Texte blanc
          searchable: true,  // Ajout de la fonctionnalité de recherche intégrée
          selectedColor: Color.fromRGBO(121, 201, 243, 1), // Couleur sélectionnée
          selectedItemsTextStyle: TextStyle(color: Color.fromRGBO(121, 201, 243, 1)), // Couleur du texte des éléments sélectionnés
          backgroundColor: Color.fromRGBO(12, 19, 31, 1), // Couleur de fond de la popup
          itemsTextStyle: TextStyle(color: Colors.white), // Texte des options en blanc
          searchHintStyle: TextStyle(color: Colors.grey), // Texte d'indication en gris pour la recherche
          searchHint: 'Rechercher...', // Texte pour le champ de recherche
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Color.fromRGBO(121, 201, 243, 1), // Couleur de la bordure
              width: 1,
            ),
          ),
          buttonIcon: Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
          buttonText: Text(
            label,
            style: TextStyle(
              color: Colors.white, // Texte blanc
              fontSize: 16,
            ),
          ),
          initialValue: List.from(selectedValues),  // Mettre à jour la sélection
          onConfirm: (values) {
            setState(() {
              selectedValues.clear();
              selectedValues.addAll(values);
            });
          },
          chipDisplay: MultiSelectChipDisplay.none(), // Désactivation des chips individuels
        ),
        // Affichage du texte "Filtre multiple sélectionné"
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
                  backgroundColor: Colors.white, // Texte du chip en blanc
                )
              ]
                  : selectedValues
                  .map((value) => Chip(
                label: Text(value),
                onDeleted: () {
                  setState(() {
                    selectedValues.remove(value);
                  });
                },
              ))
                  .toList(),
            ),
          ),
      ],
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
          title: Text(label, style: TextStyle(color: Colors.white)), // Texte blanc
          selectedColor: Color.fromRGBO(121, 201, 243, 1), // Couleur sélectionnée
          selectedItemsTextStyle: TextStyle(color: Color.fromRGBO(121, 201, 243, 1)), // Couleur du texte des éléments sélectionnés
          backgroundColor: Color.fromRGBO(12, 19, 31, 1), // Couleur de fond de la popup
          itemsTextStyle: TextStyle(color: Colors.white), // Texte des options en blanc
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Color.fromRGBO(121, 201, 243, 1), // Couleur de la bordure
              width: 1,
            ),
          ),
          buttonIcon: Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
          buttonText: Text(
            label,
            style: TextStyle(
              color: Colors.white, // Texte blanc
              fontSize: 16,
            ),
          ),
          initialValue: List.from(selectedValues),  // Mettre à jour la sélection
          onConfirm: (values) {
            setState(() {
              selectedValues.clear();
              selectedValues.addAll(values);
            });
          },
          chipDisplay: MultiSelectChipDisplay.none(), // Désactivation des chips individuels
        ),
        // Affichage du texte "Filtre multiple sélectionné"
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
                  backgroundColor: Colors.white, // Texte du chip en blanc
                )
              ]
                  : selectedValues
                  .map((value) => Chip(
                label: Text(value),
                onDeleted: () {
                  setState(() {
                    selectedValues.remove(value);
                  });
                },
              ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
