# verifier que la table est vide avant execution

SELECT COUNT(*) FROM "API7"."PRODUCTS";

## Vérifions si la table existe

SELECT * FROM SYSIBM.SYSTABLES
WHERE CREATOR = 'API7' AND NAME = 'PRODUCTS';

truncate table API7.PRODUCTS;
