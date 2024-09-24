import 'package:flutter/material.dart';
import '../Model/objetTrouve.dart'; // Ton modèle ObjetTrouve

class DetailPage extends StatelessWidget {
  final ObjetTrouve objetTrouve;

  DetailPage({required this.objetTrouve});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'objet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date de perte : ${objetTrouve.date}', style: TextStyle(fontSize: 16)),
            if (objetTrouve.dateRestitution != null)
              Text('Date de restitution : ${objetTrouve.dateRestitution}', style: TextStyle(fontSize: 16)),
            Text('Gare d\'origine : ${objetTrouve.gareOrigine}', style: TextStyle(fontSize: 16)),
            Text('Code UIC de la gare : ${objetTrouve.codeUICGare}', style: TextStyle(fontSize: 16)),
            Text('Nature de l\'objet : ${objetTrouve.nature}', style: TextStyle(fontSize: 16)),
            Text('Type d\'objet : ${objetTrouve.type}', style: TextStyle(fontSize: 16)),
            Text('Nom du type d\'objet : ${objetTrouve.nomTypeObjet}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
