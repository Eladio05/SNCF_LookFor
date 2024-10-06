import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Ajout de cet import pour utiliser DateFormat
import '../Provider/objetTrouveProvider.dart';
import '../Model/objetTrouve.dart'; // Assurez-vous d'importer votre modèle ObjetTrouve
import '../DetailsPage/detailsPage.dart'; // Importer la page de détails

class ResultPage extends StatefulWidget {
  final Map<String, String> filters;

  ResultPage({required this.filters});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final Color bleuCanard = Color(0xFF006994);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObjetsTrouvesProvider>(context, listen: false)
          .recupererObjetsAvecFiltres(widget.filters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(121, 201, 243, 1), // Couleur app bar
        title: Text(
          'Résultats Objets Trouvés',
          style: TextStyle(color: Colors.white), // Texte blanc
        ),
      ),
      backgroundColor: Color.fromRGBO(12, 19, 31, 1), // Arrière-plan de la page
      body: Container(
        color: Color.fromRGBO(12, 19, 31, 1), // Assurez-vous que l'arrière-plan soit uniformisé
        child: Consumer<ObjetsTrouvesProvider>(
          builder: (context, provider, child) {
            if (provider.enChargement && provider.objetsTrouves.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (provider.objetsTrouves.isEmpty && !provider.enChargement) {
              return Center(
                child: Text(
                  'Aucun objet trouvé.',
                  style: TextStyle(color: Colors.white), // Texte en blanc
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.objetsTrouves.length,
              itemBuilder: (context, index) {
                var objet = provider.objetsTrouves[index];

                // On convertit l'attribut date en DateTime si c'est une chaîne de caractères
                String formattedDate;
                try {
                  formattedDate = objet.date != null
                      ? DateFormat('yyyy-MM-dd').format(DateTime.parse(objet.date!))
                      : 'Date inconnue'; // Formattage de la date si elle existe
                } catch (e) {
                  formattedDate = 'Date inconnue'; // En cas d'erreur lors de la conversion
                }

                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        objet.nature,
                        style: TextStyle(color: Colors.white), // Texte en blanc
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            objet.gareOrigine,
                            style: TextStyle(color: Colors.white), // Texte en blanc
                          ),
                          Text(
                            'Trouvé le : $formattedDate', // Ajout de la date
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(objetTrouve: objet), // Navigation vers la page de détails
                          ),
                        );
                      },
                    ),
                    Divider(
                      color: Colors.white, // Couleur de la ligne de séparation
                      thickness: 0.5, // Épaisseur de la ligne
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
