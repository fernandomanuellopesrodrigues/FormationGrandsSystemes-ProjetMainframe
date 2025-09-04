       IDENTIFICATION DIVISION.
       PROGRAM-ID. IMPVENTS.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT VENTESEU-FILE ASSIGN TO FVENTSEU
              ORGANIZATION IS SEQUENTIAL
              ACCESS MODE IS SEQUENTIAL
              FILE STATUS IS WS-FS-EU.
           SELECT VENTESAS-FILE ASSIGN TO FVENTSAS
              ORGANIZATION IS SEQUENTIAL
              ACCESS MODE IS SEQUENTIAL
              FILE STATUS IS WS-FS-AS.

       DATA DIVISION.
       FILE SECTION.
       FD  VENTESEU-FILE
           RECORD CONTAINS 35 CHARACTERS
           RECORDING MODE IS F.
       01  EU-REC.
           05 EU-O-NO      PIC 9(3).
           05 EU-O-DATE    PIC X(10).
           05 EU-S-NO      PIC 9(2).
           05 EU-C-NO      PIC 9(4).
           05 EU-P-NO      PIC X(3).
           05 EU-PRICES    PIC 9(5).
           05 EU-QUANTITY  PIC 9(2).
           05 EU-RES       PIC X(6).

       FD  VENTESAS-FILE
           RECORD CONTAINS 35 CHARACTERS
           RECORDING MODE IS F.
       01  AS-REC.
           05 AS-O-NO      PIC 9(3).
           05 AS-O-DATE    PIC X(10).
           05 AS-S-NO      PIC 9(2).
           05 AS-C-NO      PIC 9(4).
           05 AS-P-NO      PIC X(3).
           05 AS-PRICES    PIC 9(5).
           05 AS-QUANTITY  PIC 9(2).
           05 AS-RES       PIC X(6).

       WORKING-STORAGE SECTION.
       01  WS-FS-EU                   PIC XX VALUE SPACES.
           88 WS-EU-OK                         VALUE '00'.
           88 WS-EU-EOF                        VALUE '10'.
       01  WS-FS-AS                   PIC XX VALUE SPACES.
           88 WS-AS-OK                         VALUE '00'.
           88 WS-AS-EOF                        VALUE '10'.

           EXEC SQL INCLUDE SQLCA   END-EXEC.
           EXEC SQL INCLUDE ORDERS  END-EXEC.
           EXEC SQL INCLUDE ITEMS   END-EXEC.
           EXEC SQL INCLUDE CUSTOMS END-EXEC.

       01  W-DATE-IN                  PIC X(10).
       01  W-JJ                       PIC X(2).
       01  W-MM                       PIC X(2).
       01  W-AAAA                     PIC X(4).

           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  H-LINE-AMT                 PIC S9(7)V99 COMP-3 VALUE 0.
           EXEC SQL END DECLARE SECTION END-EXEC.

       PROCEDURE DIVISION.
       MAIN-SECTION.
           PERFORM OPEN-FILES
           PERFORM PROCESS-EU
           PERFORM PROCESS-AS
           PERFORM FINISH
           GOBACK.

       OPEN-FILES.
           OPEN INPUT VENTESEU-FILE
           IF NOT WS-EU-OK
              DISPLAY 'OPEN FVENTSEU STATUS=' WS-FS-EU
              GOBACK
           END-IF
           OPEN INPUT VENTESAS-FILE
           IF NOT WS-AS-OK
              DISPLAY 'OPEN FVENTSAS STATUS=' WS-FS-AS
              GOBACK
           END-IF.

       PROCESS-EU.
           PERFORM UNTIL WS-EU-EOF
              READ VENTESEU-FILE
                 AT END
                    MOVE '10' TO WS-FS-EU
                 NOT AT END
                    MOVE EU-O-DATE TO W-DATE-IN
                    PERFORM MAKE-DATE-ISO
                    PERFORM VALIDATE-EU
                    PERFORM MAP-EU
                    PERFORM CALC-LINE-AMT
                    PERFORM DO-DB2
              END-READ
           END-PERFORM.

       PROCESS-AS.
           PERFORM UNTIL WS-AS-EOF
              READ VENTESAS-FILE
                 AT END
                    MOVE '10' TO WS-FS-AS
                 NOT AT END
                    MOVE AS-O-DATE TO W-DATE-IN
                    PERFORM MAKE-DATE-ISO
                    PERFORM VALIDATE-AS
                    PERFORM MAP-AS
                    PERFORM CALC-LINE-AMT
                    PERFORM DO-DB2
              END-READ
           END-PERFORM.

       VALIDATE-EU.
           INSPECT EU-PRICES   REPLACING ALL ' ' BY '0'
           INSPECT EU-QUANTITY REPLACING ALL ' ' BY '0'
           IF EU-O-NO     IS NOT NUMERIC MOVE 0 TO EU-O-NO     END-IF
           IF EU-S-NO     IS NOT NUMERIC MOVE 0 TO EU-S-NO     END-IF
           IF EU-C-NO     IS NOT NUMERIC MOVE 0 TO EU-C-NO     END-IF
           IF EU-QUANTITY IS NOT NUMERIC MOVE 0 TO EU-QUANTITY END-IF
           IF EU-PRICES   IS NOT NUMERIC MOVE 0 TO EU-PRICES   END-IF.

       VALIDATE-AS.
           INSPECT AS-PRICES   REPLACING ALL ' ' BY '0'
           INSPECT AS-QUANTITY REPLACING ALL ' ' BY '0'
           IF AS-O-NO     IS NOT NUMERIC MOVE 0 TO AS-O-NO     END-IF
           IF AS-S-NO     IS NOT NUMERIC MOVE 0 TO AS-S-NO     END-IF
           IF AS-C-NO     IS NOT NUMERIC MOVE 0 TO AS-C-NO     END-IF
           IF AS-QUANTITY IS NOT NUMERIC MOVE 0 TO AS-QUANTITY END-IF
           IF AS-PRICES   IS NOT NUMERIC MOVE 0 TO AS-PRICES   END-IF.

       MAP-EU.
           MOVE EU-O-NO   TO ORD-O-NO
           MOVE EU-S-NO   TO ORD-S-NO
           MOVE EU-C-NO   TO ORD-C-NO
           MOVE W-DATE-IN TO ORD-O-DATE
           MOVE ORD-O-NO     TO ITM-O-NO
           MOVE EU-P-NO      TO ITM-P-NO
           MOVE EU-QUANTITY  TO ITM-QUANTITY
           COMPUTE ITM-PRICE = EU-PRICES / 100.

       MAP-AS.
           MOVE AS-O-NO   TO ORD-O-NO
           MOVE AS-S-NO   TO ORD-S-NO
           MOVE AS-C-NO   TO ORD-C-NO
           MOVE W-DATE-IN TO ORD-O-DATE
           MOVE ORD-O-NO     TO ITM-O-NO
           MOVE AS-P-NO      TO ITM-P-NO
           MOVE AS-QUANTITY  TO ITM-QUANTITY
           COMPUTE ITM-PRICE = AS-PRICES / 100.

       CALC-LINE-AMT.
           IF ITM-QUANTITY IS NOT NUMERIC
              MOVE 0 TO ITM-QUANTITY
           END-IF
           COMPUTE H-LINE-AMT = ITM-PRICE * ITM-QUANTITY.

       MAKE-DATE-ISO.
           MOVE W-DATE-IN(1:2)  TO W-JJ
           MOVE W-DATE-IN(4:2)  TO W-MM
           MOVE W-DATE-IN(7:4)  TO W-AAAA
           MOVE W-AAAA          TO W-DATE-IN(1:4)
           MOVE '-'             TO W-DATE-IN(5:1)
           MOVE W-MM            TO W-DATE-IN(6:2)
           MOVE '-'             TO W-DATE-IN(8:1)
           MOVE W-JJ            TO W-DATE-IN(9:2).

       DO-DB2.
           EXEC SQL
              INSERT INTO API9.ORDERS
                     (O_NO, S_NO, C_NO, O_DATE)
              VALUES(:ORD-O-NO,
                      :ORD-S-NO,
                      :ORD-C-NO,
                      DATE(:ORD-O-DATE))
           END-EXEC
           IF SQLCODE NOT = 0 AND SQLCODE NOT = -803
              DISPLAY 'ERR ORDERS SQL=' SQLCODE
              EXEC SQL ROLLBACK END-EXEC
              GOBACK
           END-IF
           EXEC SQL
              INSERT INTO API9.ITEMS
                     (O_NO, P_NO, QUANTITY, PRICE)
              VALUES(:ITM-O-NO,
                      :ITM-P-NO,
                      :ITM-QUANTITY,
                      :ITM-PRICE)
           END-EXEC
           IF SQLCODE NOT = 0 AND SQLCODE NOT = -803
              DISPLAY 'ERR ITEMS SQL=' SQLCODE
              EXEC SQL ROLLBACK END-EXEC
              GOBACK
           END-IF
           EXEC SQL
              UPDATE API9.CUSTOMERS
                 SET BALANCE = BALANCE + :H-LINE-AMT
               WHERE C_NO = :ORD-C-NO
           END-EXEC
           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
              DISPLAY 'ERR CUSTOMERS SQL=' SQLCODE
              EXEC SQL ROLLBACK END-EXEC
              GOBACK
           END-IF.

       FINISH.
           EXEC SQL COMMIT END-EXEC
           CLOSE VENTESEU-FILE VENTESAS-FILE.
