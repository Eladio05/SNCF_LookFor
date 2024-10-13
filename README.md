# SNCF Lookfor

SNCF Lookfor est une application développée en Flutter qui permet aux utilisateurs de retrouver des objets perdus dans les gares SNCF. L'application propose plusieurs filtres de recherche comme la gare d'origine, le type d'objet, la nature de l'objet et la date. De plus, une fonctionnalité permet de filtrer les objets retrouvés depuis la dernière connexion de l'utilisateur à l'application.

## Fonctionnalités principales

- **Recherche d'objets perdus** : Filtrer les objets par gare, type, nature, et date.
- **Filtrage par dernière connexion** : Permet de rechercher uniquement les objets trouvés depuis la dernière connexion de l'utilisateur à l'application.
- **Pagination** : Gère la pagination des résultats pour éviter de surcharger l'interface avec une trop grande quantité d'informations en une seule fois.

## Développement

L'application est développée en **Flutter** et utilise plusieurs packages externes pour faciliter le développement et l'expérience utilisateur.

### Utilisation de l'API SNCF

Nous utilisons l'API SNCF pour récupérer la liste des objets perdus en gare. Chaque appel API permet de récupérer un lot de 100 objets (pour gérer la pagination) et utilise les filtres fournis par l'utilisateur (gare, nature, type, date).

Exemple de construction de l'URL pour l'API :

```dart
String gareFilter = selectedGares.isNotEmpty
    ? 'gc_obo_gare_origine_r_name:("${selectedGares.map(encodeQuery).join('" or "')}")'
    : '';
// Autres filtres (nature, type, date)
```

Ce choix permet de maintenir les filtres flexibles et de les combiner dynamiquement pour affiner les résultats de recherche.

## Structure du projet

### Séparation des responsabilités

- **Provider vs Service** : Le `ObjetsTrouvesProvider` gère l'état de l'application, la pagination et les filtres sélectionnés par l'utilisateur. Il utilise le `ObjetsTrouvesService` pour effectuer les appels API. L'idée est de séparer la logique métier (provider) de la logique de récupération des données (service). Cela permet de garder un code plus lisible et facilement testable.

Exemple :

```dart
final ObjetsTrouvesService _service = ObjetsTrouvesService();
List<ObjetTrouve> objets = await _service.fetchObjetsAvecFiltres(...);
```

Ce choix permet une meilleure évolutivité, car on peut facilement modifier l'implémentation des appels API sans impacter la logique métier de l'application.

Sauvegarde de la date de dernière connexion
Pour la sauvegarde de la date de dernière connexion, on utilise le package shared_preferences qui permet de stocker des données simples localement, sous forme de paires clé-valeur. Cela nous permet de conserver des informations même lorsque l'application est fermée, par exemple la dernière date de connexion de l'utilisateur.

Exemple :
```dart
await prefs.setString('dateDerniereConnexion', date.toIso8601String());
```
Ce choix est simple et efficace, car shared_preferences est léger et facile à utiliser pour des besoins de persistance locale comme celui-ci.

## Multi-sélection de filtres

Pour permettre aux utilisateurs de sélectionner plusieurs valeurs (par exemple plusieurs gares ou types d'objets), nous avons utilisé le package multi_select_flutter. Ce package permet d'afficher une interface de sélection multiple avec une recherche intégrée, rendant l'expérience utilisateur plus agréable et intuitive.

Exemple d'utilisation :
```dart
MultiSelectDialogField<String>(
searchable: true,
items: organizeItems(options, selectedValues),
// ...
)
```
Ce choix a été fait pour simplifier l'implémentation d'une interface utilisateur flexible tout en restant facile à utiliser.

## Packages utilisés

- **flutter** : Framework principal pour le développement de l'application mobile.
- **http** : Pour effectuer les appels API vers l'API SNCF.
- **intl** : Utilisé pour formater les dates.
- **shared_preferences** : Permet de sauvegarder la date de dernière connexion de l'utilisateur.
- **multi_select_flutter** : Fournit des composants pour la sélection multiple avec recherche intégrée.

## Conclusion

L'application **SNCF Lookfor** permet aux utilisateurs de retrouver facilement leurs objets perdus en gare en filtrant les résultats grâce à plusieurs critères. L'implémentation a été pensée pour être modulable, claire et maintenable grâce à la séparation des responsabilités entre les providers et les services, tout en utilisant des packages pratiques comme `shared_preferences` et `multi_select_flutter` pour enrichir l'expérience utilisateur.

