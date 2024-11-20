CREATE OR REPLACE PACKAGE BO_10_gestion_emprunts_pkg
    AUTHID CURRENT_USER IS

    code_erreur NUMBER;
    message_erreur VARCHAR2(50);
    e_livre_indisponible EXCEPTION;
    e_penalites_impayees EXCEPTION;
    
        FUNCTION est_penalites_impayees_fct 
        (i_membre_id IN membres.id%TYPE)
            RETURN BOOLEAN;

        PROCEDURE emprunter_livre_prc  
        (
            i_membre_id IN membres.id%TYPE,
            i_livre_id IN livres.id%TYPE
        );

        FUNCTION est_disponible_fct 
        (i_livre_id IN livres.id%TYPE,
        o_date_retour_prevu OUT EMPRUNTS.DATE_RETOUR_PREVU%type)
            RETURN BOOLEAN;
            
END BO_10_gestion_emprunts_pkg;