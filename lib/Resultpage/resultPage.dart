import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Provider/objetTrouveProvider.dart';
import '../DetailsPage/detailsPage.dart';

class ResultPage extends StatefulWidget {
  final Map<String, String> filters;
  final bool isFromLastConnexion;

  ResultPage({required this.filters, this.isFromLastConnexion = false});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<ObjetsTrouvesProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        !provider.enChargement && !provider.finPagination) {

      if (widget.isFromLastConnexion) {
        provider.recupererProchainesPagesAvecConnexion();
      } else {
        provider.recupererProchainesPages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(121, 201, 243, 1),
        title: Text(
          'Résultats Objets Trouvés',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Color.fromRGBO(12, 19, 31, 1),
      body: Container(
        color: Color.fromRGBO(12, 19, 31, 1),
        child: Consumer<ObjetsTrouvesProvider>(
          builder: (context, provider, child) {
            if (provider.enChargement && provider.objetsTrouves.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (provider.objetsTrouves.isEmpty && !provider.enChargement) {
              return Center(
                child: Text(
                  'Aucun objet trouvé.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: provider.objetsTrouves.length + (provider.enChargement ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.objetsTrouves.length) {
                  return Center(child: CircularProgressIndicator());
                }

                var objet = provider.objetsTrouves[index];
                String formattedDate;
                try {
                  formattedDate = objet.date != null
                      ? DateFormat('dd/MM/yyyy').format(DateTime.parse(objet.date!))
                      : 'Date inconnue';
                } catch (e) {
                  formattedDate = 'Date inconnue';
                }

                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        objet.nature,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            objet.gareOrigine,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Trouvé le : $formattedDate',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(objetTrouve: objet),
                          ),
                        );
                      },
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: 0.5,
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