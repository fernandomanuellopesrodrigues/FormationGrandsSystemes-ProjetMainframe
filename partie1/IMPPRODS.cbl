
       IDENTIFICATION DIVISION.
       PROGRAM-ID. IMPPRODS.
       AUTHOR. GROUPE3.
      *****************************************************************
      * PROGRAMME : IMPORT DES NOUVEAUX PRODUITS                      *
      * OBJECTIF  : LIRE LE FICHIER PROJET.NEWPRODS.DATA ET           *
      *             INSERER LES DONNEES EN BASE API7.PRODUCTS         *
      * ENTREE    : FICHIER CSV AVEC SEPARATEUR ;                     *
      * SORTIE    : INSERTION EN BASE DB2                             *
      *****************************************************************

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT NEWPRODS-FILE
               ASSIGN TO NEWPRODS
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-NP-STATUS.

           SELECT REPORT-FILE
               ASSIGN TO REPORTS
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-RP-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  NEWPRODS-FILE.
       01  NEWPRODS-RECORD            
           05 WS-PRODUCT-NO            PIC X(3).
           05 FILLER                   PIC X VALUE ';'.
           05 WS-DESCRIPTION           PIC X(30).
           05 FILLER                   PIC X VALUE ';'.
           05 WS-PRICE                 PIC 9(3)V99.
           05 FILLER                   PIC X VALUE ';'.
           05 WS-CURRENCY              PIC XX.
       
       FD  REPORT-FILE.
       01  REPORT-RECORD               PIC X(132).

       WORKING-STORAGE SECTION.

      * Variables de controle des fichiers
       01  WS-NP-STATUS                PIC XX VALUE SPACES.
           88  WS-NP-OK                VALUE '00'.
           88  WS-NP-EOF               VALUE '10'.

       01  WS-RP-STATUS                PIC XX VALUE SPACES.
           88  WS-RP-OK                VALUE '00'.

      * Donnees formatees pour insertion
       01  WS-FORMATTED-DATA.
           05  WS-FORMATTED-DESC       PIC X(30).
           05  WS-CONVERTED-PRICE      PIC 9(3)V99.

      * Taux de conversion des devises
       01  WS-CONVERSION-RATES.
           05  WS-EU-RATE              PIC 9V9999 VALUE 1.0850.
           05  WS-YU-RATE              PIC 9V9999 VALUE 0.1450.
           05  WS-DO-RATE              PIC 9V9999 VALUE 1.0000.

      * Variables de travail
       01  WS-WORK-FIELDS.
           05  WS-PRICE-NUMERIC        PIC 9(3)V99.
           05  WS-CONVERSION-RATE      PIC 9V9999.
           05  WS-TEMP-PRICE           PIC 9(5)V9999.  
      * pour le formatage de la description        
           05  WS-CHAR-POS             PIC 9(2).
           05  WS-CURRENT-CHAR         PIC X.       
           05  WS-NEW-WORD-FLAG        PIC X VALUE 'Y'.

      * Compteurs et statistiques
       01  WS-COUNTERS.
           05  WS-RECORDS-READ         PIC 9(5) VALUE ZERO.
           05  WS-RECORDS-INSERTED     PIC 9(5) VALUE ZERO.
           05  WS-RECORDS-ERROR        PIC 9(5) VALUE ZERO.

      * Messages de rapport
       01  WS-REPORT-LINES.
           05  WS-HEADER-LINE          PIC X(132) VALUE
               'RAPPORT D''IMPORT DES PRODUITS'.
           05  WS-SEPARATOR-LINE       PIC X(132) VALUE ALL '-'.
           05  WS-DETAIL-LINE.
               10  FILLER              PIC X(10) VALUE 'PRODUIT: '.
               10  WS-RPT-PRODUCT      PIC X(3).
               10  FILLER              PIC X(5) VALUE ' - '.
               10  WS-RPT-DESC         PIC X(30).
               10  FILLER              PIC X(5) VALUE ' - '.
               10  WS-RPT-PRICE        PIC ZZ9.99.
               10  FILLER              PIC X(5) VALUE ' USD'.
           05  WS-SUMMARY-LINE.
               10  FILLER          PIC X(20) VALUE 'TOTAL TRAITES: '.
               10  WS-RPT-TOTAL        PIC ZZ,ZZ9.
               10  FILLER              PIC X(20) VALUE ' - INSERES: '.
               10  WS-RPT-INSERTED     PIC ZZ,ZZ9.
               10  FILLER              PIC X(20) VALUE ' - ERREURS: '.
               10  WS-RPT-ERRORS       PIC ZZ,ZZ9.

      * Variables DB2
           EXEC SQL INCLUDE SQLCA END-EXEC.

       01  WS-SQL-FIELDS.
           05  WS-SQL-PRODUCT-NO       PIC X(3).
           05  WS-SQL-DESCRIPTION      PIC X(30).
           05  WS-SQL-PRICE            PIC 9(3)V99.

       PROCEDURE DIVISION.

      *****************************************************************
      * PROGRAMME PRINCIPAL                                           *
      *****************************************************************
           PERFORM INITIALIZATION
           PERFORM PROCESS-FILE
           PERFORM FINALIZATION
           STOP RUN.

      *****************************************************************
      * INITIALISATION                                               *
      *****************************************************************
       INITIALIZATION.
           DISPLAY 'DEBUT DU PROGRAMME IMPPRODS'

      * Ouverture des fichiers
           OPEN INPUT NEWPRODS-FILE
           IF NOT WS-NP-OK
               DISPLAY 'ERREUR OUVERTURE FICHIER NEWPRODS: '
                       WS-NP-STATUS
               STOP RUN
           END-IF

           OPEN OUTPUT REPORT-FILE
           IF NOT WS-RP-OK
               DISPLAY 'ERREUR OUVERTURE FICHIER RAPPORT: ' 
                       WS-RP-STATUS
               STOP RUN
           END-IF

      * Ecriture de l'en-tete du rapport
           WRITE REPORT-RECORD FROM WS-HEADER-LINE
           WRITE REPORT-RECORD FROM WS-SEPARATOR-LINE

      * Initialisation des compteurs
           MOVE ZERO TO WS-RECORDS-READ
           MOVE ZERO TO WS-RECORDS-INSERTED
           MOVE ZERO TO WS-RECORDS-ERROR.

      *****************************************************************
      * TRAITEMENT DU FICHIER                                        *
      *****************************************************************
       PROCESS-FILE.
           PERFORM READ-NEXT-RECORD
           PERFORM UNTIL WS-NP-EOF
               PERFORM PROCESS-RECORD
               PERFORM READ-NEXT-RECORD
           END-PERFORM.

      *****************************************************************
      * LECTURE D'UN ENREGISTREMENT                                  *
      *****************************************************************
       READ-NEXT-RECORD.
           READ NEWPRODS-FILE INTO WS-INPUT-LINE
           IF WS-NP-OK
               ADD 1 TO WS-RECORDS-READ
           END-IF.

      *****************************************************************
      * TRAITEMENT D'UN ENREGISTREMENT                               *
      *****************************************************************
       PROCESS-RECORD.
           IF WS-PRODUCT-NO NOT = SPACES
               PERFORM FORMAT-DESCRIPTION
               PERFORM CONVERT-CURRENCY
               PERFORM INSERT-PRODUCT
           ELSE
               DISPLAY 'LIGNE IGNOREE (VIDE)'
               ADD 1 TO WS-RECORDS-ERROR
           END-IF.

      *****************************************************************
      * FORMATAGE DE LA DESCRIPTION                                  *
      *****************************************************************
       FORMAT-DESCRIPTION.
           MOVE SPACES TO WS-FORMATTED-DESC
           MOVE 1 TO WS-CHAR-POS
           MOVE 'Y' TO WS-NEW-WORD-FLAG

           PERFORM VARYING WS-CHAR-POS FROM 1 BY 1
               UNTIL WS-CHAR-POS > 30
               OR WS-DESCRIPTION-RAW(WS-CHAR-POS:1) = SPACE

               MOVE WS-DESCRIPTION-RAW(WS-CHAR-POS:1) 
                       TO WS-CURRENT-CHAR

               IF WS-CURRENT-CHAR = SPACE
                   MOVE WS-CURRENT-CHAR TO 
                       WS-FORMATTED-DESC(WS-CHAR-POS:1)
                   MOVE 'Y' TO WS-NEW-WORD-FLAG
               ELSE
                   IF WS-NEW-WORD-FLAG = 'Y'
                       PERFORM CONVERT-TO-UPPER
                       MOVE 'N' TO WS-NEW-WORD-FLAG
                   ELSE
                       PERFORM CONVERT-TO-LOWER
                   END-IF
                   MOVE WS-CURRENT-CHAR TO 
                       WS-FORMATTED-DESC(WS-CHAR-POS:1)
               END-IF
           END-PERFORM.

      *****************************************************************
      * CONVERSION EN MAJUSCULE                                      *
      *****************************************************************
       CONVERT-TO-UPPER.
           IF WS-CURRENT-CHAR >= 'a' AND WS-CURRENT-CHAR <= 'z'
               COMPUTE WS-CURRENT-CHAR =
                   FUNCTION CHAR(FUNCTION ORD(WS-CURRENT-CHAR) - 32)
           END-IF.

      *****************************************************************
      * CONVERSION EN MINUSCULE                                      *
      *****************************************************************
       CONVERT-TO-LOWER.
           IF WS-CURRENT-CHAR >= 'A' AND WS-CURRENT-CHAR <= 'Z'
               COMPUTE WS-CURRENT-CHAR =
                   FUNCTION CHAR(FUNCTION ORD(WS-CURRENT-CHAR) + 32)
           END-IF.

      *****************************************************************
      * CONVERSION DE DEVISE                                         *
      *****************************************************************
       CONVERT-CURRENCY.
           MOVE FUNCTION NUMVAL(WS-PRICE-RAW) TO WS-PRICE-NUMERIC

           EVALUATE WS-CURRENCY
               WHEN 'EU'
                   MOVE WS-EU-RATE TO WS-CONVERSION-RATE
               WHEN 'YU'
                   MOVE WS-YU-RATE TO WS-CONVERSION-RATE
               WHEN 'DO'
                   MOVE WS-DO-RATE TO WS-CONVERSION-RATE
               WHEN OTHER
                   DISPLAY 'DEVISE INCONNUE: ' WS-CURRENCY
                   MOVE WS-DO-RATE TO WS-CONVERSION-RATE
           END-EVALUATE

           COMPUTE WS-TEMP-PRICE = WS-PRICE-NUMERIC * WS-CONVERSION-RATE
           MOVE WS-TEMP-PRICE TO WS-CONVERTED-PRICE.

      *****************************************************************
      * INSERTION EN BASE DE DONNEES                                 *
      *****************************************************************
       INSERT-PRODUCT.
           MOVE WS-PRODUCT-NO TO WS-SQL-PRODUCT-NO
           MOVE WS-FORMATTED-DESC TO WS-SQL-DESCRIPTION
           MOVE WS-CONVERTED-PRICE TO WS-SQL-PRICE

           EXEC SQL
               INSERT INTO API7.PRODUCTS (P_NO, DESCRIPTION, PRICE)
               VALUES (:WS-SQL-PRODUCT-NO, :WS-SQL-DESCRIPTION,
                           :WS-SQL-PRICE)
           END-EXEC

           IF SQLCODE = 0
               ADD 1 TO WS-RECORDS-INSERTED
               PERFORM WRITE-DETAIL-LINE
               DISPLAY 'PRODUIT INSERE: ' WS-PRODUCT-NO
           ELSE
               ADD 1 TO WS-RECORDS-ERROR
               DISPLAY 'ERREUR INSERTION PRODUIT: ' WS-PRODUCT-NO
               DISPLAY 'SQLCODE: ' SQLCODE
               EXEC SQL ROLLBACK END-EXEC
           END-IF.

      *****************************************************************
      * ECRITURE LIGNE DE DETAIL                                     *
      *****************************************************************
       WRITE-DETAIL-LINE.
           MOVE WS-PRODUCT-NO TO WS-RPT-PRODUCT
           MOVE WS-FORMATTED-DESC TO WS-RPT-DESC
           MOVE WS-CONVERTED-PRICE TO WS-RPT-PRICE
           WRITE REPORT-RECORD FROM WS-DETAIL-LINE.

      *****************************************************************
      * FINALISATION                                                 *
      *****************************************************************
       FINALIZATION.
           PERFORM WRITE-SUMMARY
           PERFORM CLOSE-FILES
           DISPLAY 'FIN DU PROGRAMME IMPPRODS'
           DISPLAY 'TOTAL ENREGISTREMENTS LUS: ' WS-RECORDS-READ
           DISPLAY 'TOTAL PRODUITS INSERES: ' WS-RECORDS-INSERTED
           DISPLAY 'TOTAL ERREURS: ' WS-RECORDS-ERROR.

      *****************************************************************
      * ECRITURE DU RESUME                                           *
      *****************************************************************
       WRITE-SUMMARY.
           WRITE REPORT-RECORD FROM WS-SEPARATOR-LINE
           MOVE WS-RECORDS-READ TO WS-RPT-TOTAL
           MOVE WS-RECORDS-INSERTED TO WS-RPT-INSERTED
           MOVE WS-RECORDS-ERROR TO WS-RPT-ERRORS
           WRITE REPORT-RECORD FROM WS-SUMMARY-LINE.

      *****************************************************************
      * FERMETURE DES FICHIERS                                       *
      *****************************************************************
       CLOSE-FILES.
           CLOSE NEWPRODS-FILE
           CLOSE REPORT-FILE.
           