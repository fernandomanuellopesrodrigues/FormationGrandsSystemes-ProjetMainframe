# Tests de validation des entrées

- Pièce avec tous les champs valides
- Pièce sans numéro
- Pièce sans nom
- Pièce avec un poids non numérique
- Pièce avec un nom trop long

## Tests a ajouter

1. Tests de logique métier :
    - Ajout d'une pièce qui existe déjà
    - Vérification de la sensibilité à la casse des noms de pièces
2. Tests d'intégration :
    - Vérification que la pièce est bien enregistrée dans le fichier VSAM
    - Vérification des messages d'erreur appropriés
