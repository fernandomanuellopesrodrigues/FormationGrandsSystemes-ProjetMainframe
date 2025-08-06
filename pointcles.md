Points clés à retenir :
Priorités de développement suggérées :

Commencer par la Partie 1 (import produits) - c'est la plus simple et elle alimente la base
Puis la Partie 2 (import ventes) - elle utilise les produits de la Partie 1
Ensuite la Partie 3 (factures) - elle utilise les données des parties précédentes
Finir par la Partie 4 (CICS) - la plus complexe techniquement

Défis techniques identifiés :

Conversion des devises : Il faut gérer 3 devises (EU, DO, YU)
Formatage des données : Positions fixes dans les fichiers de ventes
Calculs de factures : TVA et commission à calculer correctement
CICS : Authentification et gestion d'écrans

Questions :
Données manquantes dans les fichiers :
J'ai remarqué que certains prix sont manquants dans les fichiers de ventes (VENTEAS.txt). 

Il faudra soit :
Récupérer les prix depuis la table PRODUCTS
Ou corriger les fichiers de données

