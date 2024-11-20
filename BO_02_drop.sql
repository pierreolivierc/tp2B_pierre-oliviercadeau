--------------------------------------------------------
--  DESCTRUCTION DES OBJETS DE LA BASE DE DONNEES
--------------------------------------------------------
-- Sequence
DROP SEQUENCE BO.code_membre_seq;

-- Index
DROP INDEX membres_nom_complet_i;
DROP INDEX genres_nom_i;
DROP INDEX livres_isbn_i;

-- Tables
DROP TABLE BO.EMPRUNTS;
DROP TABLE BO.LIVRES;
DROP TABLE BO.MEMBRES;
DROP TABLE BO.AUTEURS;
DROP TABLE BO.GENRES;
DROP TABLE BO.SECTIONS;

PROMPT Tables détruites