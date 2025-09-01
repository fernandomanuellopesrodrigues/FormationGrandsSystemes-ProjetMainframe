       IDENTIFICATION DIVISION.
       PROGRAM-ID. TSTAUTH3.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.           
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  TEST-CASES.
           05  TEST-CASE-1    PIC X(40) VALUE
               'TEST 1: LOGIN REUSSI'.
           05  TEST-CASE-2    PIC X(40) VALUE
               'TEST 2: MOT DE PASSE INCORRECT'.
           05  TEST-CASE-3    PIC X(40) VALUE
               'TEST 3: UTILISATEUR INCONNU'.
           05  TEST-CASE-4    PIC X(40) VALUE
               'TEST 4: CHAMPS VIDES'.
           05  TEST-CASE-5    PIC X(40) VALUE
               'TEST 5: TOUCHE PF3 - DECONNEXION'.
           
       01  TEST-RESULTS.
           05  PASS-COUNT     PIC 9(3)  VALUE ZERO.
           05  FAIL-COUNT     PIC 9(3)  VALUE ZERO.

       COPY DFHAID.
       COPY MS03.

       01  TEST-ZONE.
           05  TST-USER-LOGGED  PIC X(1)   VALUE 'N'.
           05  TST-LOGIN        PIC X(5)   VALUE SPACES.
           05  TST-LAST-MSG     PIC X(78)  VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN.
           DISPLAY '*** DEBUT DES TESTS AUTHENTIFICATION ***'
           DISPLAY '--------------------------------------'
           
           PERFORM TEST-LOGIN-REUSSI
           PERFORM TEST-MDP-INCORRECT
           PERFORM TEST-UTILISATEUR-INCONNU
           PERFORM TEST-CHAMPS-VIDES
           PERFORM TEST-DECONNEXION
           
           PERFORM DISPLAY-RESULTS
           GOBACK.

       TEST-LOGIN-REUSSI.          
           DISPLAY TEST-CASE-1
           MOVE 'N' TO TST-USER-LOGGED
           MOVE SPACES TO TST-LAST-MSG
      * il faut que ca existe dans le fichier
           MOVE 'USER1' TO L-LOGINI         
           MOVE 'PASSWORD123' TO L-PASSWDI
           
           EXEC CICS LINK
               PROGRAM('AUTH03')
               COMMAREA(TEST-ZONE)
               LENGTH(LENGTH OF TEST-ZONE)
           END-EXEC
           
           IF TST-USER-LOGGED = 'Y' AND 
              TST-LOGIN = 'USER1' AND
              TST-LAST-MSG = 'AUTENTIFICATION OK'
               ADD 1 TO PASS-COUNT
               DISPLAY '  --> PASSED: Authentification reussie'
           ELSE
               ADD 1 TO FAIL-COUNT
               DISPLAY '  --> FAILED: ' TST-LAST-MSG
           END-IF.

       TEST-MDP-INCORRECT.           
           DISPLAY TEST-CASE-2
           MOVE 'N' TO TST-USER-LOGGED
           MOVE SPACES TO TST-LAST-MSG
      * il faut que le login existe dans le fichier
           MOVE 'USER1' TO L-LOGINI
           MOVE 'MAUVAISMDP' TO L-PASSWDI
           
           EXEC CICS LINK
               PROGRAM('AUTH03')
               COMMAREA(TEST-ZONE)
               LENGTH(LENGTH OF TEST-ZONE)
           END-EXEC
           
           IF TST-USER-LOGGED = 'N' AND 
              TST-LAST-MSG = 'MOT DE PASSE INVALIDE'
               ADD 1 TO PASS-COUNT
               DISPLAY '  --> PASSED: Mot de passe incorrect detecte'
           ELSE
               ADD 1 TO FAIL-COUNT
               DISPLAY '  --> FAILED: ' TST-LAST-MSG
           END-IF.

       TEST-UTILISATEUR-INCONNU.
           DISPLAY TEST-CASE-3
           MOVE 'N' TO TST-USER-LOGGED
           MOVE SPACES TO TST-LAST-MSG
      * il faut que le login existe pas dans le fichier
           MOVE 'INVAL' TO L-LOGINI
           MOVE 'PASSWORD' TO L-PASSWDI
           
           EXEC CICS LINK
               PROGRAM('AUTH03')
               COMMAREA(TEST-ZONE)
               LENGTH(LENGTH OF TEST-ZONE)
           END-EXEC
           
           IF TST-USER-LOGGED = 'N' AND 
              TST-LAST-MSG = 'UTILISATEUR INCONNU'
               ADD 1 TO PASS-COUNT
               DISPLAY '  --> PASSED: Utilisateur inconnu détecté'
           ELSE
               ADD 1 TO FAIL-COUNT
               DISPLAY '  --> FAILED: ' TST-LAST-MSG
           END-IF.

       TEST-CHAMPS-VIDES.
           DISPLAY TEST-CASE-4
           MOVE 'N' TO TST-USER-LOGGED
           MOVE SPACES TO TST-LAST-MSG
           MOVE SPACES TO L-LOGINI
           MOVE SPACES TO L-PASSWDI
           
           EXEC CICS LINK
               PROGRAM('AUTH03')
               COMMAREA(TEST-ZONE)
               LENGTH(LENGTH OF TEST-ZONE)
           END-EXEC
           
           IF TST-USER-LOGGED = 'N' AND 
              TST-LAST-MSG = 'LOGIN ET MOT DE PASSE REQUIS'
               ADD 1 TO PASS-COUNT
               DISPLAY '  --> PASSED: Champs vides détectés'
           ELSE
               ADD 1 TO FAIL-COUNT
               DISPLAY '  --> FAILED: ' TST-LAST-MSG
           END-IF.

       TEST-DECONNEXION.
           DISPLAY TEST-CASE-5
           MOVE 'Y' TO TST-USER-LOGGED
           MOVE 'USER1' TO TST-LOGIN
           MOVE SPACES TO TST-LAST-MSG
           MOVE DFHPF3 TO EIBAID
           
           EXEC CICS LINK
               PROGRAM('AUTH03')
               COMMAREA(TEST-ZONE)
               LENGTH(LENGTH OF TEST-ZONE)
           END-EXEC
           
           IF TST-USER-LOGGED = 'N' AND 
              TST-LAST-MSG = 'AU REVOIR'
               ADD 1 TO PASS-COUNT
               DISPLAY '  --> PASSED: Déconnexion réussie'
           ELSE
               ADD 1 TO FAIL-COUNT
               DISPLAY '  --> FAILED: ' TST-LAST-MSG
           END-IF.

       DISPLAY-RESULTS.          
           DISPLAY '*** RESULTATS DES TESTS AUTHENTIFICATION ***'
           DISPLAY '------------------------------------------'
           DISPLAY 'TESTS REUSSIS: ' PASS-COUNT
           DISPLAY 'TESTS ECHOUES: ' FAIL-COUNT
           DISPLAY '------------------------------------------'.