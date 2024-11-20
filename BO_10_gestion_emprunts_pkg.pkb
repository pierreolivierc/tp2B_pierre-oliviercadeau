CREATE OR REPLACE PACKAGE BODY BO_10_gestion_emprunts_pkg IS
    
    -- Fonction A. est_penalites_impayees_fct - étudiant 1

    ---------------------------------------------------------------------------------------------
    -- Fonction : est_penalites_impayees_fct
    --
    -- BUT : Vérifie si le membre a des pénalités
    --
    -- PARAMÈTRES :
    --  i_membre_id (membres.id%TYPE) :     id d'un membre
    --
    -- RETOUR (boolean) :
    --  TRUE, si il a une pénalité.
    --  FALSE, s'il n'y a pas de pénalité 
    --
    -- EXCEPTIONS :
    --  e_penalites_impayees :     Levée si paramètre date_retour est en retard
    FUNCTION est_penalites_impayees_fct 
    (i_membre_id IN membres.id%TYPE)
        RETURN boolean
    IS
    nombre_jours_retards NUMBER;
    BEGIN
        SELECT COUNT(*) INTO nombre_jours_retards
        FROM EMPRUNTS e
        WHERE e.MEMBRES_ID = i_membre_id
        AND (e.DATE_RETOUR - e.DATE_RETOUR_PREVU) > 0
        OR((e.DATE_RETOUR_PREVU is null)
        AND (e.DATE_RETOUR < SYSDATE));

        IF nombre_jours_retards > 0  THEN
            RAISE e_penalites_impayees;
        END IF;

        RETURN false;
        
    EXCEPTION
        WHEN e_penalites_impayees THEN
            dbms_output.put_line('Nous ne gèrerons pas le paiement des pénalités');
            RETURN true;
        WHEN OTHERS THEN
            code_erreur := sqlcode;
            message_erreur := sqlerrm;
            dbms_output.put_line( code_erreur || ' - ' || message_erreur);
    END est_penalites_impayees_fct;
    

    -- Procédure B. emprunter_livre_prc - étudiant 1

    ---------------------------------------------------------------------------------------------
    -- Fonction : emprunter_livre_prc 
    --
    -- BUT : Retourner un livre pour permettre à un client de l'emprunter, s'il respecte les critères requis.
    --
    -- PARAMÈTRES :
    -- i_membre_id (membres.id%TYPE) :     id d'un membre
    -- i_livre_id(livres.id%TYPE) :         id d'un livre
    PROCEDURE emprunter_livre_prc  
    (
        i_membre_id IN membres.id%TYPE,
        i_livre_id IN livres.id%TYPE
    )
    IS
        o_date_retour_prevu  EMPRUNTS.DATE_RETOUR_PREVU%type;
    BEGIN
        IF est_penalites_impayees_fct(i_membre_id) THEN
            DBMS_OUTPUT.PUT_LINE('Vous devez payer vos pénalités avant d''emprunter un livre');
        ELSE
            -- IF rechercher_livre_fct(i_livre_id) is not null THEN
                IF est_disponible_fct(i_livre_id, o_date_retour_prevu) THEN
                    INSERT INTO emprunts 
                    (LIVRES_ID, MEMBRES_ID, date_emprunt, DATE_RETOUR) 
                    VALUES (i_livre_id, i_membre_id, SYSDATE, NULL);
                    DBMS_OUTPUT.PUT_LINE('Livre emprunté avec succès.');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('Le livre est déjà emprunté et indisponible.');
                END IF;
            -- ELSE
            --     DBMS_OUTPUT.PUT_LINE('Le livre demandé n''existe pas.');
            -- END IF;
        END IF; 
    EXCEPTION
        WHEN OTHERS THEN
            code_erreur := SQLCODE;
            message_erreur := SQLERRM;
            DBMS_OUTPUT.PUT_LINE(code_erreur || ' - ' || message_erreur);
    END emprunter_livre_prc;
    

    -- Fonction C. est_disponible_fct - étudiant 1

    ---------------------------------------------------------------------------------------------
    -- Fonction : est_disponible_fct
    --
    -- BUT : Vérifie si un livre est disponible à l’emprunt en date d’aujourd’hui
    --
    -- PARAMÈTRES :
    -- i_livre_id(livres.id%TYPE) :         id d'un livre
    -- o_date_retour(EMPRUNTS.DATE_RETOUR%type) :    date de retour prévu
    --
    -- RETOUR (boolean) :
    --  TRUE, si le livre est disponible.
    --  FALSE, si e_livre_indisponible retourne 
    --
    -- EXCEPTIONS :
    --  e_livre_indisponible :     Levée si paramètre o_date_retour_prevu dépace date d'aujourd'hui
    FUNCTION est_disponible_fct 
    (i_livre_id IN livres.id%TYPE,
    o_date_retour_prevu OUT EMPRUNTS.DATE_RETOUR_PREVU%type)
        RETURN boolean
    IS
    date_retour_prevu EMPRUNTS.DATE_RETOUR%type;
    BEGIN
        SELECT DATE_RETOUR_PREVU INTO date_retour_prevu
        FROM EMPRUNTS e
        WHERE e.LIVRES_ID = i_livre_id;

        IF date_retour_prevu > SYSDATE THEN
            RAISE e_livre_indisponible;
        ELSE
            RETURN TRUE;
        END IF;
        
    EXCEPTION
        WHEN e_livre_indisponible THEN
            dbms_output.put_line('Livre indisponible');
            o_date_retour_prevu := date_retour_prevu;
            RETURN FALSE;
        WHEN no_data_found THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            code_erreur := sqlcode;
            message_erreur := sqlerrm;
            dbms_output.put_line( code_erreur || ' - ' || message_erreur);
    END est_disponible_fct;
    
END BO_10_gestion_emprunts_pkg;