import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/objetTrouveProvider.dart';
import 'Filters/filterPage.dart';

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
        fontFamily: 'Avenir'
      ),
      home: FiltersPage(),
    );
  }
}
