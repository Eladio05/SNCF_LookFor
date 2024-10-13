import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../Model/objetTrouve.dart';

class DetailPage extends StatefulWidget {
  final ObjetTrouve objetTrouve;

  DetailPage({required this.objetTrouve});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  @override
  Widget build(BuildContext context) {
    String getImageForType(String type) {
      switch (type) {
        case "Appareils électroniques, informatiques, appareils photo":
          return 'assets/images/appareil_electro.png';
        case "Articles d'enfants, de puériculture":
          return 'assets/images/puericulture.png';
        case "Articles de sport, loisirs, camping":
          return 'assets/images/sport.png';
        case "Articles médicaux":
          return 'assets/images/medical.png';
        case "Bagagerie: sacs, valises, cartables":
          return 'assets/images/bagage.png';
        case "Bijoux, montres":
          return 'assets/images/bijoux.png';
        case "Clés, porte-clés, badge magnétique":
          return 'assets/images/cle.png';
        case "Divers":
          return 'assets/images/divers.png';
        case "Instruments de musique":
          return 'assets/images/musique.png';
        case "Livres, articles de papéterie":
          return 'assets/images/livre.png';
        case "Optique":
          return 'assets/images/lunette.png';
        case "Parapluies":
          return 'assets/images/parapluie.png';
        case "Pièces d'identités et papiers personnels":
          return 'assets/images/carte_identite.png';
        case "Porte-monnaie / portefeuille, argent, titres":
          return 'assets/images/porte_monnaie.png';
        case "Vélos, trottinettes, accessoires 2 roues":
          return 'assets/images/velo.png';
        case "Vêtements, chaussures":
          return 'assets/images/vetement.png';
        default:
          return 'assets/images/defaut.png';
      }
    }

    String formatDateTime(String dateTime) {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('d MMMM yyyy', 'fr_FR').format(parsedDate);
    }

    String formatTime(String dateTime) {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('HH:mm').format(parsedDate);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(121, 201, 243, 1),
        title: Text("Détails de l'objet", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color.fromRGBO(12, 19, 31, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                getImageForType(widget.objetTrouve.type),
                width: 250,
                height: 250,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                widget.objetTrouve.nature,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Type d'objet : ${widget.objetTrouve.type}",
              style: TextStyle(
                fontSize: 16, color: Colors.white),
            ),
            Text(
              "Date de perte : ${formatDateTime(widget.objetTrouve.date)}",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text(
              "Heure de perte : ${formatTime(widget.objetTrouve.date)}",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            if (widget.objetTrouve.dateRestitution != null)
              Text(
                "Date de restitution : ${formatDateTime(widget.objetTrouve.dateRestitution!)}",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            SizedBox(height: 10),
            Text(
              "Gare d'origine : ${widget.objetTrouve.gareOrigine}",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
