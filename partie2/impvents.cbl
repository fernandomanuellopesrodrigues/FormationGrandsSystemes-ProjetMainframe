      *****************************************************************
      * PROGRAMME : IMPVENTS  (PARTIE 2 - API9 )
      * OBJET     : VENTES EU/AS -> ORDERS, ITEMS + MAJ CUSTOMS.BALANCE
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. IMPVENTS.
       AUTHOR. GROUPE3.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT VENTESEU-FILE ASSIGN TO FVENTEU
               ORGANIZATION IS SEQUENTIAL.
           SELECT VENTESAS-FILE ASSIGN TO FVENTAS
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  VENTESEU-FILE.                
       01 EU-REC.
          05 EU-O-NO      PIC 9(3).                 
          05 EU-O-DATE    PIC X(10).                 
          05 EU-S-NO      PIC 9(2).                 
          05 EU-C-NO      PIC 9(4).                  
          05 EU-P-NO      PIC X(3).                  
          05 EU-PRICE5    PIC S9(3)V9(2) USAGE COMP-3.                   
          05 EU-QUANTITY  PIC 9(2).                  
          05 EU-RES       PIC X(6).                  

       FD  VENTESAS-FILE.            
       01 AS-REC.
          05 AS-O-NO      PIC 9(3).
          05 AS-O-DATE    PIC X(10).
          05 AS-S-NO      PIC 9(2).
          05 AS-C-NO      PIC 9(4).
          05 AS-P-NO      PIC X(3).
          05 AS-PRICE5    PIC S9(3)V9(2) USAGE COMP-3.  
          05 AS-QUANTITY  PIC 9(2).
          05 AS-RES       PIC X(6).

       WORKING-STORAGE SECTION.
      * DB2
           EXEC SQL INCLUDE SQLCA   END-EXEC.
           EXEC SQL INCLUDE ORDERS  END-EXEC.
           EXEC SQL INCLUDE ITEMS   END-EXEC.
           EXEC SQL INCLUDE CUSTOMS END-EXEC.

      * Flags EOF
       77 WS-EOF-EU       PIC X     VALUE 'N'.
       77 WS-EOF-AS       PIC X     VALUE 'N'.

      * Conversions
       01 W-DATE-IN       PIC X(10).
       01 W-JJ            PIC X(2).
       01 W-MM            PIC X(2).
       01 W-AAAA          PIC X(4).
       01 WS-PRICE5       PIC S9(3)V9(2) USAGE COMP-3.

       PROCEDURE DIVISION.
      *===============================================================
      * MAIN
      *===============================================================
       MAIN-START.
           OPEN INPUT VENTESEU-FILE
                INPUT VENTESAS-FILE

           PERFORM UNTIL WS-EOF-EU = 'Y'
                   READ VENTESEU-FILE
                   AT END
                      MOVE 'Y' TO WS-EOF-EU
                   NOT AT END
                       MOVE EU-O-DATE TO W-DATE-IN
                       PERFORM MAKE-DATE-ISO
                       PERFORM MAP-EU-TO-DCL
                       PERFORM DO-DB2
                   END-READ
           END-PERFORM

           PERFORM UNTIL WS-EOF-AS = 'Y'
                   READ VENTESAS-FILE
                   AT END
                      MOVE 'Y' TO WS-EOF-AS
                   NOT AT END
                       MOVE AS-O-DATE TO W-DATE-IN
                       PERFORM MAKE-DATE-ISO
                       PERFORM MAP-AS-TO-DCL
                       PERFORM DO-DB2
                   END-READ
           END-PERFORM

           EXEC SQL COMMIT END-EXEC
           CLOSE VENTESEU-FILE VENTESAS-FILE
           GOBACK.

      *===============================================================
      * MAPPINGS -> DCLGEN
      *===============================================================
       MAP-EU-TO-DCL.
      * ORDERS (host vars DCLGEN)
           MOVE EU-O-NO TO ORD-O-NO
           MOVE EU-S-NO TO ORD-S-NO
           MOVE EU-C-NO TO ORD-C-NO
           MOVE W-DATE-IN TO ORD-O-DATE
      * ITEMS
           MOVE ORD-O-NO TO ITM-O-NO
           MOVE EU-P-NO TO ITM-P-NO
           MOVE EU-QUANTITY TO ITM-QUANTITY
           MOVE EU-PRICE5 TO WS-PRICE5
           .         

       MAP-AS-TO-DCL.
      * ORDERS
           MOVE AS-O-NO TO ORD-O-NO
           MOVE AS-S-NO TO ORD-S-NO
           MOVE AS-C-NO TO ORD-C-NO
           MOVE W-DATE-IN TO ORD-O-DATE
      * ITEMS
           MOVE ORD-O-NO TO ITM-O-NO
           MOVE AS-P-NO TO ITM-P-NO
           MOVE AS-QUANTITY TO ITM-QUANTITY
           MOVE AS-PRICE5 TO WS-PRICE5
           . 

      *===============================================================
      * DATE JJ/MM/AAAA -> YYYY-MM-DD  (dans W-DATE-IN)
      *===============================================================
       MAKE-DATE-ISO.
           MOVE W-DATE-IN(1:2) TO W-JJ
           MOVE W-DATE-IN(4:2) TO W-MM
           MOVE W-DATE-IN(7:4) TO W-AAAA
           MOVE W-AAAA TO W-DATE-IN(1:4)
           MOVE '-' TO W-DATE-IN(5:1)
           MOVE W-MM TO W-DATE-IN(6:2)
           MOVE '-' TO W-DATE-IN(8:1)
           MOVE W-JJ TO W-DATE-IN(9:2).

      *===============================================================
      * SQL (UNIQUEMENT VARIABLES DCLGEN) - SCHEMA API9
      *===============================================================
       DO-DB2.
      * INSERT ORDERS (ignore -803)
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

      * INSERT ITEMS (ignore -803)
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

      * UPDATE CUSTOMS : BALANCE += (PRICE * QUANTITY)
           EXEC SQL
              UPDATE API9.CUSTOMERS
                 SET BALANCE = BALANCE
                             +(:ITM-PRICE
                                * :ITM-QUANTITY)
               WHERE C_NO = :ORD-C-NO
           END-EXEC
           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
              DISPLAY 'ERR CUSTOMS SQL=' SQLCODE
              EXEC SQL ROLLBACK END-EXEC
              GOBACK
           END-IF.