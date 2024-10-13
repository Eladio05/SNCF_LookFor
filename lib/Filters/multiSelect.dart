import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MultiSelectWidget extends StatelessWidget {
  final String label;
  final List<String> valeurSelectionne;
  final List<String> options;
  final Function(List<String>) onConfirm;
  final VoidCallback onClear;

  MultiSelectWidget({
    required this.label,
    required this.valeurSelectionne,
    required this.options,
    required this.onConfirm,
    required this.onClear,
  });

  List<MultiSelectItem<String>> organizeItems(
      List<String> options, List<String> selectedValues) {
    List<MultiSelectItem<String>> selectedItems = selectedValues
        .map((value) => MultiSelectItem<String>(value, value))
        .toList();
    List<MultiSelectItem<String>> unselectedItems = options
        .where((option) => !selectedValues.contains(option))
        .map((option) => MultiSelectItem<String>(option, option))
        .toList();
    return [...selectedItems, ...unselectedItems];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiSelectDialogField<String>(
          searchable: true,
          items: organizeItems(options, valeurSelectionne),
          title: Text(label, style: TextStyle(color: Colors.white)),
          selectedColor: Color.fromRGBO(121, 201, 243, 1),
          backgroundColor: Color.fromRGBO(12, 19, 31, 1),
          selectedItemsTextStyle: TextStyle(color: Color.fromRGBO(121, 201, 243, 1)),
          itemsTextStyle: TextStyle(color: Colors.white),
          buttonIcon: Icon(Icons.arrow_drop_down, color: Colors.white),
          buttonText: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
          searchHintStyle: TextStyle(color: Colors.white), // Barre de recherche en blanc
          searchTextStyle: TextStyle(color: Colors.white), // Texte de recherche en blanc
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Color.fromRGBO(121, 201, 243, 1), width: 1),
          ),
          initialValue: List.from(valeurSelectionne),
          onConfirm: (values) => onConfirm(values),
          chipDisplay: MultiSelectChipDisplay.none(),
        ),
        if (valeurSelectionne.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: valeurSelectionne.length > 2
                  ? [
                Chip(
                  label: Text('Filtres multiples sélectionnés'),
                  onDeleted: onClear,
                  backgroundColor: Colors.white,
                )
              ]
                  : valeurSelectionne
                  .map((value) => Chip(
                label: Text(value),
                onDeleted: () => onConfirm(valeurSelectionne..remove(value)),
              ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
