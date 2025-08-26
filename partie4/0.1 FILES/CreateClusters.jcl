//USERS03  JOB (ACCT#),'FERNAND',MSGLEVEL=(1,1),COND=(4,LT),
//             CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//CREATE   EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
  DELETE API7.PROJET.PARTS03.KSDS PURGE
  DELETE API7.PROJET.USERS03.KSDS PURGE 
  DEFINE CLUSTER(NAME(API7.PROJET.PARTS03.KSDS) -
                VOLUMES(APIWK2)                  -
                TRACKS(3 2)                      -
                FREESPACE(20 20)                 -
                KEYS(3 0)                        -
                RECORDSIZE(70 70)                -
                INDEXED)                         -
         DATA(NAME(API7.PROJET.PARTS03.KSDS.D)) -
         INDEX(NAME(API7.PROJET.PARTS03.KSDS.I))  
  DEFINE CLUSTER(NAME(API7.PROJET.USERS03.KSDS)  -
                VOLUMES(APIWK2)                  -
                TRACKS(3 2)                      -
                FREESPACE(20 20)                 -
                KEYS(5 0)                        -
                RECORDSIZE(70 70)                -
                INDEXED)                         -            
         DATA(NAME(API7.PROJET.USERS03.KSDS.D)) -
         INDEX(NAME(API7.PROJET.USERS03.KSDS.I))
/* 
//***********************************************************
//ALIMUSR  EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//DDIN     DD DSN=API7.AJC.EMPLOYE.DATA,DISP=SHR
//DDOUT    DD DSN=API7.PROJET.USERS03.KSDS,DISP=SHR
//SYSIN    DD *
 REPRO INFILE(DDIN)          -
       OUTFILE(DDOUT)
/*  
