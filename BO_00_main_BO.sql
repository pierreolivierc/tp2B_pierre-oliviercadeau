-- DROP
Prompt Suppression des tables;
@BO_02_drop.sql;
Prompt Schémas complétés;

-- TABLES
Prompt Création des tables et création des contraintes;
@BO_03_objects.sql;
Prompt Tables et contraintres complétées;

-- DATA
Prompt Insertions des données;
@BO_04_data.sql;
Prompt Insertions complétées;

@BO_10_gestion_emprunts_pkg.pks;
@BO_10_gestion_emprunts_pkg.pkb;