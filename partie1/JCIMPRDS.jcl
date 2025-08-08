//API7IMP  JOB (ACCT#),'COMPDB2',MSGCLASS=H,REGION=4M,
//    CLASS=A,MSGLEVEL=(1,1),NOTIFY=&SYSUID,
//    COND=(4,LT)
//*
//*------------------------------------------------------*
//* ===> CHANGER API7 PAR N° DU GROUPE                  *
//*      CHANGER IMPPRODS PAR LE NOM DU PROGRAMME       *
//*------------------------------------------------------*
//*
//*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*
//*   CETTE PROCEDURE CONTIENT 5 STEPS :                             *
//*       ======> SI RE-EXECUTION FAIRE RESTART AU "STEPRUN"         *
//*                                                                  *
//*         1/  PRECOMPILE  DB2                                      *
//*         2/  COMPILE COBOL II                                     *
//*         3/  LINKEDIT  (DANS API7.COB.LOAD)                       *
//*         4/  BIND PLAN PARTIR DE API7.COB.DBRM                    *
//*         5/  EXECUTE DU PROGRAMME                                 *
//*  LES   PROCEDURES  SE TROUVENT DANS SDJ.FORM.PROCLIB             *
//*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*
//PROCLIB  JCLLIB ORDER=SDJ.FORM.PROCLIB
//*
//         SET SYSUID=API7,
//             NOMPGM=IMPPRODS
//*
//APPROC   EXEC COMPDB2
//STEPDB2.SYSLIB   DD DSN=&SYSUID..COB.CPY,DISP=SHR
//STEPDB2.SYSIN    DD DSN=&SYSUID..COB.SRC(&NOMPGM),DISP=SHR
//STEPDB2.DBRMLIB  DD DSN=&SYSUID..COB.DBRM(&NOMPGM),DISP=SHR
//STEPCOB.SYSLIB   DD DSN=&SYSUID..COB.CPY,DISP=SHR
//                 DD DSN=&SYSUID..COB.CPY,DISP=SHR
//STEPLNK.SYSLMOD  DD DSN=&SYSUID..COB.LOAD(&NOMPGM),DISP=SHR
//*
//*--- ETAPE DE BIND --------------------------------------
//*
//BIND     EXEC PGM=IKJEFT01,COND=(4,LT)
//DBRMLIB  DD  DSN=&SYSUID..COB.DBRM,DISP=SHR
//SYSTSPRT DD  SYSOUT=*,OUTLIM=25000
//SYSTSIN  DD  *
  DSN SYSTEM (DSN1)
  BIND PLAN      (IMPPRODS) -
       QUALIFIER (API7)     -
       ACTION    (REPLACE) -
       MEMBER    (IMPPRODS) -
       VALIDATE  (BIND)    -
       ISOLATION (CS)      -
       ACQUIRE   (USE)     -
       RELEASE   (COMMIT)  -
       EXPLAIN   (NO)
/*
//STEPRUN  EXEC PGM=IKJEFT01,COND=(4,LT)
//STEPLIB  DD  DSN=&SYSUID..COB.LOAD,DISP=SHR
//SYSOUT   DD  SYSOUT=*,OUTLIM=1000
//SYSTSPRT DD  SYSOUT=*,OUTLIM=2500
//SYSTSIN  DD  *
  DSN SYSTEM (DSN1)
  RUN PROGRAM(IMPPRODS) PLAN (IMPPRODS)
/*
//*
//* FICHIERS POUR L'EXECUTION DU PROGRAMME
//NEWPRODS DD DSN=PROJET.NEWPRODS.DATA,DISP=SHR
//REPORTS  DD DSN=API7.IMPPRODS.REPORT,
//            DISP=(NEW,CATLG,DELETE),
//            UNIT=SYSDA,SPACE=(TRK,(5,5)),
//            DCB=(RECFM=FB,LRECL=132,BLKSIZE=13200)
