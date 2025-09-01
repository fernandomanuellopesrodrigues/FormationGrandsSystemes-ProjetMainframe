//RUNONL03 JOB (ACCT),'CICS ONLINE 03',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//********************************************************************
//* This JCL prepares online CICS execution for PART 4
//* 1) Load modules are already copied to YOUR.CICS.LOADLIB (see JCLCOB03)
//* 2) Ask operator or via 3270:
//*    - CEDA INSTALL GROUP(GRP03)
//*    - CEMT SET PROGRAM(AUTH03) NEWCOPY
//*    - CEMT SET PROGRAM(PARTS03) NEWCOPY
//*    - CEMT SET MAPSET(MS03) NEWCOPY
//*    - Run transaction: T03L (login) then XCTL to T03P
//* Note: NEWCOPY is done online, not by this JCL.
//********************************************************************
//* Option: use DFHCSDUP to update CSD definitions (install still via CEDA)
//DFHCSDUP EXEC PGM=DFHCSDUP,REGION=0M,COND=(0,LT)
//STEPLIB  DD  DISP=SHR,DSN=DFH.V5R6M0.SDFHLOAD
//SYSPRINT DD  SYSOUT=*
//DFHCSD   DD  DISP=SHR,DSN=YOUR.CICS.CSD
//SYSIN    DD  *
  DEFINE GROUP(GRP03)
  DEFINE FILE(PARTSX) GROUP(GRP03) DSNAME(PROJET.NEWPARTS.KSDS)  -
         SERVREQ(READ,ADD,UPDATE,BROWSE) KEYLENGTH(3)
  DEFINE FILE(USERSX) GROUP(GRP03) DSNAME(AJC.EMPLOYE.KSDS)       -
         SERVREQ(READ,BROWSE) KEYLENGTH(8)
  DEFINE MAPSET(MS03) GROUP(GRP03)
  DEFINE PROGRAM(AUTH03) GROUP(GRP03) LANGUAGE(COBOL)
  DEFINE PROGRAM(PARTS03) GROUP(GRP03) LANGUAGE(COBOL)
  DEFINE TRANSACTION(T03L) GROUP(GRP03) PROGRAM(AUTH03)
  DEFINE TRANSACTION(T03P) GROUP(GRP03) PROGRAM(PARTS03)
/*
//********************************************************************
//* Operator reminder (to run on 3270 in the CICS region):
//*   CEDA INSTALL GROUP(GRP03)
//*   CEMT SET PROG(AUTH03) NEWCOPY
//*   CEMT SET PROG(PARTS03) NEWCOPY
//*   CEMT SET MAPSET(MS03) NEWCOPY
//*   Type: T03L
//******************************************************************** 