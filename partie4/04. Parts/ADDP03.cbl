       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADDP03.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       DATA DIVISION.
       WORKING-STORAGE SECTION.  

       01 PARTSX-REC.
          05 P-PART-NO       PIC X(3).
          05 P-PART-NAME     PIC X(20).
          05 P-COLOR         PIC X(10).
          05 P-WEIGHT        PIC 9(3).
          05 P-CITY          PIC X(15).

       77 WS-CD-ERR          PIC 9(2)  VALUE 0.         
      
       COPY DFHAID.  
       COPY MS03.       
       
       LINKAGE SECTION.
       01 ZONE.   
          05 CA-USER-LOGGED  PIC X(1).
          05 CA-LOGIN        PIC X(5).              
          05 CA-LAST-MSG     PIC X(78).    

      ****************************************************************** 
       PROCEDURE DIVISION USING ZONE.
       MAIN.
           IF EIBCALEN = ZERO OR CA-USER-LOGGED NOT = 'Y'
              EXEC CICS XCTL 
				       PROGRAM('AUTH03')
                   COMMAREA(ZONE)
                   LENGTH(LENGTH OF ZONE)
               END-EXEC
           END-IF
      
          
          IF  RESPONSE NOT = DFHRESP(NORMAL)
              PERFORM ERROR-PARA
          END-IF.

           IF EIBAID = DFHNULL
              MOVE 'SAISISSEZ UNE PIECE PUIS ENTER' TO CA-LAST-MSG
              MOVE LOW-VALUES TO MAP03PO 
              PERFORM SEND-FORM              
           END-IF

           PERFORM HANDLE-TOUCHE
           PERFORM SEND-FORM			 
           .
      ******************************************************************
      * AFFICHE L'ECRAN DE AJOUT DES PIECES
      ******************************************************************
       SEND-FORM.
           MOVE CA-LAST-MSG TO I-MSGO
           
               
           EXEC CICS SEND
                MAP('MAP03P')
                MAPSET('MS03')
                FROM (MAP03PO)
                ERASE
                CURSOR
                TERMINAL
                RESP(WS-CD-ERR) 
                FRSET
                FREEKB
                WAIT
           END-EXEC

           IF WS-CD-ERR NOT = DFHRESP(NORMAL)
              MOVE 'ERR SEND' TO CA-LAST-MSG
              PERFORM END-ALL        
           END-IF  
           .
       
       HANDLE-TOUCHE.
           EVALUATE EIBAID
           WHEN DFHENTER
                PERFORM SAVE-PART
           WHEN DFHPF5
                PERFORM FORM-CLEAR
           WHEN DFHPF3
                PERFORM SEND-GOODBYE 
           WHEN DFHCLEAR
                PERFORM FORM-CLEAR
           WHEN OTHER
                MOVE 'TOUCHE NON SUPPORTEE' TO CA-LAST-MSG            
           END-EVALUATE
           .

       SAVE-PART.
           PERFORM RECEIVE-PART

           IF P-PART-NO = SPACES OR P-PART-NAME = SPACES
              MOVE 'NUMERO ET NOM DE LA PIECE SONT OBLIGATOIRES'
                 TO CA-LAST-MSG           
              EXIT PARAGRAPH          
           END-IF

           IF P-WEIGHT NOT NUMERIC
              MOVE 'LE POIDS DOIT ETRE NUMERIQUE' TO CA-LAST-MSG                         
              EXIT PARAGRAPH
           END-IF

           EXEC CICS READ
                FILE('PARTS03')
                INTO (PARTSX-REC)
                RIDFLD(P-PART-NO)
                RESP(WS-CD-ERR) 
           END-EXEC.

           IF WS-CD-ERR = DFHRESP(NORMAL)
              MOVE 'LA PIECE EXISTE DEJA' TO CA-LAST-MSG
              EXIT PARAGRAPH           
           END-IF.
       
           EXEC CICS WRITE 
			       FILE('PARTS03')
                FROM (PARTSX-REC)
                RIDFLD(P-PART-NO)
                RESP(WS-CD-ERR)
           END-EXEC.


           IF WS-CD-ERR = DFHRESP(NORMAL)
              MOVE 'PIECE ENREGISTREE' TO CA-LAST-MSG
              MOVE LOW-VALUES TO MAP03PO
           ELSE
              MOVE 'ERREUR ECRITURE FICHIER VSAM' TO CA-LAST-MSG
           END-IF
           .

      ******************************************************************
      *       on recupere les donnees depuis l'ecran de login
       RECEIVE-PART.
           EXEC CICS RECEIVE 
			       MAP('MAP03P')
                MAPSET('MS03')
                INTO (MAP03PI)
                RESP(WS-CD-ERR)
           END-EXEC

           IF WS-CD-ERR NOT = DFHRESP(NORMAL)
              MOVE 'ERR RECEIVE' TO CA-LAST-MSG
              PERFORM END-ALL              
           END-IF
           
			  MOVE I-PARTNOI TO P-PART-NO         
           MOVE I-NAMEI TO P-PART-NAME
           MOVE I-COLORI TO P-COLOR
           MOVE I-WEIGHTI TO P-WEIGHT
           MOVE I-CITYI TO P-CITY
           .
         
      ******************************************************************
       FORM-CLEAR.
           MOVE LOW-VALUES TO MAP03PO
           MOVE 'FORMULAIRE VIDE' TO CA-LAST-MSG
           .
      ******************************************************************
       SEND-GOODBYE.
           MOVE 'AU REVOIR' TO CA-LAST-MSG
           PERFORM END-ALL          
           .
      ******************************************************************
       END-ALL.
           EXEC CICS SEND 
			       FROM (CA-LAST-MSG)
                LENGTH(LENGTH OF CA-LAST-MSG)
                WAIT
                ERASE
           END-EXEC
           EXEC CICS RETURN 
           END-EXEC
           .      