import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/objetTrouveProvider.dart'; // Importer le provider
import 'Homepage/homePage.dart'; // Importer la page d'accueil (HomePage)

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
      home: HomePage(), // Définit HomePage comme la page d'accueil
    );
  }
}
