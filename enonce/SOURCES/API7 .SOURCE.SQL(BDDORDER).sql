DROP TABLE API7.ORDERS;
DROP TABLE API7.CUSTOMERS;
DROP TABLE API7.ITEMS;
DROP TABLE API7.PRODUCTS;
DROP TABLE API7.EMPLOYES;
DROP TABLE API7.DEPTS;

DROP INDEX API7.CUSTOMERS_PK;
DROP INDEX API7.DEPTS_PK;
DROP INDEX API7.EMPLOYEES_PK;
DROP INDEX API7.PRODUCTS_PK;
DROP INDEX API7.ITEMS_PK;
DROP INDEX API7.ORDERS_PK;

DROP INDEX API7.DEPTSPK;
DROP INDEX API7.EMPPK;
DROP INDEX API7.HAVEFK;
DROP INDEX API7.ITOFK;
DROP INDEX API7.ITPFK;
DROP INDEX API7.ORDPK;
DROP INDEX API7.SFK;
DROP INDEX API7.CFK;


--==============================================================
-- Table : API7.CUSTOMERS
--==============================================================
create table API7.CUSTOMERS (
   C_NO                 DEC(4)                 not null,
   COMPANY              VARCHAR(30)            not null,
   ADDRESS              VARCHAR(100),
   CITY                 VARCHAR(20)            not null,
   STATE                CHAR(2)                not null,
   ZIP                  CHAR(5)                not null,
   PHONE                CHAR(10),
   BALANCE              DEC(10, 2),
   constraint PIDCNO primary key (C_NO)
);

--==============================================================
-- Index : API7.CUSTOMERS_PK
--==============================================================
create unique index API7.CUSTOMERS_PK on API7.CUSTOMERS (
   C_NO                 ASC
);

--==============================================================
-- Table : API7.DEPTS
--==============================================================
create table API7.DEPTS (
   DEPT                 DEC(4)                 not null,
   DNAME                VARCHAR(20)            not null,
   constraint PIDDEPT primary key (DEPT)
);

--==============================================================
-- Index : API7.DEPTS_PK
--==============================================================
create unique index API7.DEPTSPK on API7.DEPTS (
   DEPT                 ASC
);

--==============================================================
-- Table : EMPLOYEES
--==============================================================
create table API7.EMPLOYEES (
   E_NO                 DEC(2)                 not null,
   DEPT                 DEC(4)                 not null,
   LNAME                VARCHAR(20)            not null,
   FNAME                VARCHAR(20),
   STREET               VARCHAR(100)           not null,
   CITY                 VARCHAR(20)            not null,
   ST                   CHAR(2)                not null,
   ZIP                  CHAR(5)                not null,
   PAYRATE              DEC(5, 2)              not null,
   COM                  DEC(2, 2),
   constraint PIDEMP primary key (E_NO)
);

--==============================================================
-- Index : API7.EMPLOYEES_PK
--==============================================================
create unique index API7.EMPPK on API7.EMPLOYEES (
   E_NO                 ASC
);

--==============================================================
-- Index : API7.HAVE_FK
--==============================================================
create index API7.HAVEFK on API7.EMPLOYEES (
   DEPT                 ASC
);

--==============================================================
-- Table : API7.PRODUCTS
--==============================================================
create table API7.PRODUCTS (
   P_NO                 CHAR(3)                not null,
   DESCRIPTION          VARCHAR(30)            not null,
   PRICE                DEC(5, 2)              not null,
   constraint PIDPRNO primary key (P_NO)
);

--==============================================================
-- Index : API7.PRODUCTS_PK
--==============================================================
create unique index API7.PRPK on API7.PRODUCTS (
   P_NO                 ASC
);
--==============================================================
-- Table : API7.ITEMS
--==============================================================
create table API7.ITEMS (
   O_NO                 DEC(3)                 not null,
   P_NO                 CHAR(3)                not null,
   QUANTITY             DEC(2)                 not null,
   PRICE                DEC(5, 2)              not null,
   constraint PITEMS primary key (O_NO, P_NO)
);

