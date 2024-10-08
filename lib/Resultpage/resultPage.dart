import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour la gestion des dates
import '../Provider/objetTrouveProvider.dart';
import '../Model/objetTrouve.dart'; // Assurez-vous d'importer votre modèle ObjetTrouve
import '../DetailsPage/detailsPage.dart'; // Importer la page de détails

class ResultPage extends StatefulWidget {
  final Map<String, String> filters;
  final bool isFromLastConnexion; // Ajout d'un paramètre pour vérifier si c'est depuis la dernière connexion

  ResultPage({required this.filters, this.isFromLastConnexion = false});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final Color bleuCanard = Color(0xFF006994);
  late ScrollController _scrollController; // Controller pour gérer le défilement

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // Initialisation du ScrollController
    _scrollController.addListener(_onScroll); // Ajout du listener pour surveiller le défilement
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose du ScrollController
    super.dispose();
  }

  // Méthode appelée quand on scrolle la liste
  void _onScroll() {
    final provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        !provider.enChargement && !provider.finPagination) {

      if (widget.isFromLastConnexion) {
        // Si la page est chargée depuis la dernière connexion, on continue à utiliser la date de connexion
        provider.recupererProchainesPagesAvecConnexion();
      } else {
        // Si on est en bas de la liste, que l'on ne charge pas déjà et qu'il reste des données à charger
        provider.recupererProchainesPages(); // Charger les prochaines pages
      }
    }
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
              controller: _scrollController, // Utilisation du ScrollController
              itemCount: provider.objetsTrouves.length + (provider.enChargement ? 1 : 0), // Ajout d'un élément pour l'indicateur de chargement
              itemBuilder: (context, index) {
                if (index == provider.objetsTrouves.length) {
                  return Center(child: CircularProgressIndicator()); // Affichage du loader en bas
                }

                var objet = provider.objetsTrouves[index];

                // On convertit l'attribut date en DateTime si c'est une chaîne de caractères
                String formattedDate;
                try {
                  formattedDate = objet.date != null
                      ? DateFormat('dd/MM/yyyy').format(DateTime.parse(objet.date!)) // Formattage en JJ/MM/AAAA
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
