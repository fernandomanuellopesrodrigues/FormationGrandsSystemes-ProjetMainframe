       IDENTIFICATION DIVISION.
       PROGRAM-ID. AUTH03.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
           
       DATA DIVISION.
       WORKING-STORAGE SECTION. 
       01 WS-MAPSET-NAME     PIC X(4)   VALUE 'MS03'.
       01 WS-MAP-LOGIN       PIC X(6)   VALUE 'MAP03L'.
       01 WS-PGM-PARTS       PIC X(8)   VALUE 'PARTS03'.
       01 WS-PGM-USERSX      PIC X(24)  VALUE 'USERS03'.
       01 WS-TRANS-NAME      PIC X(5)   VALUE 'T03L'.

       01 USERSX-REC.
          05 U-LOGIN         PIC X(8).
          05 U-PASSWORD      PIC X(8).
          05 U-EMP-NO        PIC 9(5).
          05 U-LNAME         PIC X(20).
          05 U-FNAME         PIC X(20).
      
       77 WS-CD-ERR          PIC 9(2)   VALUE 0.  
      
       COPY DFHBMSCA.
       COPY DFHAID.
       COPY MS03.

       LINKAGE SECTION.
       01 DFHCOMMAREA        PIC X(256).
       01 CA-AREA REDEFINES DFHCOMMAREA.
          05 CA-USER-LOGGED  PIC X(1).
          05 CA-LOGIN        PIC X(8).
          05 CA-EMP-NO       PIC 9(5).        
          05 CA-LAST-MSG     PIC X(78).
          05 FILLER          PIC X(164).

     

      ******************************************************************
      *    SI EIBCALEN = 0 ==> PREMIERE FOIS
      ******************************************************************
       PROCEDURE DIVISION.
       MAIN.
           EVALUATE EIBTRNID
           WHEN WS-TRANS-NAME
                IF EIBCALEN = ZERO                  
                   MOVE SPACES TO CA-LOGIN CA-LAST-MSG
                   PERFORM SEND-LOGIN             
                END-IF  
                PERFORM HANDLE-TOUCHE        
           WHEN OTHER
                CONTINUE
           END-EVALUATE
           PERFORM SEND-LOGIN
           .
      ******************************************************************
      * AFFICHE L'ECRAN DE LOGIN
      ******************************************************************
       SEND-LOGIN.
           MOVE 'N' TO CA-USER-LOGGED
           MOVE CA-LAST-MSG TO L-MSGO
           EXEC CICS
                SEND MAP(WS-MAP-LOGIN)
                MAPSET(WS-MAPSET-NAME)
                RESP(WS-CD-ERR)
                FROM (MAP03LO)
                ERASE
                CURSOR
                WAIT
                END-EXEC
           IF WS-CD-ERR NOT = DFHRESP(NORMAL)
              MOVE 'ERR SEND' TO CA-LAST-MSG
              PERFORM FIN-TOTALE        
           END-IF         
           EXEC CICS
                RETURN
                TRANSID(WS-TRANS-NAME)
                COMMAREA(DFHCOMMAREA)
                LENGTH(LENGTH OF DFHCOMMAREA)
                END-EXEC
           .          
      ******************************************************************
      * EIBAID PERMET DE RECUPERER LA TOUCHE APPUYEE
      ******************************************************************
       HANDLE-TOUCHE.
           EVALUATE EIBAID
           WHEN DFHENTER               
                PERFORM VALIDATE-CREDENTIALS
           WHEN DFHPF3
                PERFORM SEND-GOODBYE              
           WHEN DFHCLEAR
                MOVE SPACES TO L-LOGINO L-PASSWDO
                MOVE SPACES TO CA-LAST-MSG                            
           WHEN OTHER
                MOVE 'TOUCHE INVALIDE !' TO CA-LAST-MSG              
           END-EVALUATE
           .

       VALIDATE-CREDENTIALS.
           PERFORM RECEIVE-LOGIN
           MOVE L-LOGINI TO U-LOGIN
           MOVE L-PASSWDI TO U-PASSWORD

           IF U-LOGIN = SPACES OR U-PASSWORD = SPACES
              MOVE 'LOGIN ET MOT DE PASSE REQUIS' TO CA-LAST-MSG               
           ELSE
      ******************************************************************
      * cherche sur le fichier des utilisateurs par login        
              EXEC CICS
                   READ FILE(WS-PGM-USERSX)
                   INTO (USERSX-REC)
                   RIDFLD(U-LOGIN)
                   RESP(WS-CD-ERR)        
                   END-EXEC        
        
              IF WS-CD-ERR NOT = DFHRESP(NORMAL)        
                 MOVE 'UTILISATEUR INCONNU' TO CA-LAST-MSG        
              ELSE         
                 IF U-PASSWORD NOT = L-PASSWDI        
                    MOVE 'MOT DE PASSE INVALIDE' TO CA-LAST-MSG
                 END-IF         
              END-IF        
        
              PERFORM AUTH-OK        
           END-IF
           .
     
      ******************************************************************
      *       on recupere les donnees depuis l'ecran de login
       RECEIVE-LOGIN.
           EXEC CICS
                RECEIVE MAP(WS-MAP-LOGIN)
                MAPSET(WS-MAPSET-NAME)
                INTO (MAP03LI)
                RESP(WS-CD-ERR)
                END-EXEC
           IF WS-CD-ERR NOT = DFHRESP(NORMAL)
              MOVE 'ERR RECEIVE' TO CA-LAST-MSG
              PERFORM FIN-TOTALE              
           END-IF
           .
      ******************************************************************
      *       authentification est ok on passe la main a
      *       l'ecran de saisie
       AUTH-OK.
           MOVE 'Y' TO CA-USER-LOGGED
           MOVE U-LOGIN TO CA-LOGIN
           MOVE U-EMP-NO TO CA-EMP-NO
           MOVE SPACES TO CA-LAST-MSG
           EXEC CICS XCTL PROGRAM(WS-PGM-PARTS)
                COMMAREA(DFHCOMMAREA)
                LENGTH(LENGTH OF DFHCOMMAREA)
                END-EXEC          
           .

      ******************************************************************
       SEND-GOODBYE.
           MOVE 'Au revoir' TO CA-LAST-MSG
           PERFORM FIN-TOTALE          
           .
           
      ******************************************************************
       FIN-TOTALE.
           EXEC CICS
                SEND FROM (CA-LAST-MSG)
                LENGTH(LENGTH OF CA-LAST-MSG)
                WAIT
                ERASE
                END-EXEC
           EXEC CICS
                RETURN 
                END-EXEC
           .