--==============================================================
-- Index : API7.ITEMS_PK
--==============================================================
create unique index API7.ITEMSPK on API7.ITEMS (
   O_NO                 ASC,
   P_NO                 ASC
);

--==============================================================
-- Index : ITEMS_FK
--==============================================================
create index ITOFK on API7.ITEMS (
   O_NO                 ASC
);

--==============================================================
-- Index : ITEMS2_FK
--==============================================================
create index ITPFK on API7.ITEMS (
   P_NO                 ASC
);

--==============================================================
-- Table : ORDERS
--==============================================================
create table API7.ORDERS (
   O_NO                 DEC(3)                 not null,
   S_NO                 DEC(2)                 not null,
   C_NO                 DEC(4)                 not null,
   O_DATE               DATE                   not null,
   constraint P_IDONO primary key (O_NO)
);

--==============================================================
-- Index : API7.ORDERS_PK
--==============================================================
create unique index API7.ORDPK on API7.ORDERS (
   O_NO                 ASC
);

--==============================================================
-- Index : API7.IS_ASSOCIATED_FK
--==============================================================
create index API7.SFK on API7.ORDERS (
   S_NO                 ASC
);

--==============================================================
-- Index : PASS_FK
--==============================================================
create index API7.CFK on API7.ORDERS (
   C_NO                 ASC
);

alter table API7.EMPLOYEES
   add constraint FDEPT foreign key (DEPT)
      references API7.DEPTS (DEPT)
      on delete restrict;

alter table API7.ITEMS
   add constraint FITO foreign key (O_NO)
      references API7.ORDERS (O_NO)
      on delete restrict;

alter table API7.ITEMS
   add constraint FITP foreign key (P_NO)
      references API7.PRODUCTS (P_NO)
      on delete restrict;

alter table API7.ORDERS
   add constraint FORDS foreign key (S_NO)
      references API7.EMPLOYEES (E_NO)
      on delete restrict;

alter table API7.ORDERS
   add constraint FORDC foreign key (C_NO)
      references API7.CUSTOMERS (C_NO)
      on delete restrict;

-- Insérer des données fictives dans la table CUSTOMERS

INSERT INTO API7.CUSTOMERS
(C_NO, COMPANY, ADDRESS, CITY, STATE, ZIP, PHONE, BALANCE)
VALUES
(1, 'ABC Company', '123 Main Street', 'New York',
   'NY', '10001', '555-1234', 1500.00);

INSERT INTO API7.CUSTOMERS
(C_NO, COMPANY, ADDRESS, CITY, STATE, ZIP, PHONE, BALANCE)
VALUES (2, 'XYZ Corporation', '456 Elm Street',
   'Los Angeles', 'CA', '90001', '555-5678', 2500.50);

INSERT INTO API7.CUSTOMERS
(C_NO, COMPANY, ADDRESS, CITY, STATE, ZIP, PHONE, BALANCE)
VALUES (3, 'LMN Enterprises', '789 Oak Avenue',
   'Chicago', 'IL', '60601', '555-9012', 1800.75);

INSERT INTO API7.CUSTOMERS
(C_NO, COMPANY, ADDRESS, CITY, STATE, ZIP, PHONE, BALANCE)
VALUES (4, 'PQR Industries', '101 Pine Street',
   'Houston', 'TX', '77002', '555-3456', 3200.25);

INSERT INTO API7.CUSTOMERS
(C_NO, COMPANY, ADDRESS, CITY, STATE, ZIP, PHONE, BALANCE)
VALUES (5, 'DEF Corporation', '222 Cedar Avenue',
   'Miami', 'FL', '33101', '555-6789', 2000.00);


-- Insérer des données fictives dans la table DEPTS

INSERT INTO API7.DEPTS (DEPT, DNAME)
VALUES (100, 'Sales');

INSERT INTO API7.DEPTS (DEPT, DNAME)
VALUES (200, 'Marketing');

