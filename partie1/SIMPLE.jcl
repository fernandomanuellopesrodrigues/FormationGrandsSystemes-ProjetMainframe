//SIMPLE   JOB (ACCT#),'SIMPLE COMPILE',CLASS=H,
//             MSGLEVEL=(1,1),NOTIFY=API7
//*
//*****************************************************************
//* JOB : COMPILATION SIMPLE SANS DB2                            *
//*****************************************************************
//*
//STEP1    EXEC PGM=IGYCRCTL,PARM='OBJECT,NODECK,NOTEST'
//STEPLIB  DD DSN=IGY.V6R3M0.SIGYCOMP,DISP=SHR
//SYSLIB   DD DSN=SYS1.COBCOPY,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSIN    DD *
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.
       PROCEDURE DIVISION.
           DISPLAY 'HELLO WORLD'.
           STOP RUN.
/*
//SYSLIN   DD SYSOUT=*
