//TESTLIB  JOB (ACCT#),'TEST LIBRARIES',CLASS=H,
//             MSGLEVEL=(1,1),NOTIFY=API7
//*
//*****************************************************************
//* JOB : TEST DE L'EXISTENCE DES BIBLIOTHEQUES                  *
//*****************************************************************
//*
//STEP1    EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//TEST1    DD DSN=API7.COB.SRC,DISP=SHR
//TEST2    DD DSN=API7.COB.LOAD,DISP=SHR
//TEST3    DD DSN=IGY.V6R3M0.SIGYCOMP,DISP=SHR
//TEST4    DD DSN=SYS1.COBCOPY,DISP=SHR
//TEST5    DD DSN=CEE.SCEELKED,DISP=SHR
