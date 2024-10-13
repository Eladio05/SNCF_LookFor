import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime? dateSelectionne;
  final Function(DateTime?) selectionDate;

  DatePickerWidget({required this.dateSelectionne, required this.selectionDate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Sélectionner une date',
              hintText: dateSelectionne == null ? 'Aucune date sélectionnée' : null,
              hintStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(121, 201, 243, 1)),
              ),
            ),
            style: TextStyle(color: Colors.white),
            controller: TextEditingController(
              text: dateSelectionne != null
                  ? DateFormat('yyyy-MM-dd').format(dateSelectionne!)
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
                        primary: Color.fromRGBO(121, 201, 243, 1),
                        onPrimary: Colors.white,
                        surface: Color.fromRGBO(12, 19, 31, 1),
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: Color.fromRGBO(12, 19, 31, 1),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                selectionDate(picked);
              }
            },
          ),
        ),
        if (dateSelectionne != null)
          IconButton(
            icon: Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              selectionDate(null);
            },
          ),
      ],
    );
  }
}
