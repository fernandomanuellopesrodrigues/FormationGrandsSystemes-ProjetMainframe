# Projet MAINFRAME AJCFRAME - Analyse détaillée

## Vue d'ensemble du projet
La société AJCFRAME souhaite moderniser son système de gestion des produits et des ventes avec 4 parties principales :
1. Import de nouveaux produits avec conversion de devises
2. Import des ventes depuis prestataires européens et asiatiques
3. Génération de factures
4. Interface CICS pour saisie de pièces

---

## PARTIE 1 : Import des nouveaux produits

### Objectif
Traiter le fichier `PROJET.NEWPRODS.DATA` (format CSV avec séparateur `;`) et insérer les données dans la base.

### Structure du fichier d'entrée
```
Format : NUMERO_PRODUIT;DESCRIPTION;PRIX;DEVISE
Exemple : P10;USB FLASH DRIVE;15;EU
```
### Étapes de développement

#### 1. Programme de lecture et traitement
```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID. IMPORT-PRODUCTS.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-PRODUCT-RECORD.
   05 WS-PRODUCT-NO      PIC X(3).
   05 FILLER             PIC X VALUE ';'.
   05 WS-DESCRIPTION     PIC X(30).
   05 FILLER             PIC X VALUE ';'.
   05 WS-PRICE           PIC 9(3)V99.
   05 FILLER             PIC X VALUE ';'.
   05 WS-CURRENCY        PIC XX.

01 WS-CONVERSION-RATES.
   05 WS-EU-RATE         PIC 9V9999 VALUE 1.0850.  * Euro vers Dollar
   05 WS-YU-RATE         PIC 9V9999 VALUE 0.1450.  * Yuan vers Dollar
   05 WS-DO-RATE         PIC 9V9999 VALUE 1.0000.  * Dollar (référence)
```

#### 2. Logique de conversion des devises
- **EU (Euro)** → Dollar : multiplier par 1.0850
- **YU (Yuan)** → Dollar : multiplier par 0.1450  
- **DO (Dollar)** → Dollar : pas de conversion (1.0000)

#### 3. Formatage des descriptions
Transformer "USB FLASH DRIVE" en "Usb Flash Drive" (majuscule au début de chaque mot)

#### 4. Insertion en base
```sql
INSERT INTO APIX.PRODUCTS (P_NO, DESCRIPTION, PRICE)
VALUES (:WS-PRODUCT-NO, :WS-FORMATTED-DESC, :WS-CONVERTED-PRICE)
```

---

## PARTIE 2 : Import des ventes

### Objectif
Traiter les fichiers de ventes européennes (`PROJET.VENTESEU.DATA`) et asiatiques (`PROJET.VENTESAS.DATA`) et mettre à jour les balances clients.

### Structure des fichiers
```
Positions : 1-3   : N° Commande
           4-13  : Date (JJ/MM/AAAA)
           14-15 : N° Employé
           16-19 : N° Client
           20-22 : N° Produit
           23-27 : Prix (5 dont 2 décimales)
           28-29 : Quantité
           30-35 : Réservé
```

### Données analysées

#### Fichier VENTESAS (Asie)
- **Commande 501** (15/10/2022) : Client 0003, Employé 20
  - P02 : 01549 × 10 = 154.90 +
  - P03 : 03575 × 02 = 71.50
- **Commande 502** (02/11/2022) : Client 0002, Employé 30
  - P05 : 05025 × 07 = 351.75
- **Commande 503** (05/11/2022) : Client 0001, Employé 50
  - P15 : ? × 10 (prix manquant)
- **Commande 505** (17/11/2022) : Client 0004, Employé 40
  - P10 : ? × 01 + (prix manquants)
  - P12 : ? × 04 (prix manquants)
 
#### Fichier VENTESEU (Europe)
- **Commande 500** (10/10/2022) : Client 0004, Employé 10
  - P01 : 02599 × 03 = 77.97 +
  - P03 : 03575 × 02 = 71.50 +
  - P04 : 01000 × 05 = 50.00
- **Commande 502** (02/11/2022) : Client 0002, Employé 30 
  - P03 : 03575 × 02 = 71.50 +
  - P04 : 01000 × 05 = 50.00
- **Commande 503** (05/11/2022) : Client 0001, Employé 50 
  - P11 : ? × 05 = ? + (prix manquants)
- **Commande 504** (07/11/2022) : Client 0003, Employé 40
  - P14 : ? × 01 = ? + (prix manquants)
  - P18 : ? × 04 = ? + (prix manquants)

### Étapes de développement

#### 1. Programme de lecture des fichiers
```cobol
01 SALES-RECORD.
   05 ORDER-NO           PIC 999.
   05 ORDER-DATE         PIC X(10).
   05 EMP-NO             PIC 99.
   05 CUST-NO            PIC 9999.
   05 PROD-NO            PIC XXX.
   05 PRICE              PIC 99999.
   05 QUANTITY           PIC 99.
   05 FILLER             PIC X(6).
```

#### 2. Insertion dans ORDERS
```sql
INSERT INTO APIX.ORDERS (O_NO, S_NO, C_NO, O_DATE)
VALUES (:ORDER-NO, :EMP-NO, :CUST-NO, :FORMATTED-DATE)
```

#### 3. Insertion dans ITEMS
```sql
INSERT INTO APIX.ITEMS (O_NO, P_NO, QUANTITY, PRICE)
VALUES (:ORDER-NO, :PROD-NO, :QUANTITY, :PRICE-FORMATTED)
```

