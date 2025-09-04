//JIMPV    JOB  NOTIFY=&SYSUID,CLASS=A,MSGCLASS=H,MSGLEVEL=(1,1),
//             TIME=(0,30),REGION=0M,COND=(8,LT)
//JCLLIB   JCLLIB ORDER=SDJ.FORM.PROCLIB
//*------------------------------------------------------------*
//* Parametres symboliques                                     *
//*------------------------------------------------------------*
// SET SYSUID=API9
// SET NOMPGM=IMPVENTS
//*------------------------------------------------------------*
//* PRECOMP/COMP/LINK (PROC COMPDB2)                           *
//*------------------------------------------------------------*
//APPROC   EXEC COMPDB2
//STEPDB2.SYSLIB   DD  DSN=&SYSUID..SOURCE.DCLGEN,DISP=SHR
//                 DD  DSN=&SYSUID..SOURCE.COPY,DISP=SHR
//STEPDB2.SYSIN    DD  DSN=&SYSUID..SOURCE.COBOL(&NOMPGM),DISP=SHR
//STEPDB2.DBRMLIB  DD  DSN=&SYSUID..SOURCE.DBRMLIB(&NOMPGM),DISP=SHR
//STEPLNK.SYSLMOD  DD  DSN=&SYSUID..SOURCE.PGMLIB(&NOMPGM),DISP=SHR
//*------------------------------------------------------------*
//* BIND DB2 PLAN                                              *
//*------------------------------------------------------------*
//BIND     EXEC PGM=IKJEFT01,COND=(4,LT)
//DBRMLIB  DD  DSN=&SYSUID..SOURCE.DBRMLIB,DISP=SHR
//SYSTSPRT DD  SYSOUT=*,OUTLIM=25000
//SYSTSIN  DD  *
  DSN SYSTEM(DSN1)
  BIND PLAN(IMPVENTS)           -
       QUALIFIER(API9)          -
       ACTION(REPLACE)          -
       MEMBER(IMPVENTS)         -
       VALIDATE(BIND)           -
       ISOLATION(CS)            -
       ACQUIRE(USE)             -
       RELEASE(COMMIT)          -
       EXPLAIN(NO)
  END
/*
//*------------------------------------------------------------------*
//* (OPTION) RAZ du rapport précédent                               *
//*------------------------------------------------------------------*
//RAZ      EXEC PGM=IDCAMS,COND=(4,LT)
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
  DELETE API9.PROJET.VENTES.REPORT
  SET MAXCC=0
/*
//*------------------------------------------------------------*
//* EXECUTION                                                  *
//*------------------------------------------------------------*
//STEPRUN  EXEC PGM=IKJEFT01
//STEPLIB  DD  DSN=&SYSUID..SOURCE.PGMLIB,DISP=SHR
//SYSTSPRT DD  SYSOUT=*,OUTLIM=5000
//SYSOUT   DD  SYSOUT=*,OUTLIM=2000
//SYSTSIN  DD  *
  DSN SYSTEM(DSN1)
  RUN PROGRAM(IMPVENTS) PLAN(IMPVENTS)
  END
/*
/*------------------ FICHIERS D'ENTREE VENTES ----------------*/
//FENTSEU DD  DSN=API9.PROJET.VENTESEU.DATA,DISP=SHR
//FENTSAS DD  DSN=API9.PROJET.VENTESAS.DATA,DISP=SHR
/*---------------------- RAPPORT DE SORTIE -------------------*/
//FREPORT   DD  DSN=API9.PROJET.VENTES.REPORT,
//             DISP=(NEW,CATLG,DELETE),
//             UNIT=SYSDA,SPACE=(TRK,(5,5)),
//             DCB=(RECFM=FB,LRECL=132,BLKSIZE=13200)
