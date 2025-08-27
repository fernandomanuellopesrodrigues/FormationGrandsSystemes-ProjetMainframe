       IDENTIFICATION DIVISION.
       PROGRAM-ID. IMPVENTS.
       AUTHOR. GROUPE3.

      *****************************************************************
      * PARTIE 2 : Import des ventes (EU + AS)
      * Objectif : ORDERS / ITEMS + MAJ CUSTOMERS.BALANCE PAR COMMANDE
      * Fichiers : PROJET.VENTESEU.DATA, PROJET.VENTESAS.DATA (X(35))
      *****************************************************************

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT VENTESEU-FILE
               ASSIGN TO FNVENTESEU
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FS-VENEU.

           SELECT VENTESAS-FILE
               ASSIGN TO FNVENTESAS
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FS-VENSAS.

           SELECT REPORT-FILE
               ASSIGN TO FREPORT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FS-REPORT.

       DATA DIVISION.
       FILE SECTION.
       FD  VENTESEU-FILE.
       01  VENTESEU-REC              PIC X(35).
       FD  VENTESAS-FILE.
       01  VENTESAS-REC              PIC X(35).
       FD  REPORT-FILE.
       01  REPORT-REC                PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-FS-VENEU               PIC XX VALUE SPACES.
           88 WS-VENEU-OK                  VALUE '00'.
           88 WS-VENEU-EOF                 VALUE '10'.
       01  WS-FS-VENSAS              PIC XX VALUE SPACES.
           88 WS-VENSAS-OK                 VALUE '00'.
           88 WS-VENSAS-EOF                VALUE '10'.
       01  WS-FS-REPORT              PIC XX VALUE SPACES.
           88 WS-REPORT-OK                 VALUE '00'.

       01  WS-SRC                    PIC XX VALUE SPACES.
       01  WS-IN-REC                 PIC X(35) VALUE SPACES.

      * Layout fixe (positions)
       01  SALES-RECORD.
           05 ORDER-NO               PIC 999.
           05 ORDER-DATE             PIC X(10).
           05 EMP-NO                 PIC 99.
           05 CUST-NO                PIC 9999.
           05 PROD-NO                PIC XXX.
           05 PRICE                  PIC 99999.
           05 QUANTITY               PIC 99.
           05 FILLER                 PIC X(6).

       01  WS-DATE-YYYY              PIC X(4).
       01  WS-DATE-MM                PIC X(2).
       01  WS-DATE-DD                PIC X(2).
       01  FORMATTED-DATE            PIC X(10).  *> YYYY-MM-DD

       01  PRICE-FORMATTED           PIC S9(5)V99 COMP-3 VALUE +0.
       01  CAT-PRICE                 PIC S9(5)V99 COMP-3 VALUE +0.
       01  LINE-AMOUNT               PIC S9(7)V99 COMP-3 VALUE +0.

      * Agrégation par commande
       01  CUR-ORDER-NO              PIC 9(3) VALUE 0.
       01  CUR-CUST-NO               PIC 9(4) VALUE 0.
       01  TOTAL-ORDER               PIC S9(9)V99 COMP-3 VALUE +0.
       01  HAS-OPEN-ORDER            PIC X VALUE 'N'.

       01  LINE-OK                   PIC X VALUE 'N'.
       01  ERR-MSG                   PIC X(60) VALUE SPACES.

       01  CNT-READ                  PIC 9(7) VALUE 0.
       01  CNT-OK                    PIC 9(7) VALUE 0.
       01  CNT-ERR                   PIC 9(7) VALUE 0.
       01  CNT-COMMIT                PIC 9(5) VALUE 0.

       01  RPT-HDR                   PIC X(132) VALUE
           'IMPORT VENTES (EU/AS) → ORDERS / ITEMS + BALANCE (PAR COMMANDE)'.
       01  RPT-SEP                   PIC X(132) VALUE ALL '-'.
       01  RPT-OK.
           05 FILLER                 PIC X(4)  VALUE 'SRC:'.
           05 R-SRC                  PIC X(2).
           05 FILLER                 PIC X(5)  VALUE ' O#:'.
           05 R-ONO                  PIC ZZZ.
           05 FILLER                 PIC X(5)  VALUE ' C#:'.
           05 R-CNO                  PIC ZZZZ.
           05 FILLER                 PIC X(5)  VALUE ' S#:'.
           05 R-SNO                  PIC ZZ.
           05 FILLER                 PIC X(6)  VALUE ' PNO:'.
           05 R-PNO                  PIC XXX.
           05 FILLER                 PIC X(7)  VALUE ' QTY='.
           05 R-QTY                  PIC ZZ9.
           05 FILLER                 PIC X(9)  VALUE ' PRICE='.
           05 R-PRC                  PIC Z,ZZ9.99.
           05 FILLER                 PIC X(6)  VALUE '  OK'.
       01  RPT-ERR.
           05 FILLER                 PIC X(4)  VALUE 'SRC:'.
           05 R2-SRC                 PIC X(2).
           05 FILLER                 PIC X(5)  VALUE ' O#:'.
           05 R2-ONO                 PIC ZZZ.
           05 FILLER                 PIC X(2)  VALUE ' '.
           05 R2-MSG                 PIC X(90).
       01  RPT-SUM.
           05 FILLER                 PIC X(13) VALUE 'TOTAL LUS: '.
           05 RS-READ                PIC ZZ,ZZZ,ZZ9.
           05 FILLER                 PIC X(8)  VALUE '  OK: '.
           05 RS-OK                  PIC ZZ,ZZZ,ZZ9.
           05 FILLER                 PIC X(12) VALUE '  ERREURS: '.
           05 RS-ERR                 PIC ZZ,ZZZ,ZZ9.

           EXEC SQL INCLUDE SQLCA END-EXEC.

       01  H-ORD.
           05 H-O-NO                 PIC 9(3).
           05 H-O-DATE               PIC X(10).
           05 H-S-NO                 PIC 9(2).
           05 H-C-NO                 PIC 9(4).
       01  H-ITEM.
           05 H-I-O-NO               PIC 9(3).
           05 H-I-P-NO               PIC XXX.
           05 H-I-QTY                PIC S9(3) COMP-3.
           05 H-I-PRICE              PIC S9(5)V99 COMP-3.
       01  H-CUST.
           05 H-C-NO-K               PIC 9(4).
           05 H-C-DELTA              PIC S9(9)V99 COMP-3.

      *****************************************************************
       PROCEDURE DIVISION.
           PERFORM INIT
           PERFORM PROCESS-EU
           PERFORM FLUSH-OPEN-ORDER
           PERFORM PROCESS-AS
           PERFORM FLUSH-OPEN-ORDER
           PERFORM FINI
           GOBACK.

       INIT.
           OPEN OUTPUT REPORT-FILE
           IF NOT WS-REPORT-OK
              DISPLAY 'ERREUR OUVERTURE RAPPORT ' WS-FS-REPORT
              MOVE 12 TO RETURN-CODE
              GOBACK
           END-IF
           WRITE REPORT-REC FROM RPT-HDR
           WRITE REPORT-REC FROM RPT-SEP
           .

       PROCESS-EU.
           MOVE 'EU' TO WS-SRC
           OPEN INPUT VENTESEU-FILE
           IF NOT WS-VENEU-OK
              DISPLAY 'ERREUR OUVERTURE VENTESEU ' WS-FS-VENEU
              GO TO CLOSE-EU
           END-IF
           PERFORM UNTIL WS-VENEU-EOF
              READ VENTESEU-FILE
                 AT END MOVE '10' TO WS-FS-VENEU
                 NOT AT END
                    MOVE VENTESEU-REC TO WS-IN-REC
                    PERFORM PROCESS-LINE
              END-READ
           END-PERFORM
       CLOSE-EU.
           CLOSE VENTESEU-FILE
           .

       PROCESS-AS.
           MOVE 'AS' TO WS-SRC
           OPEN INPUT VENTESAS-FILE
           IF NOT WS-VENSAS-OK
              DISPLAY 'ERREUR OUVERTURE VENTESAS ' WS-FS-VENSAS
              GO TO CLOSE-AS
           END-IF
           PERFORM UNTIL WS-VENSAS-EOF
              READ VENTESAS-FILE
                 AT END MOVE '10' TO WS-FS-VENSAS
                 NOT AT END
                    MOVE VENTESAS-REC TO WS-IN-REC
                    PERFORM PROCESS-LINE
              END-READ
           END-PERFORM
       CLOSE-AS.
           CLOSE VENTESAS-FILE
           .

       PROCESS-LINE.
           ADD 1 TO CNT-READ
           PERFORM PARSE-LINE
           PERFORM NORMALIZE-LINE
           PERFORM VALIDATE-LINE
           IF LINE-OK NOT = 'Y'
              ADD 1 TO CNT-ERR
              PERFORM LOG-ERR USING ERR-MSG
              EXIT PARAGRAPH
           END-IF

           IF HAS-OPEN-ORDER = 'Y'
              AND ORDER-NO NOT = CUR-ORDER-NO
              PERFORM FLUSH-OPEN-ORDER
           END-IF

           IF HAS-OPEN-ORDER NOT = 'Y'
              MOVE ORDER-NO  TO CUR-ORDER-NO
              MOVE CUST-NO   TO CUR-CUST-NO
              MOVE +0        TO TOTAL-ORDER
              MOVE 'Y'       TO HAS-OPEN-ORDER
           END-IF

           PERFORM UPSERT-ORDERS
           IF SQLCODE NOT = 0
              ADD 1 TO CNT-ERR
              PERFORM LOG-ERR USING 'ERREUR UPSERT ORDERS'
              EXIT PARAGRAPH
           END-IF

           PERFORM UPSERT-ITEMS
           IF SQLCODE NOT = 0
              ADD 1 TO CNT-ERR
              PERFORM LOG-ERR USING 'ERREUR UPSERT ITEMS'
              EXIT PARAGRAPH
           END-IF

           COMPUTE LINE-AMOUNT = QUANTITY * PRICE-FORMATTED
           ADD LINE-AMOUNT TO TOTAL-ORDER

           ADD 1 TO CNT-OK
           PERFORM LOG-OK
           ADD 1 TO CNT-COMMIT
           IF CNT-COMMIT >= 100
              EXEC SQL COMMIT END-EXEC
              MOVE 0 TO CNT-COMMIT
           END-IF
           .

       PARSE-LINE.
           MOVE WS-IN-REC(1:3)    TO ORDER-NO
           MOVE WS-IN-REC(4:10)   TO ORDER-DATE
           MOVE WS-IN-REC(14:2)   TO EMP-NO
           MOVE WS-IN-REC(16:4)   TO CUST-NO
           MOVE WS-IN-REC(20:3)   TO PROD-NO
           MOVE WS-IN-REC(23:5)   TO PRICE
           MOVE WS-IN-REC(28:2)   TO QUANTITY
           .

       NORMALIZE-LINE.
           MOVE ORDER-DATE(7:4) TO WS-DATE-YYYY
           MOVE ORDER-DATE(4:2) TO WS-DATE-MM
           MOVE ORDER-DATE(1:2) TO WS-DATE-DD
           STRING WS-DATE-YYYY '-' WS-DATE-MM '-' WS-DATE-DD
              DELIMITED BY SIZE INTO FORMATTED-DATE
           END-STRING
           IF PRICE = 0
              PERFORM READ-CATALOG-PRICE
              MOVE CAT-PRICE TO PRICE-FORMATTED
           ELSE
              COMPUTE PRICE-FORMATTED = PRICE / 100
           END-IF
           .

       VALIDATE-LINE.
           MOVE 'N' TO LINE-OK
           MOVE SPACES TO ERR-MSG
           IF QUANTITY = 0
              MOVE 'QUANTITY=0' TO ERR-MSG
              EXIT PARAGRAPH
           END-IF
           MOVE CUST-NO TO H-C-NO-K
           EXEC SQL SELECT 1 FROM API9.CUSTOMERS
                      WHERE C_NO = :H-C-NO-K
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 'CLIENT INCONNU' TO ERR-MSG
              EXIT PARAGRAPH
           END-IF
           MOVE EMP-NO TO H-S-NO
           EXEC SQL SELECT 1 FROM API9.EMPLOYEES
                      WHERE E_NO = :H-S-NO
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 'EMPLOYE INCONNU' TO ERR-MSG
              EXIT PARAGRAPH
           END-IF
           EXEC SQL SELECT 1 FROM API9.PRODUCTS
                      WHERE P_NO = :PROD-NO
           END-EXEC
           IF SQLCODE NOT = 0
              MOVE 'PRODUIT INCONNU' TO ERR-MSG
              EXIT PARAGRAPH
           END-IF
           MOVE 'Y' TO LINE-OK
           .

       READ-CATALOG-PRICE.
           MOVE +0 TO CAT-PRICE
           EXEC SQL
              SELECT PRICE INTO :CAT-PRICE
                FROM API9.PRODUCTS
               WHERE P_NO = :PROD-NO
           END-EXEC
           .

       UPSERT-ORDERS.
           MOVE ORDER-NO       TO H-O-NO
           MOVE FORMATTED-DATE TO H-O-DATE
           MOVE EMP-NO         TO H-S-NO
           MOVE CUST-NO        TO H-C-NO
           EXEC SQL
              UPDATE API9.ORDERS
                 SET O_DATE = :H-O-DATE,
                     S_NO   = :H-S-NO,
                     C_NO   = :H-C-NO
               WHERE O_NO   = :H-O-NO
           END-EXEC
           IF SQLCODE = 0 AND SQLERRD(3) = 0
              EXEC SQL
                 INSERT INTO API9.ORDERS (O_NO, S_NO, C_NO, O_DATE)
                 VALUES (:H-O-NO, :H-S-NO, :H-C-NO, :H-O-DATE)
              END-EXEC
           END-IF
           .

       UPSERT-ITEMS.
           MOVE ORDER-NO        TO H-I-O-NO
           MOVE PROD-NO         TO H-I-P-NO
           MOVE QUANTITY        TO H-I-QTY
           MOVE PRICE-FORMATTED TO H-I-PRICE
           EXEC SQL
              UPDATE API9.ITEMS
                 SET QUANTITY = :H-I-QTY,
                     PRICE    = :H-I-PRICE
               WHERE O_NO = :H-I-O-NO
                 AND P_NO = :H-I-P-NO
           END-EXEC
           IF SQLCODE = 0 AND SQLERRD(3) = 0
              EXEC SQL
                 INSERT INTO API9.ITEMS (O_NO, P_NO, QUANTITY, PRICE)
                 VALUES (:H-I-O-NO, :H-I-P-NO, :H-I-QTY, :H-I-PRICE)
              END-EXEC
           END-IF
           .

       FLUSH-OPEN-ORDER.
           IF HAS-OPEN-ORDER = 'Y'
              MOVE CUR-CUST-NO TO H-C-NO-K
              MOVE TOTAL-ORDER TO H-C-DELTA
              EXEC SQL
                 UPDATE API9.CUSTOMERS
                    SET BALANCE = COALESCE(BALANCE,0) + :H-C-DELTA
                  WHERE C_NO = :H-C-NO-K
              END-EXEC
              EXEC SQL COMMIT END-EXEC
              MOVE 'N' TO HAS-OPEN-ORDER
              MOVE 0   TO TOTAL-ORDER
           END-IF
           .

       LOG-OK.
           MOVE WS-SRC            TO R-SRC
           MOVE ORDER-NO          TO R-ONO
           MOVE CUST-NO           TO R-CNO
           MOVE EMP-NO            TO R-SNO
           MOVE PROD-NO           TO R-PNO
           MOVE QUANTITY          TO R-QTY
           MOVE PRICE-FORMATTED   TO R-PRC
           WRITE REPORT-REC FROM RPT-OK
           .

       LOG-ERR USING P-MSG.
           MOVE WS-SRC    TO R2-SRC
           MOVE ORDER-NO  TO R2-ONO
           MOVE P-MSG     TO R2-MSG
           WRITE REPORT-REC FROM RPT-ERR
           .

       FINI.
           EXEC SQL COMMIT END-EXEC
           WRITE REPORT-REC FROM RPT-SEP
           MOVE CNT-READ TO RS-READ
           MOVE CNT-OK   TO RS-OK
           MOVE CNT-ERR  TO RS-ERR
           WRITE REPORT-REC FROM RPT-SUM
           CLOSE REPORT-FILE
           DISPLAY 'FIN IMPVENTS  LUS:' CNT-READ
                   '  OK:' CNT-OK '  ERR:' CNT-ERR
           .
