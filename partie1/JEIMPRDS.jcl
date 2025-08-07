//IMPPRODS JOB (ACCT),'IMPORT PRODUITS',CLASS=A,MSGCLASS=X,
//             MSGLEVEL=(1,1),NOTIFY=&SYSUID
//*
//*****************************************************************
//* JOB : IMPORT DES NOUVEAUX PRODUITS                           *
//* PROGRAMME : JEIMPRDS                                         *
//* FICHIER D'ENTREE : PROJET.NEWPRODS.DATA                     *
//* BASE DE DONNEES : API7.PRODUCTS                             *
//*****************************************************************
//*
//STEP1    EXEC PGM=IMPPRODS
//STEPLIB  DD DSN=API7.LOAD,DISP=SHR
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
//* FICHIER D'ENTREE - NOUVEAUX PRODUITS
//NEWPRODS DD DSN=PROJET.NEWPRODS.DATA,DISP=SHR
//*
//* FICHIER DE RAPPORT
//REPORTS  DD DSN=API7.IMPPRODS.REPORT,
//            DISP=(NEW,CATLG,DELETE),
//            UNIT=SYSDA,
//            SPACE=(TRK,(5,5)),
//            DCB=(RECFM=FB,LRECL=132,BLKSIZE=13200)
//*
//* PARAMETRES DB2
//DSNPLAN  DD DSN=API7.DBRMLIB.DATA(IMPPRODS),DISP=SHR
//
