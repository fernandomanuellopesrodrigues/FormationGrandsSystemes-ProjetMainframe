       IDENTIFICATION DIVISION.
       PROGRAM-ID. AUTH03.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.   

       DATA DIVISION.
       WORKING-STORAGE SECTION.
            COPY DFHAID.
            COPY DFHBMSCA.
            COPY MS03.

       01 USERSX-REC.
          05 U-LOGIN         PIC X(5).
          05 U-PASSWORD      PIC X(15).
          05 U-PRENOM        PIC X(15).
          05 U-CP            PIC X(5).
          05 U-VILLE         PIC X(20).
          05 U-SALAIRE       PIC 9(5)V99.
          05 U-FILLER        PIC XXX.
      
       77 WS-CD-ERR          PIC 9(2).   
  
       LINKAGE SECTION.
       01 ZONE.     
          05 CA-USER-LOGGED  PIC X(1).
          05 CA-LOGIN        PIC X(5).       
          05 CA-LAST-MSG     PIC X(78).     

      ******************************************************************
      *    SI EIBCALEN = 0 ==> PREMIERE FOIS
      ******************************************************************
       PROCEDURE DIVISION USING ZONE.
       MAIN.
           EVALUATE EIBTRNID
           WHEN 'T03L'
              IF EIBCALEN = ZERO 
                 MOVE LOW-VALUES TO MAP03LO                 
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
              SEND MAP('MAP03L')
                MAPSET('MS03')
                RESP(WS-CD-ERR)
                FROM (MAP03LO)
                ERASE
                CURSOR
                TERMINAL
                WAIT
           END-EXEC
           IF WS-CD-ERR NOT = DFHRESP(NORMAL)
              MOVE 'ERR SEND' TO CA-LAST-MSG
              PERFORM END-ALL        
           END-IF         
           EXEC CICS
              RETURN
                TRANSID('T03L')
                COMMAREA(ZONE)
                LENGTH(LENGTH OF ZONE)
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
               MOVE LOW-VALUES TO MAP03LO  
               MOVE SPACES TO CA-LAST-MSG                            
           WHEN OTHER
              MOVE 'TOUCHE INVALIDE !' TO CA-LAST-MSG              
           END-EVALUATE
           .

       VALIDATE-CREDENTIALS.
           PERFORM RECEIVE-LOGIN
           IF U-LOGIN = SPACES OR U-PASSWORD = SPACES
              MOVE 'LOGIN ET MOT DE PASSE REQUIS' TO CA-LAST-MSG               
           END-IF      
      * cherche sur le fichier des utilisateurs par login        
           EXEC CICS
                READ FILE('USERS03')
                INTO (USERSX-REC)
                RIDFLD(U-LOGIN)
                RESP(WS-CD-ERR)        
           END-EXEC        
       
           IF WS-CD-ERR NOT = DFHRESP(NORMAL)        
             MOVE 'UTILISATEUR INCONNU' TO CA-LAST-MSG        
           ELSE         
              IF U-PASSWORD NOT = L-PASSWDI        
                 MOVE 'MOT DE PASSE INVALIDE' TO CA-LAST-MSG
              ELSE 
                 MOVE 'AUTENTIFICATION OK' TO CA-LAST-MSG
                 PERFORM AUTH-OK  
              END-IF         
           END-IF           
           .
     
      ******************************************************************
      *       on recupere les donnees depuis l'ecran de login
       RECEIVE-LOGIN.
           EXEC CICS
              RECEIVE MAP('MAP03L')
                   MAPSET('MS03')
                   INTO (MAP03LI)
                   RESP(WS-CD-ERR)
           END-EXEC
           IF WS-CD-ERR NOT = DFHRESP(NORMAL)
              MOVE 'ERR RECEIVE' TO CA-LAST-MSG
              PERFORM END-ALL              
           END-IF
           MOVE L-LOGINI TO U-LOGIN
           MOVE L-PASSWDI TO U-PASSWORD
           .
      ******************************************************************
      *       authentification est ok on passe la main a
      *       l'ecran de saisie
       AUTH-OK.
           MOVE 'Y' TO CA-USER-LOGGED
           MOVE U-LOGIN TO CA-LOGIN       
           MOVE SPACES TO CA-LAST-MSG
           EXEC CICS 
              XCTL PROGRAM('ADDP03')
              COMMAREA(ZONE)
              LENGTH(LENGTH OF ZONE)
           END-EXEC          
           .

      ******************************************************************
       SEND-GOODBYE.
           MOVE 'AU REVOIR' TO CA-LAST-MSG
           PERFORM END-ALL          
           .           
      ******************************************************************
       END-ALL.
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