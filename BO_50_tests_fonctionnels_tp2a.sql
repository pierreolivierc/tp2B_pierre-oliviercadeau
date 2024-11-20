set serveroutput on;


/************************************* Fait par ÉTUDIANT 1, à tester par ÉTUDIANT 2 *******************************************/
-- A. TEST FONCTIONNEL POUR est_penalites_impayees_fct
DECLARE
    ID_MEMBRE NUMBER;
    a_retard BOOLEAN;
BEGIN
    -- LIVRES TOUS RETOURNÉS, SANS AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRES TOUS RETOURNÉS, SANS AMENDE À PAYER');
    ID_MEMBRE := 7; 
    a_retard := BO.BO_10_gestion_emprunts_pkg.est_penalites_impayees_fct(ID_MEMBRE);
    
    IF a_retard = TRUE THEN
        DBMS_OUTPUT.PUT_LINE('Le membre a au moins un retard.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Le membre n''a aucun retard.');
    END IF;
    
    -- LIVRES TOUS RETOURNÉS, MAIS AVEC AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRES TOUS RETOURNÉS, MAIS AVEC AMENDE À PAYER');
    ID_MEMBRE := 3; 
    a_retard := BO.BO_10_gestion_emprunts_pkg.est_penalites_impayees_fct(ID_MEMBRE);
    
    IF a_retard = TRUE THEN
        DBMS_OUTPUT.PUT_LINE('Le membre a au moins un retard.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Le membre n''a aucun retard.');
    END IF;

 

    -- LIVRE PAS TOUS RETOURNÉS, AVEC AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : LIVRE PAS TOUS RETOURNÉS, AVEC AMENDE À PAYER');
    ID_MEMBRE := 1;
    a_retard := BO.BO_10_gestion_emprunts_pkg.est_penalites_impayees_fct(ID_MEMBRE);
    IF a_retard = TRUE THEN
        DBMS_OUTPUT.PUT_LINE('Le membre a au moins un retard.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Le membre n''a aucun retard.');
    END IF;

 

    -- LIVRE PAS TOUS RETOURNÉS, MAIS SANS AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 4 : LIVRE PAS TOUS RETOURNÉS, MAIS SANS AMENDE À PAYER');
    ID_MEMBRE := 2;
    a_retard := BO.BO_10_gestion_emprunts_pkg.est_penalites_impayees_fct(ID_MEMBRE);
    IF a_retard = TRUE THEN
        DBMS_OUTPUT.PUT_LINE('Le membre a au moins un retard.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Le membre n''a aucun retard.');
    END IF;
END;
/

--B. TEST FONCTIONNEL POUR emprunter_livre_prc
DECLARE
    ID_MEMBRE NUMBER;
    ID_LIVRE  NUMBER;
    VERIF     VARCHAR2(1000); -- Pratique pour afficher les dates lors de transactions (longue concaténation des données de dates)
BEGIN
 
    -- EMPRUNT IMPOSSIBLE, CAR AMENDES
    DBMS_OUTPUT.PUT_LINE ('*** CAS DE TEST no. 1 : EMPRUNT IMPOSSIBLE, CAR AMENDES');
    ID_MEMBRE := 1;
    ID_LIVRE := 1;
    BO.BO_10_gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);

    ROLLBACK; -- Pour annuler les modifications de la transaction (retrouver les données d'origine)
 
    -- LIVRE INEXISTANT
    DBMS_OUTPUT.PUT_LINE ('*** CAS DE TEST no. 2 : LIVRE INEXISTANT');
    ID_MEMBRE := 3;
    ID_LIVRE := 555;
    BO.BO_10_gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);

    ROLLBACK;
 
    -- LIVRE EXISTANT, MAIS DÉJÀ EMPRUNTÉ
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : LIVRE EXISTANT, MAIS DÉJÀ EMPRUNTÉ');
    ID_MEMBRE := 3;
    ID_LIVRE := 18;
    BO.BO_10_gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);

    ROLLBACK;
 
    -- CAS DE TEST no. 4 : ON PEUT EMPRUNTER LE LIVRE
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 4 : ON PEUT EMPRUNTER LE LIVRE');
    ID_MEMBRE := 3;
    ID_LIVRE := 1;
    BO.BO_10_gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);


    ROLLBACK;
END;
/

--C. TEST FONCTIONNEL POUR est_disponible_fct
DECLARE
    ID_LIVRE     NUMBER;
    RETOUR_PREVU DATE;
    est_disponible BOOLEAN;

BEGIN
 
    -- LIVRE DISPONIBLE POUR EMPRUNT
    ID_LIVRE     :=  3;
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRE DISPONIBLE POUR EMPRUNT');
    est_disponible := BO.BO_10_gestion_emprunts_pkg.est_disponible_fct(ID_LIVRE, RETOUR_PREVU);
    IF est_disponible = TRUE THEN
        DBMS_OUTPUT.PUT_LINE('Le livre est disponible');
    ELSE
        DBMS_OUTPUT.PUT_LINE('La date de retour prévu est le :' || RETOUR_PREVU);
    END IF;
 

    -- LIVRE DÉJÀ EMPRUNTÉ
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRE DÉJÀ EMPRUNTÉ');
    ID_LIVRE     :=  18;
    est_disponible := BO.BO_10_gestion_emprunts_pkg.est_disponible_fct(ID_LIVRE, RETOUR_PREVU);
    IF est_disponible = TRUE THEN
        DBMS_OUTPUT.PUT_LINE('Le livre est disponible');
    ELSE
        DBMS_OUTPUT.PUT_LINE('La date de retour prévu est le : ' || RETOUR_PREVU);
    END IF;
END;
/