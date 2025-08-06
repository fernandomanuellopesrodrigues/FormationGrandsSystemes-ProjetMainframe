--==============================================================
-- Table : API7.PARTS
--==============================================================
create table API7.PARTS (
   PNO                  CHAR(2)                not null,
   PNAME                VARCHAR(30)            not null,
   COLOR                VARCHAR(20),
   WEIGHT               DEC(2),
   CITY                 VARCHAR(20),
   constraint PIDPNO primary key (PNO)
);

--==============================================================
-- Index : PARTS_PK
--==============================================================
create unique index PARTSPK on API7.PARTS (
   PNO                  ASC
);


--==============================================================
-- Table : SUPPLIER
--==============================================================
create table API7.SUPPLIER (
   SNO                  CHAR(2)                not null,
   SNAME                VARCHAR(20)            not null,
   CITY                 VARCHAR(20)            not null,
   constraint PIDSNO primary key (SNO)
);

--==============================================================
-- Index : SUPPLIER_PK
--==============================================================
create unique index SUPPPK on API7.SUPPLIER (
   SNO                  ASC
);

--==============================================================
-- Table : PARTSUPP
--==============================================================
create table API7.PARTSUPP (
   PNO                  CHAR(2)                not null,
   SNO                  CHAR(2)                not null,
   QTY                  DEC(2)                 not null,
   constraint PIDPS primary key (PNO, SNO)
);

--==============================================================
-- Index : PARTSUPP_PK
--==============================================================
create unique index PSPK on API7.PARTSUPP (
   PNO                  ASC,
   SNO                  ASC
);

--==============================================================
-- Index : PARTSUPP_FK
--==============================================================
create index PSPFK on API7.PARTSUPP (
   PNO                  ASC
);

--==============================================================
-- Index : PARTSUPP2_FK
--==============================================================
create index PSSFK on API7.PARTSUPP (
   SNO                  ASC
);


-- Insertions dans la table SUPPLIER

-- Requête 1
INSERT INTO API7.SUPPLIER (SNO, SNAME, CITY)
VALUES ('S1', 'Newegg', 'New York');

-- Requête 2
INSERT INTO API7.SUPPLIER (SNO, SNAME, CITY)
VALUES ('S2', 'Micro Center', 'Los Angeles');

-- Requête 3
INSERT INTO API7.SUPPLIER (SNO, SNAME, CITY)
VALUES ('S3', 'Adafruit', 'Chicago');



-- Insertions dans la table PARTS

-- Requête 1
INSERT INTO API7.PARTS (PNO, PNAME, COLOR, WEIGHT, CITY)
VALUES ('P1', 'Case Screws', 'Red', 10, 'New York');

-- Requête 2
INSERT INTO API7.PARTS (PNO, PNAME, COLOR, WEIGHT, CITY)
VALUES ('P2', 'Cable Ties', 'Blue', 20, 'Los Angeles');

-- Requête 3
INSERT INTO API7.PARTS (PNO, PNAME, COLOR, WEIGHT, CITY)
VALUES ('P3', 'Fan Grills', 'Green', 15, 'Chicago');

-- Requête 4
INSERT INTO API7.PARTS (PNO, PNAME, COLOR, WEIGHT, CITY)
VALUES ('P4', 'Dust Filters', 'Yellow', 25, 'Houston');

-- Requête 5
INSERT INTO API7.PARTS (PNO, PNAME, COLOR, WEIGHT, CITY)
VALUES ('P5', 'Cooling Fan', 'Black', 30, 'Miami');

alter table API7.PARTSUPP
   add constraint FPSS foreign key (SNO)
      references API7.SUPPLIER (SNO)
      on delete restrict;

alter table API7.PARTSUPP
   add constraint FPSP foreign key (PNO)
      references API7.PARTS (PNO)
      on delete restrict;


-- Insertions dans la table PARTSUPP

-- Requêtes pour associer les parties (PNO) aux fournisseurs (SNO)

-- Part 1 avec Supplier 1
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P1', 'S1', 10);

-- Part 2 avec Supplier 1
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P2', 'S1', 20);

-- Part 3 avec Supplier 2
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P3', 'S2', 15);

-- Part 4 avec Supplier 2
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P4', 'S2', 25);

-- Part 5 avec Supplier 3
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P5', 'S3', 30);

-- Part 1 avec Supplier 2
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P1', 'S2', 12);

-- Part 2 avec Supplier 3
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P2', 'S3', 18);

-- Part 3 avec Supplier 1
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)      
VALUES ('P3', 'S1', 90);

-- Part 4 avec Supplier 3
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P4', 'S3', 20);

-- Part 5 avec Supplier 1
INSERT INTO API7.PARTSUPP (PNO, SNO, QTY)
VALUES ('P5', 'S1', 20);