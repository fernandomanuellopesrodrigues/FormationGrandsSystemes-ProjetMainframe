       IDENTIFICATION DIVISION.
       PROGRAM-ID. TSTADDP3.       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.       
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 TEST-RESULTS.
          05 PASS-COUNT      PIC 9     VALUE ZERO.
          05 FAIL-COUNT      PIC 9     VALUE ZERO.      
       
       COPY MS03. 

       LINKAGE SECTION.
       01 ZONE.
          05 CA-USER-LOGGED  PIC X(1).
          05 CA-LOGIN        PIC X(5).
          05 CA-LAST-MSG     PIC X(78).
      ****************************************************************** 
       PROCEDURE DIVISION USING ZONE.
       MAIN.
           PERFORM TEST-VALID-INPUT
           PERFORM TEST-MISSING-NAME
           PERFORM TEST-INVALID-WEIGHT
           PERFORM DISPLAY-RESULTS
           GOBACK
           .          
       
       TEST-VALID-INPUT.
           DISPLAY 'TEST 1: AJOUT PIECE VALIDE'
           MOVE 'P01' TO I-PARTNOI
           MOVE 'PIECE TEST' TO I-NAMEI
           MOVE 'ROUGE' TO I-COLORI
           MOVE '100' TO I-WEIGHTI
           MOVE 'PARIS' TO I-CITYI
           
           EXEC CICS LINK
                PROGRAM('ADDP03')
                COMMAREA(ZONE)
                LENGTH(LENGTH OF ZONE)
                END-EXEC
           
           IF CA-LAST-MSG = 'PIECE ENREGISTREE'
              ADD 1 TO PASS-COUNT
              DISPLAY '  --> PASSED'
           ELSE
              ADD 1 TO FAIL-COUNT
              DISPLAY '  --> FAILED: ' CA-LAST-MSG
           END-IF
           .
       
       TEST-MISSING-NAME.
           DISPLAY 'TEST 2: PIECE SANS NOM'
           MOVE SPACES TO I-NAMEI
           MOVE 'P02' TO I-PARTNOI
           
           EXEC CICS LINK
                PROGRAM('ADDP03')
                COMMAREA(ZONE)
                LENGTH(LENGTH OF ZONE)
                END-EXEC
           
           IF CA-LAST-MSG =
              'NUMERO ET NOM DE LA PIECE SONT OBLIGATOIRES'
              ADD 1 TO PASS-COUNT
              DISPLAY '  --> PASSED'
           ELSE
              ADD 1 TO FAIL-COUNT
              DISPLAY '  --> FAILED: ' CA-LAST-MSG
           END-IF
           .
       
       TEST-INVALID-WEIGHT.
           DISPLAY 'TEST 3: POIDS NON NUMERIQUE'
           MOVE 'P03' TO I-PARTNOI
           MOVE 'PIECE TEST' TO I-NAMEI
           MOVE 'ABC' TO I-WEIGHTI
           MOVE 'PARIS' TO I-CITYI
           
           EXEC CICS LINK
                PROGRAM('ADDP03')
                COMMAREA(ZONE)
                LENGTH(LENGTH OF ZONE)
                END-EXEC
           
           IF CA-LAST-MSG = 'LE POIDS DOIT ETRE NUMERIQUE'
              ADD 1 TO PASS-COUNT
              DISPLAY '  --> PASSED'
           ELSE
              ADD 1 TO FAIL-COUNT
              DISPLAY '  --> FAILED: ' CA-LAST-MSG
           END-IF
           .
       
       DISPLAY-RESULTS.  
           DISPLAY 'TESTS TERMINES'
           DISPLAY '--------------'
           DISPLAY 'TESTS REUSSIS: ' PASS-COUNT
           DISPLAY 'TESTS ECHOUES: ' FAIL-COUNT
           .     