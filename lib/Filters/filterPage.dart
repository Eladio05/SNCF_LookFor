import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour la gestion des dates
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Package pour la sélection multiple
import '../Provider/objetTrouveProvider.dart';
import '../Homepage/homePage.dart'; // Importer la HomePage

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
      appBar: AppBar(
        title: Text('Filtres Objets Trouvés'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Sélection multiple pour les gares
              _buildMultiSelect(
                context,
                'Gare d\'origine',
                selectedGares,
                gares,
                    () => resetFilter('gare'),
              ),
              SizedBox(height: 16),

              // Sélection multiple pour la nature des objets
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
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
                      icon: Icon(Icons.clear),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(filters: {
                        'gare': selectedGares.isNotEmpty
                            ? selectedGares.join(',')
                            : '',
                        'nature': selectedNatures.isNotEmpty
                            ? selectedNatures.join(',')
                            : '',
                        'type': selectedTypes.isNotEmpty
                            ? selectedTypes.join(',')
                            : '',
                        'date': selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : '',
                      }),
                    ),
                  );
                },
                child: Text('Rechercher'),
              ),

              // Bouton Voir tous les objets
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(filters: {}), // On passe un objet vide
                  ),
                );
              },
              child: Text('Voir tous les objets'),
            ),
          ],
          ),
        ),
      ),
    );
  }

  // Méthode pour construire la sélection multiple avec options sélectionnées en haut
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
          title: Text(label),
          selectedColor: Colors.blue,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          buttonIcon: Icon(
            Icons.arrow_drop_down,
            color: Colors.grey,
          ),
          buttonText: Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          initialValue: selectedValues,
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
            child: selectedValues.length > 2
                ? Chip(label: Text('Filtre multiple sélectionné'))
                : Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: selectedValues
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