INSERT INTO API7.DEPTS (DEPT, DNAME)
VALUES (300, 'Engineering');

-- Insérer des données fictives dans la table DEPTS

INSERT INTO API7.EMPLOYEES
(E_NO, DEPT, LNAME, FNAME, STREET, CITY, ST, ZIP, PAYRATE, COM)
VALUES (10, 100, 'Doe', 'John', '123 Main Street',
   'New York', 'NY', '10001', 20.00, 0.05);

INSERT INTO API7.EMPLOYEES
(E_NO, DEPT, LNAME, FNAME, STREET, CITY, ST, ZIP, PAYRATE, COM)
VALUES (20, 200, 'Smith', 'Alice', '456 Elm Street',
 'Los Angeles', 'CA', '90001', 22.50, 0.03);

INSERT INTO API7.EMPLOYEES
(E_NO, DEPT, LNAME, FNAME, STREET, CITY, ST, ZIP, PAYRATE, COM)
VALUES (30, 300, 'Johnson', 'David', '789 Oak Avenue',
 'Chicago', 'IL', '60601', 25.00, 0.02);

INSERT INTO API7.EMPLOYEES
(E_NO, DEPT, LNAME, FNAME, STREET, CITY, ST, ZIP, PAYRATE, COM)
VALUES (40, 100, 'Williams', 'Mary', '101 Pine Street',
   'Houston', 'TX', '77002', 21.75, 0.04);

INSERT INTO API7.EMPLOYEES
(E_NO, DEPT, LNAME, FNAME, STREET, CITY, ST, ZIP, PAYRATE, COM)
VALUES (50, 200, 'Brown', 'Michael', '222 Cedar Avenue',
 'Miami', 'FL', '33101', 24.50, 0.06);

-- Insérer des données fictives dans la table ORDERS

INSERT INTO API7.ORDERS (O_NO, S_NO, C_NO, O_DATE)
VALUES (101, 10, 1, '2022-02-15');

INSERT INTO API7.ORDERS (O_NO, S_NO, C_NO, O_DATE)
VALUES (102, 20, 2, '2018-03-20');

INSERT INTO API7.ORDERS (O_NO, S_NO, C_NO, O_DATE)
VALUES (103, 30, 3, '2020-02-25');

INSERT INTO API7.PRODUCTS (P_NO, DESCRIPTION, PRICE)
VALUES ('P01', 'Mouse Bluetooth', 25.99);

INSERT INTO API7.PRODUCTS (P_NO, DESCRIPTION, PRICE)
VALUES ('P02', 'Battery', 15.49);

INSERT INTO API7.PRODUCTS (P_NO, DESCRIPTION, PRICE)
VALUES ('P03', 'Router', 35.75);

INSERT INTO API7.PRODUCTS (P_NO, DESCRIPTION, PRICE)
VALUES ('P04', 'Keyboard', 10.00);

INSERT INTO API7.PRODUCTS (P_NO, DESCRIPTION, PRICE)
VALUES ('P05', 'External Hard Drive', 50.25);

INSERT INTO API7.PRODUCTS (P_NO, DESCRIPTION, PRICE)
VALUES ('P06', 'Printer XP427', 50.55);

INSERT INTO API7.PRODUCTS (P_NO, DESCRIPTION, PRICE)
VALUES ('P07', 'USB Drive', 10.25);

-- Insérer des données fictives dans la table ITEMS

INSERT INTO API7.ITEMS (O_NO, P_NO, QUANTITY, PRICE)
VALUES (101, 'P01', 10, 25.99);

INSERT INTO API7.ITEMS (O_NO, P_NO, QUANTITY, PRICE)
VALUES (101, 'P03', 15, 35.75);

INSERT INTO API7.ITEMS (O_NO, P_NO, QUANTITY, PRICE)
VALUES (102, 'P03', 10, 35.75);

INSERT INTO API7.ITEMS (O_NO, P_NO, QUANTITY, PRICE)
VALUES (103, 'P05', 10, 50.25);