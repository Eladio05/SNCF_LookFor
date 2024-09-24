import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/objetTrouve.dart'; // Ton modèle ObjetTrouve
import '../Provider/objetTrouveProvider.dart';
import '../DetailsPage/detailsPage.dart'; // La nouvelle page de détails

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color bleuCanard = Color(0xFF006994);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObjetsTrouvesProvider>(context, listen: false).recupererObjets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bleuCanard,
        title: Text('SNCF LookFor'),
      ),
      body: Container(
        color: Colors.white,
        child: Consumer<ObjetsTrouvesProvider>(
          builder: (context, provider, child) {
            if (provider.objetsTrouves.isEmpty && !provider.enChargement) {
              return Center(child: CircularProgressIndicator());
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!provider.enChargement && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  provider.recupererObjets();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: provider.objetsTrouves.length + (provider.enChargement ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == provider.objetsTrouves.length) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var objet = provider.objetsTrouves[index];

                  return ListTile(
                    title: Text(objet.nature),
                    subtitle: Text(objet.gareOrigine),
                    onTap: () {
                      // Naviguer vers la page de détails en passant l'objet trouvé
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
