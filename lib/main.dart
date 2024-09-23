import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'objetTrouveProvider.dart'; // Le provider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ObjetsTrouvesProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNCF LookFor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // L'écran d'accueil
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Couleurs
  final Color bleuCanard = Color(0xFF006994);

  @override
  void initState() {
    super.initState();
    // Charger les 100 premiers objets au démarrage via le provider
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
        color: Colors.white, // Fond blanc
        child: Consumer<ObjetsTrouvesProvider>(
          builder: (context, provider, child) {
            if (provider.objetsTrouves.isEmpty && !provider.enChargement) {
              // Affichage de l'indicateur de chargement au début
              return Center(child: CircularProgressIndicator());
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Charger plus d'objets quand on arrive en bas
                if (!provider.enChargement && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  provider.recupererObjets();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: provider.objetsTrouves.length + (provider.enChargement ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == provider.objetsTrouves.length) {
                    return Center(child: CircularProgressIndicator()); // Loader pendant le chargement
                  }
                  var objet = provider.objetsTrouves[index];

                  return ListTile(
                    title: Text(objet.nature), // Afficher la nature de l'objet
                    subtitle: Text(objet.gareOrigine), // Afficher la gare d'origine
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
