import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static Future<void> sauvegardeDateDerniereConnexion(DateTime date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool result = await prefs.setString('dateDerniereConnexion', date.toIso8601String());
      if (result) {
        print('Date de dernière connexion sauvegardée avec succès : $date');
      } else {
        print('Échec de la sauvegarde de la date de dernière connexion.');
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde de la date de dernière connexion : $e');
    }
  }

  static Future<DateTime?> getDateDerniereConnexion() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dernieredateConnexionString = prefs.getString('dateDerniereConnexion');
      if (dernieredateConnexionString != null) {
        DateTime date = DateTime.parse(dernieredateConnexionString);
        print('Date de dernière connexion récupérée : $date');
        return date;
      } else {
        print('Aucune date de dernière connexion trouvée.');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la date de dernière connexion : $e');
    }
    return null;
  }

  static Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dateDerniereConnexion');
    print('Préférences réinitialisées.');
  }
}
