
       IDENTIFICATION DIVISION.
       PROGRAM-ID. IMPPRODS.
       AUTHOR. GROUPE3.
      *****************************************************************
      * PROGRAMME : IMPORT DES NOUVEAUX PRODUITS                      *
      * OBJECTIF  : LIRE LE FICHIER PROJET.NEWPRODS.DATA ET           *
      *             INSERER LES DONNEES EN BASE APIX.PRODUCTS         *
      * ENTREE    : FICHIER CSV AVEC SEPARATEUR ;                     *
      * SORTIE    : INSERTION EN BASE DB2                             *
      *****************************************************************

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT NEWPRODS-FILE
               ASSIGN TO NEWPRODS
               ORGANIZATION IS SEQUENTIAL.
               ACCES MODE IS SEQUENTIAL.
               FILE STATUS IS WS-NP-STATUS.

           SELECT REPORT-FILE
               ASSIGN TO REPORT
               ORGANIZATION IS SEQUENTIAL.
               ACCES MODE IS SEQUENTIAL.
               FILE STATUS IS WS-RP-STATUS.

       DATA DIVISION.
       
       WORKING-STORAGE SECTION.

       
