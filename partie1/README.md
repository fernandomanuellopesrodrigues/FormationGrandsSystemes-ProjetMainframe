# PARTIE 1 : Import des nouveaux produits

## Description
Programme COBOL pour importer les nouveaux produits depuis un fichier CSV vers la base de données API7.PRODUCTS.

## Fonctionnalités
- ✅ Lecture du fichier CSV avec séparateur `;`
- ✅ Conversion des devises (EU→USD, YU→USD, DO→USD)
- ✅ Formatage des descriptions (première lettre de chaque mot en majuscule)
- ✅ Insertion en base de données DB2
- ✅ Génération d'un rapport détaillé
- ✅ Gestion des erreurs et statistiques

## Structure du fichier d'entrée
```
Format : NUMERO_PRODUIT;DESCRIPTION;PRIX;DEVISE
Exemple : P10;USB FLASH DRIVE;15;EU
```

## Taux de conversion
- **EU (Euro)** → Dollar : 1.0850
- **YU (Yuan)** → Dollar : 0.1450  
- **DO (Dollar)** → Dollar : 1.0000 (pas de conversion)

## Fichiers
- `IMPPRODS.cbl` : Programme principal COBOL
- `COMPILE.jcl` : JCL de compilation avec DB2
- `IMPPRODS.jcl` : JCL d'exécution
- `TEST.DATA` : Fichier de test avec 3 produits

## Compilation
```jcl
//COMPILE  JOB ...
//STEP1    EXEC PGM=DSNHPC    (Précompilation DB2)
//STEP2    EXEC PGM=IGYCRCTL  (Compilation COBOL)
//STEP3    EXEC PGM=IEWL      (Link-edit)
//STEP4    EXEC PGM=IKJEFT01  (Bind DB2)
```

## Exécution
```jcl
//IMPPRODS JOB ...
//STEP1    EXEC PGM=IMPPRODS
//NEWPRODS DD DSN=PROJET.NEWPRODS.DATA,DISP=SHR
//REPORTS  DD DSN=AP7.IMPPRODS.REPORT,DISP=(NEW,CATLG)
```

## Exemple de sortie
```
RAPPORT D'IMPORT DES PRODUITS
-----------------------------
PRODUIT: P10 - Usb Flash Drive - 16.28 USD
PRODUIT: P11 - Headphones - 30.50 USD
PRODUIT: P12 - Micro - 3.73 USD
-----------------------------
TOTAL TRAITES: 3 - INSERES: 3 - ERREURS: 0
```

## Tests recommandés
1. **Test conversion devises** : Vérifier EU→USD, YU→USD
2. **Test formatage** : "USB FLASH DRIVE" → "Usb Flash Drive"
3. **Test erreurs** : Produits en doublon, devises inconnues
4. **Test performance** : Fichier avec 1000+ produits

## Prérequis
- Base de données API7 créée
- Table PRODUCTS existante
- Droits d'insertion sur API7.PRODUCTS
- Bibliothèques COBOL et DB2 disponibles