#### 4. Mise à jour des balances clients
```sql
UPDATE APIX.CUSTOMERS 
SET BALANCE = BALANCE + :TOTAL-ORDER
WHERE C_NO = :CUST-NO
```

---

## PARTIE 3 : Génération de factures

### Objectif
Créer des factures pour chaque commande au format spécifié.

### Étapes de développement

#### 1. Export des données vers fichier
```sql
SELECT O.O_NO, O.O_DATE, C.COMPANY, C.ADDRESS, C.CITY, C.ZIP, C.STATE, E.LNAME, E.FNAME, D.DNAME, I.P_NO, P.DESCRIPTION, I.QUANTITY, I.PRICE
FROM APIX.ORDERS O
JOIN APIX.CUSTOMERS C ON O.C_NO = C.C_NO  
JOIN APIX.EMPLOYEES E ON O.S_NO = E.E_NO
JOIN APIX.DEPTS D ON E.DEPT = D.DEPT
JOIN APIX.ITEMS I ON O.O_NO = I.O_NO
JOIN APIX.PRODUCTS P ON I.P_NO = P.P_NO
ORDER BY O.O_NO
```

#### 2. Sous-programme de formatage de date
```cobol
PROGRAM-ID. DATE-FORMATTER.
* Convertir 2024-12-19 en "Thursday, December 19, 2024"
```

#### 3. Calculs de la facture
- **Sous-total** : Somme des (quantité × prix)
- **TVA** : Sous-total × taux TVA (lu en SYSIN)  
- **Commission** : Sous-total × 9.9%
- **Total** : Sous-total + TVA + Commission

#### 4. Programme principal de génération
```cobol
PROGRAM-ID. GENERATE-INVOICES.
* Lecture du fichier extract
* Appel du sous-programme de date
* Formatage et écriture de chaque facture
```

---

## PARTIE 4 : Interface CICS pour saisie de pièces

### Objectif
Créer une IHM sécurisée pour ajouter des pièces dans `PROJET.NEWPARTS.KSDS`.

### Architecture CICS

#### 1. Fichiers VSAM
- **PARTSX** : Fichier des nouvelles pièces (PROJET.NEWPARTS.KSDS)
- **USERSX** : Fichier des employés (AJC.EMPLOYE.KSDS)

#### 2. Ressources CICS
- **Transaction** : TXXX (où X = nom du groupe)
- **Mapset** : MSXX
- **Map** : MAPXX

#### 3. Programmes CICS

##### Programme d'authentification
```cobol
PROGRAM-ID. AUTHXX.
* Vérification login/mot de passe depuis USERSX
* Si OK → passage à l'écran de saisie
* Si KO → message d'erreur
```

##### Programme de saisie de pièces
```cobol  
PROGRAM-ID. PARTSXX.
* Saisie des données pièces
* Validation des données
* Écriture dans PARTSX
* Gestion des doublons
```

#### 4. Maps BMS
```
Écran de login :
+------------------+
| Login    : ____  |
| Password : ____  | 
|                  |
| [ENTER] [CLEAR]  |
+------------------+

Écran saisie pièces :
+------------------------+
| Part Number : ___      |
| Part Name   : ________ |
| Color       : ________ |
| Weight      : ___      |
| City        : ________ |
|                        |
| [SAVE] [CLEAR] [EXIT]  |
+------------------------+
```

---

## Architecture technique générale

### Structure des programmes
```
PARTIE 1: COBOL Batch
├── IMPORT-PRODUCTS.cob (principal)
├── CURRENCY-CONVERT.cob (sous-programme)
└── FORMAT-DESC.cob (sous-programme)

PARTIE 2: COBOL Batch  
├── IMPORT-SALES-EU.cob
├── IMPORT-SALES-AS.cob
└── UPDATE-BALANCE.cob (sous-programme)

PARTIE 3: COBOL Batch
├── EXTRACT-DATA.cob (export depuis DB)
├── GENERATE-INVOICE.cob (principal)
└── DATE-FORMAT.cob (sous-programme)

PARTIE 4: CICS
├── AUTHXX.cob (authentification)
├── PARTSXX.cob (saisie pièces)
├── MSXX.bms (mapset)
└── MAPXX.bms (maps)
```

### Base de données
- **APIX** : Schéma principal (ORDERS, CUSTOMERS, PRODUCTS, etc.)
- **API1** : Schéma des pièces (PARTS, SUPPLIER, PARTSUPP)

### JCL d'exécution
```jcl
//STEP1   EXEC PGM=IMPORT-PRODUCTS
//SYSOUT  DD SYSOUT=*
//INPUT   DD DSN=PROJET.NEWPRODS.DATA,DISP=SHR
//SYSIN   DD *
EU 1.0850
YU 0.1450  
DO 1.0000
/*
```

---

## Tests unitaires recommandés

### Partie 1 - Import produits
- Test conversion devise (EU→DO, YU→DO)
- Test formatage description
- Test validation numéro produit unique

### Partie 2 - Import ventes  
- Test calcul total commande
- Test mise à jour balance client
- Test gestion dates

### Partie 3 - Factures
- Test calculs TVA/Commission
- Test formatage date en lettres
- Test structure facture

### Partie 4 - CICS
- Test authentification 
- Test validation données saisies
- Test prévention doublons

---

## Livrables du projet

1. **Code source** : Tous les programmes COBOL et BMS
2. **JCL** : Scripts d'exécution et de compilation
3. **Documentation** : Guide utilisateur et technique
4. **Tests** : Jeux de données et résultats attendus
5. **Présentation** : PowerPoint pour la soutenance
6. **Dépôt** : Centralisation sur Github
