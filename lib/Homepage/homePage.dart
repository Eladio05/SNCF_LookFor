import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/objetTrouveProvider.dart';
import '../DetailsPage/detailsPage.dart';

class HomePage extends StatefulWidget {
  final Map<String, String> filters;

  HomePage({required this.filters});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        backgroundColor: bleuCanard,
        title: Text('Résultats Objets Trouvés'),
      ),
      body: Container(
        color: Colors.white,
        child: Consumer<ObjetsTrouvesProvider>(
          builder: (context, provider, child) {
            if (provider.enChargement) {
              return Center(child: CircularProgressIndicator());
            }

            if (provider.objetsTrouves.isEmpty) {
              return Center(child: Text('Aucun objet trouvé.'));
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!provider.enChargement &&
                    scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  provider.recupererObjetsAvecFiltres(widget.filters);
                }
                return false;
              },
              child: ListView.builder(
                itemCount: provider.objetsTrouves.length,
                itemBuilder: (context, index) {
                  var objet = provider.objetsTrouves[index];

                  return ListTile(
                    title: Text(objet.nature),
                    subtitle: Text(objet.gareOrigine),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(objetTrouve: objet),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
