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
               ASSIGN TO FNPRODS
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-NP-STATUS.
      
           SELECT REPORT-FILE
               ASSIGN TO FREPORT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-RP-STATUS.

           SELECT SYSIN-FILE
               ASSIGN TO SYSIN
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-SI-STATUS.
      
       DATA DIVISION.
       FILE SECTION.
       FD  NEWPRODS-FILE.
       01 NEWPRODS-RECORD         PIC X(45).
      
       FD  REPORT-FILE.
       01 REPORT-RECORD           PIC X(132).

       FD  SYSIN-FILE.
       01 SYSIN-RECORD            PIC X(80).
      
       WORKING-STORAGE SECTION.
      
      * VARIABLES DE CONTROLE DES FICHIERS
       01 WS-NP-STATUS            PIC XX         VALUE SPACES.
          88 WS-NP-OK                            VALUE '00'.
          88 WS-NP-EOF                           VALUE '10'.
      
       01 WS-RP-STATUS            PIC XX         VALUE SPACES.
          88 WS-RP-OK                            VALUE '00'.

       01 WS-SI-STATUS            PIC XX         VALUE SPACES.
          88 WS-SI-OK                            VALUE '00'.
          88 WS-SI-EOF                           VALUE '10'.
      
      *STRUCTURE DES DONNEES PRODUIT
       01 WS-PRODUCT-DATA.
          05 WS-PRODUCT-NO        PIC X(3).
          05 WS-DESCRIPTION       PIC X(30).
          05 WS-PRICE             PIC 9(3)V99.
          05 WS-CURRENCY          PIC XX.
      
      * VARIABLES DE PARSING CSV
       01 WS-PARSING-FIELDS.
          05 WS-INPUT-LINE        PIC X(45)      VALUE SPACES.
          05 WS-FIELD-POINTER     PIC 9(2)       VALUE ZERO.
          05 WS-FIELD-LENGTH      PIC 9(2)       VALUE ZERO.
          05 WS-SEMICOLON-POS     PIC 9(2)       VALUE ZERO.
          05 WS-EXTRACTED-FIELD   PIC X(30)      VALUE SPACES.
      
      * DONNEES FORMATEES POUR INSERTION
       01 WS-FORMATTED-DATA.
          05 WS-FORMATTED-DESC    PIC X(30)      VALUE SPACES.
          05 WS-CONVERTED-PRICE   PIC 9(3)V99    VALUE ZERO.
      
      * TAUX DE CONVERSION DES DEVISES, utilise si rien en sysin
       01 WS-CONVERSION-RATES.
          05 WS-EU-RATE           PIC 9V9999     VALUE 1.0850.
          05 WS-YU-RATE           PIC 9V9999     VALUE 0.1450.
          05 WS-DO-RATE           PIC 9V9999     VALUE 1.0000.

      * TABLE DYNAMIQUE DES TAUX (alimentee depuis SYSIN)
       01 WS-RATE-TABLE.
          05 WS-RATE-ENTRY OCCURS 20 TIMES INDEXED BY RT-IX.
             10 WS-RT-CURR        PIC XX         VALUE SPACES.
             10 WS-RT-RATE        PIC 9V9999     VALUE ZERO.

       01 WS-RATE-COUNT           PIC 9(2)       VALUE ZERO.
       01 WS-RT-IDX               PIC 9(2)       VALUE ZERO.

      * VARIABLES DE PARSING SYSIN
       01 WS-SI-LEFT              PIC XX         VALUE SPACES.
       01 WS-SI-RIGHT             PIC X(20)      VALUE SPACES.
       01 WS-SI-CURR              PIC XX         VALUE SPACES.
       01 WS-SI-RATE-NUM          PIC 9V9999     VALUE ZERO.
      
      * VARIABLES DE TRAVAIL
       01 WS-WORK-FIELDS.
          05 WS-CONVERSION-RATE   PIC 9V9999     VALUE ZERO.
          05 WS-TEMP-PRICE        PIC 9(5)V9999  VALUE ZERO.
      
      * POUR LE FORMATAGE DE LA DESCRIPTION
          05 WS-CHAR-POS          PIC 9(2)       VALUE ZERO.
          05 I                    PIC 9(2)       VALUE ZERO.
      
      * COMPTEURS ET STATISTIQUES
       01 WS-COUNTERS.
          05 WS-RECORDS-READ      PIC 9(5)       VALUE ZERO.
          05 WS-RECORDS-INSERTED  PIC 9(5)       VALUE ZERO.
          05 WS-RECORDS-ERROR     PIC 9(5)       VALUE ZERO.
          05 WS-COMMIT-COUNT      PIC 9(5)       VALUE ZERO.
      
      * MESSAGES DE RAPPORT
       01 WS-REPORT-LINES.
          05 WS-HEADER-LINE       PIC X(132)     VALUE
                'RAPPORT D''IMPORT DES PRODUITS'.
          05 WS-SEPARATOR-LINE    PIC X(132)     VALUE ALL '-'.
          05 WS-DETAIL-LINE.
             10 FILLER            PIC X(10)      VALUE 'PRODUIT: '.
             10 WS-RPT-PRODUCT    PIC X(3).
             10 FILLER            PIC X(5)       VALUE ' - '.
             10 WS-RPT-DESC       PIC X(30).
             10 FILLER            PIC X(5)       VALUE ' - '.
             10 WS-RPT-PRICE      PIC ZZ9.99.
             10 FILLER            PIC X(5)       VALUE ' USD'.
          05 WS-SUMMARY-LINE.
             10 FILLER            PIC X(15)      VALUE 'TOTAL TRAITES: '
           .
             10 WS-RPT-TOTAL      PIC ZZ,ZZ9.
             10 FILLER            PIC X(15)      VALUE ' - INSERES: '.
             10 WS-RPT-INSERTED   PIC ZZ,ZZ9.
             10 FILLER            PIC X(15)      VALUE ' - ERREURS: '.
             10 WS-RPT-ERRORS     PIC ZZ,ZZ9.
          05 WS-TIMESTAMP-LINE    PIC X(132).
      
      * VARIABLES DB2
           EXEC SQL INCLUDE SQLCA END-EXEC.
      * VARIABLES HOTES DB2 (SANS DECLARE SECTION)
       01 H-PRODUCT-NO            PIC X(3).
       01 H-DESCRIPTION           PIC X(30).
       01 H-PRICE                 PIC S9(2)V9(2) USAGE COMP-3
                                                 VALUE +0.
      
       PROCEDURE DIVISION.
      
      *****************************************************************
      * PROGRAMME PRINCIPAL                                           *
      *****************************************************************
           PERFORM INITIALIZATION
           PERFORM PROCESS-FILE
           PERFORM FINALIZATION
           GOBACK.
      
      *****************************************************************
      * INITIALISATION                                               *
      *****************************************************************
       INITIALIZATION.
           DISPLAY 'DEBUT DU PROGRAMME IMPPRODS'
      
      * OUVERTURE DES FICHIERS
           OPEN INPUT NEWPRODS-FILE
           IF NOT WS-NP-OK
              DISPLAY 'ERREUR OUVERTURE FICHIER NEWPRODS: '
                      WS-NP-STATUS
              MOVE 12 TO RETURN-CODE
              PERFORM CLOSE-FILES
              GOBACK
           END-IF
      
           OPEN OUTPUT REPORT-FILE
           IF NOT WS-RP-OK
              DISPLAY 'ERREUR OUVERTURE FICHIER RAPPORT: '
                      WS-RP-STATUS
              MOVE 12 TO RETURN-CODE
              PERFORM CLOSE-FILES
              GOBACK
           END-IF

      * CHARGEMENT DES TAUX DEPUIS SYSIN
           PERFORM LOAD-RATES
      
      * ECRITURE DE L'EN-TETE DU RAPPORT
           WRITE REPORT-RECORD FROM WS-HEADER-LINE
           WRITE REPORT-RECORD FROM WS-SEPARATOR-LINE
      
      * INITIALISATION DES COMPTEURS
           MOVE ZERO TO WS-RECORDS-READ
           MOVE ZERO TO WS-RECORDS-INSERTED
           MOVE ZERO TO WS-RECORDS-ERROR
           MOVE ZERO TO WS-COMMIT-COUNT
           .
      
      *****************************************************************
      * TRAITEMENT DU FICHIER                                        *
      *****************************************************************
       PROCESS-FILE.
           PERFORM READ-NEXT-RECORD
           PERFORM UNTIL WS-NP-EOF
                   PERFORM PROCESS-RECORD
                   PERFORM READ-NEXT-RECORD
           END-PERFORM
           .
      
      *****************************************************************
      * LECTURE D'UN ENREGISTREMENT                                  *
      *****************************************************************
       READ-NEXT-RECORD.
           READ NEWPRODS-FILE
           IF WS-NP-OK
              MOVE NEWPRODS-RECORD TO WS-INPUT-LINE
              DISPLAY 'LIGNE LUE :' WS-INPUT-LINE
              ADD 1 TO WS-RECORDS-READ
           ELSE
              IF WS-NP-EOF
                 DISPLAY 'FIN DE FICHIER NEWPRODS'
              ELSE
                 DISPLAY 'ERREUR LECTURE NEWPRODS, STATUS: '
                         WS-NP-STATUS
                 ADD 1 TO WS-RECORDS-ERROR
              END-IF
           END-IF
           .
      
      *****************************************************************
      * TRAITEMENT D'UN ENREGISTREMENT                               *
      *****************************************************************
       PROCESS-RECORD.
           PERFORM PARSE-CSV-LINE
           IF WS-PRODUCT-NO NOT = SPACES
              PERFORM FORMAT-DESCRIPTION
              PERFORM CONVERT-CURRENCY
              PERFORM INSERT-PRODUCT
           ELSE
              DISPLAY 'LIGNE IGNOREE (VIDE)'
              ADD 1 TO WS-RECORDS-ERROR
           END-IF
           .
      
      *****************************************************************
      * ANALYSE DE LA LIGNE CSV                                      *
      *****************************************************************
       PARSE-CSV-LINE.
           MOVE 1 TO WS-FIELD-POINTER
           MOVE SPACES TO WS-PRODUCT-DATA
      
      * EXTRACTION DU NUMERO DE PRODUIT
           PERFORM EXTRACT-FIELD
           MOVE WS-EXTRACTED-FIELD TO WS-PRODUCT-NO
      
      * EXTRACTION DE LA DESCRIPTION
           PERFORM EXTRACT-FIELD
           MOVE WS-EXTRACTED-FIELD TO WS-DESCRIPTION
      
      * EXTRACTION DU PRIX    
           PERFORM EXTRACT-FIELD
      * remplacer virgule par point
           INSPECT WS-EXTRACTED-FIELD REPLACING ALL ',' BY '.'     
           DISPLAY 'PRICE EXTRACTED:' WS-EXTRACTED-FIELD
           COMPUTE WS-PRICE = FUNCTION NUMVAL(WS-EXTRACTED-FIELD)  
           DISPLAY 'PRICE APRES CONV:' WS-PRICE           
      
      * EXTRACTION DE LA DEVISE
           PERFORM EXTRACT-FIELD
           MOVE WS-EXTRACTED-FIELD TO WS-CURRENCY 
           DISPLAY 'INFOS EXTRAITES :' WS-PRODUCT-DATA           
           .
      
      * TODO A ESSAYER AVEC UN INSPECT
      *****************************************************************
      * EXTRACTION D'UN CHAMP CSV                                    *
      *****************************************************************
       EXTRACT-FIELD.
           MOVE SPACES TO WS-EXTRACTED-FIELD
           MOVE 0 TO WS-FIELD-LENGTH
      
      * RECHERCHE DU PROCHAIN POINT-VIRGULE
           PERFORM VARYING WS-SEMICOLON-POS FROM WS-FIELD-POINTER BY 1
              UNTIL WS-SEMICOLON-POS > 45
              OR WS-INPUT-LINE(WS-SEMICOLON-POS:1) = ';'
           END-PERFORM
      
      * CALCUL DE LA LONGUEUR DU CHAMP
           COMPUTE WS-FIELD-LENGTH = WS-SEMICOLON-POS - WS-FIELD-POINTER
      
      * EXTRACTION DU CHAMP SI LONGUEUR VALIDE
           IF WS-FIELD-LENGTH > 0 AND WS-FIELD-LENGTH <= 30
              MOVE WS-INPUT-LINE(WS-FIELD-POINTER:WS-FIELD-LENGTH)
                 TO WS-EXTRACTED-FIELD
           END-IF
      
      * POSITIONNEMENT POUR LE CHAMP SUIVANT
           COMPUTE WS-FIELD-POINTER = WS-SEMICOLON-POS + 1
           .
      
      *****************************************************************
      * FORMATAGE DE LA DESCRIPTION                                  *
      *****************************************************************
       FORMAT-DESCRIPTION.
           MOVE SPACES TO WS-FORMATTED-DESC
           MOVE 1 TO WS-CHAR-POS
           PERFORM VARYING I FROM 1 BY 1
              UNTIL I > LENGTH OF WS-DESCRIPTION
                   IF I = 1 OR WS-DESCRIPTION(I - 1:1) = ' '
                      MOVE FUNCTION UPPER-CASE(WS-DESCRIPTION(I:1))
                         TO WS-FORMATTED-DESC(WS-CHAR-POS:1)
                   ELSE
                      MOVE FUNCTION LOWER-CASE(WS-DESCRIPTION(I:1))
                         TO WS-FORMATTED-DESC(WS-CHAR-POS:1)
                   END-IF
                   ADD 1 TO WS-CHAR-POS
           END-PERFORM
           .
      
      *****************************************************************
      * CONVERSION DE DEVISE                                         *
      *****************************************************************
       CONVERT-CURRENCY.      
           MOVE WS-DO-RATE TO WS-CONVERSION-RATE
           MOVE 0 TO WS-RT-IDX
           IF WS-RATE-COUNT > 0
              PERFORM VARYING WS-RT-IDX FROM 1 BY 1
                 UNTIL WS-RT-IDX > WS-RATE-COUNT
                 OR WS-RT-CURR(WS-RT-IDX) = WS-CURRENCY                      
              END-PERFORM
              IF WS-RT-IDX <= WS-RATE-COUNT
                 MOVE WS-RT-RATE(WS-RT-IDX) TO WS-CONVERSION-RATE                         
              END-IF
           END-IF           
           DISPLAY 'CONVERSION RATE:' WS-CONVERSION-RATE
           COMPUTE WS-TEMP-PRICE = WS-PRICE * WS-CONVERSION-RATE
           MOVE WS-TEMP-PRICE TO WS-CONVERTED-PRICE
           .
      
      *****************************************************************
      * INSERTION EN BASE DE DONNEES                                 *
      *****************************************************************
       INSERT-PRODUCT.
           MOVE WS-PRODUCT-NO TO H-PRODUCT-NO
           MOVE WS-FORMATTED-DESC TO H-DESCRIPTION
           MOVE WS-CONVERTED-PRICE TO H-PRICE
           DISPLAY 'INSERTION EN BDD D''UN NOUVEAU PRODUIT'
           DISPLAY 'PRODUCT NO  : ' H-PRODUCT-NO
           DISPLAY 'DESCRIPTION : ' H-DESCRIPTION
           DISPLAY 'PRICE       : ' H-PRICE
      
           EXEC SQL
               INSERT INTO API7.PRODUCTS
               (P_NO, DESCRIPTION, PRICE)
               VALUES
               (:H-PRODUCT-NO, :H-DESCRIPTION, :H-PRICE)
           END-EXEC     
           IF SQLCODE = 0
              ADD 1 TO WS-RECORDS-INSERTED
              ADD 1 TO WS-COMMIT-COUNT
              PERFORM WRITE-DETAIL-LINE
              DISPLAY 'PRODUIT INSERE: ' WS-PRODUCT-NO
           ELSE
              ADD 1 TO WS-RECORDS-ERROR
              PERFORM WRITE-DETAIL-LINE
              DISPLAY 'ERREUR INSERTION PRODUIT: ' WS-PRODUCT-NO
              DISPLAY 'SQLCODE: ' SQLCODE            
           END-IF
      
      * COMMIT periodique tous les 100 traitements
           IF WS-COMMIT-COUNT >= 100
               EXEC SQL COMMIT END-EXEC
              MOVE 0 TO WS-COMMIT-COUNT
              DISPLAY 'COMMIT PERIODIQUE EFFECTUE'
           END-IF
           .
      
      *****************************************************************
      * ECRITURE LIGNE DE DETAIL                                     *
      *****************************************************************
       WRITE-DETAIL-LINE.
           MOVE WS-PRODUCT-NO TO WS-RPT-PRODUCT
           MOVE WS-FORMATTED-DESC TO WS-RPT-DESC
           MOVE WS-CONVERTED-PRICE TO WS-RPT-PRICE
           WRITE REPORT-RECORD FROM WS-DETAIL-LINE
           .
      
      *****************************************************************
      * FINALISATION                                                 *
      *****************************************************************
       FINALIZATION.
      * Commit final avant fermeture
           EXEC SQL COMMIT END-EXEC
           PERFORM WRITE-SUMMARY
           PERFORM CLOSE-FILES
           DISPLAY 'FIN DU PROGRAMME IMPPRODS'
           DISPLAY 'TOTAL ENREGISTREMENTS LUS: ' WS-RECORDS-READ
           DISPLAY 'TOTAL PRODUITS INSERES: ' WS-RECORDS-INSERTED
           DISPLAY 'TOTAL ERREURS: ' WS-RECORDS-ERROR
           .

      *****************************************************************
      * ECRITURE DU RESUME                                           *
      *****************************************************************
       WRITE-SUMMARY.
      * Ligne timestamp avec CURRENT-DATE
           PERFORM BUILD-TIMESTAMP-LINE
           WRITE REPORT-RECORD FROM WS-TIMESTAMP-LINE
           WRITE REPORT-RECORD FROM WS-SEPARATOR-LINE
           MOVE WS-RECORDS-READ TO WS-RPT-TOTAL
           MOVE WS-RECORDS-INSERTED TO WS-RPT-INSERTED
           MOVE WS-RECORDS-ERROR TO WS-RPT-ERRORS
           WRITE REPORT-RECORD FROM WS-SUMMARY-LINE
           .
      
      *****************************************************************
      * CONSTRUCTION DE LA LIGNE TIMESTAMP                           *
      *****************************************************************
       BUILD-TIMESTAMP-LINE.
           MOVE SPACES TO WS-TIMESTAMP-LINE
           STRING 'HORODATAGE: '
                  FUNCTION CURRENT-DATE(1:4)
                  '-'
                  FUNCTION CURRENT-DATE(5:2)
                  '-'
                  FUNCTION CURRENT-DATE(7:2)
                  ' '
                  FUNCTION CURRENT-DATE(9:2)
                  ':'
                  FUNCTION CURRENT-DATE(11:2)
                  ':'
                  FUNCTION CURRENT-DATE(13:2)
              DELIMITED BY SIZE
              INTO WS-TIMESTAMP-LINE
           END-STRING
           .
      
      *****************************************************************
      * CHARGEMENT DES TAUX DEPUIS SYSIN                               *
      *****************************************************************
       LOAD-RATES.
      * Tente d'ouvrir SYSIN et de charger des lignes de type CC=9.9999
           OPEN INPUT SYSIN-FILE
           IF WS-SI-OK
              MOVE 0 TO WS-RATE-COUNT
              PERFORM UNTIL WS-SI-EOF
                      PERFORM READ-NEXT-SYSIN
              END-PERFORM
              DISPLAY 'NB TAUX CHARGES: ' WS-RATE-COUNT
           ELSE
               DISPLAY 'SYSIN NON DISPONIBLE OU ERREUR OUVERTURE: '
                       WS-SI-STATUS
           END-IF
           .

       READ-NEXT-SYSIN.
           READ SYSIN-FILE
           AT END
              MOVE '10' TO WS-SI-STATUS
           NOT AT END
               PERFORM PROCESS-SYSIN-LINE
           END-READ
           .

       PROCESS-SYSIN-LINE.
      * Forme attendue: 'EU=1.0850'            
           MOVE SPACES TO WS-SI-LEFT WS-SI-RIGHT        
           UNSTRING SYSIN-RECORD
              DELIMITED BY '='
              INTO WS-SI-LEFT
                   WS-SI-RIGHT
           END-UNSTRING
      *  convertit le taux            
           COMPUTE WS-SI-RATE-NUM = FUNCTION NUMVAL(WS-SI-RIGHT)           
           ADD 1 TO WS-RATE-COUNT
           MOVE WS-SI-LEFT TO WS-RT-CURR(WS-RATE-COUNT)
           MOVE WS-SI-RATE-NUM TO WS-RT-RATE(WS-RATE-COUNT)
           .
      
      *****************************************************************
      * FERMETURE DES FICHIERS                                       *
      *****************************************************************
       CLOSE-FILES.
           CLOSE NEWPRODS-FILE
           CLOSE REPORT-FILE
           .