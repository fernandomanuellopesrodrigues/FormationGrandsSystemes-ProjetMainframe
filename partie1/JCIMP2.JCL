//JCIMP2    JOB NOTIFY=&SYSUID,CLASS=A,MSGCLASS=H,
//       TIME=(0,30),MSGLEVEL=(1,1)
//***********************************************************
//*  ====> JCL D'APPEL DE LA PROCEDURE COMPDB2  BATCH       *
//*                                                         *
//*  ====> COMPIL COBOL/DB2 + BIND   (BATCH)                *
//*        =======================   *******                *
//*        REMPLACER API? PAR VOTRE USER TSO                *
//*           ? : Nì DU GROUPE,  $ : N¢ DU PROGRAMME        *
//*                  API?DB$ PAR LE NOM DU PROGRAMME        *
//*                                                         *
//***********************************************************
//PROCLIB  JCLLIB ORDER=SDJ.FORM.PROCLIB
//*
//         SET SYSUID=API7,
//             NOMPGM=IMPPRODS
//*
//APPROC   EXEC COMPDB2
//STEPDB2.SYSLIB   DD DSN=&SYSUID..SOURCE.DCLGEN,DISP=SHR
//                 DD DSN=&SYSUID..SOURCE.COPY,DISP=SHR
//STEPDB2.SYSIN    DD DSN=&SYSUID..SOURCE.COBOL(&NOMPGM),DISP=SHR
//STEPDB2.DBRMLIB  DD DSN=&SYSUID..SOURCE.DBRMLIB(&NOMPGM),DISP=SHR
//STEPLNK.SYSLMOD  DD DSN=&SYSUID..SOURCE.PGMLIB(&NOMPGM),DISP=SHR
//*TEPCOB.SYSLIB   DD DSN=&SYSUID..DB2FILES.COPY,DISP=SHR
//*
//*--- ETAPE DE BIND --------------------------------------
//*
//BIND     EXEC PGM=IKJEFT01,COND=(4,LT)
//DBRMLIB  DD  DSN=&SYSUID..SOURCE.DBRMLIB,DISP=SHR
//SYSTSPRT DD  SYSOUT=*,OUTLIM=25000
//SYSTSIN  DD  *
  DSN SYSTEM (DSN1)
  BIND PLAN      (IMPPRODS) -
       QUALIFIER (API7)     -
       ACTION    (REPLACE)  -
       MEMBER    (IMPPRODS) -
       VALIDATE  (BIND)     -
       ISOLATION (CS)       -
       ACQUIRE   (USE)      -
       RELEASE   (COMMIT)   -
       EXPLAIN   (NO)
/*
//**************************************************************
//*                EXECUTION                                   *
//**************************************************************
//STEPRUN  EXEC PGM=IKJEFT01,COND=(4,LT)
//STEPLIB  DD DSN=&SYSUID..SOURCE.PGMLIB,DISP=SHR
//SYSTSPRT DD  SYSOUT=*,OUTLIM=2500
//SYSOUT   DD  SYSOUT=*,OUTLIM=1000
//SYSTSIN  DD  *
  DSN SYSTEM (DSN1)
  RUN PROGRAM(IMPPRODS) PLAN(IMPPRODS)
/*
//FNPRODS  DD DSN=API7.PROJET.NEWPRODS.DATA,DISP=SHR
//FREPORT  DD DSN=API7.PROJET.NEWPRODS.REPORT,
//            DISP=(NEW,CATLG,DELETE),
//            UNIT=SYSDA,SPACE=(TRK,(5,5)),
//            DCB=(RECFM=FB,LRECL=132,BLKSIZE=13200)
