SET SERVEROUTPUT ON;

-- Création des utilisateurs fait par étudiant 1, Pierre-Olivier Cadeau.
DECLARE
    TYPE Utilisateur IS RECORD (
        nom_schema sys.dba_users.username%type,
        nom_schema_pw VARCHAR2(20)
    );
    
    TYPE ListeUtilisateurs IS TABLE OF Utilisateur;
    
    utilisateurs ListeUtilisateurs := ListeUtilisateurs(
        Utilisateur('BO', 'BO'),
        Utilisateur('TP2A_2266001', 'garneau'),
        Utilisateur('TP2A_2263887', 'garneau')
    );

    resultat     INTEGER;
    code_erreur  NUMBER;
    message_erreur VARCHAR2(255 CHAR);

BEGIN
    FOR i IN 1 .. utilisateurs.COUNT LOOP
        BEGIN
            -- Vérifie si le user existe pis le supprime, si ces le cas
            SELECT COUNT(1) INTO resultat
            FROM sys.dba_users
            WHERE username = UPPER(utilisateurs(i).nom_schema);

            IF resultat = 1 THEN
                EXECUTE IMMEDIATE 'DROP USER ' || UPPER(utilisateurs(i).nom_schema) || ' CASCADE';
                dbms_output.put_line('Utilisateur ' || utilisateurs(i).nom_schema || ' supprimé');
            END IF;

            -- Créer l'utilisateur
            EXECUTE IMMEDIATE 'CREATE USER ' 
                              || utilisateurs(i).nom_schema 
                              || ' IDENTIFIED BY ' 
                              || utilisateurs(i).nom_schema_pw;
            EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, DBA TO ' || utilisateurs(i).nom_schema;
            dbms_output.put_line('Utilisateur ' || utilisateurs(i).nom_schema || ' créé avec succès');

        EXCEPTION
            WHEN OTHERS THEN
                CASE
                    WHEN sqlcode = '-1940' THEN
                        dbms_output.put_line('Vous devez vous déconnecter du schéma avant de pouvoir le supprimer. Connectez-vous à SYS et exécutez seulement cette partie');
                    ELSE
                        code_erreur := sqlcode;
                        message_erreur := sqlerrm;
                        dbms_output.put_line('Erreur pour l''utilisateur ' || utilisateurs(i).nom_schema || ': ' || code_erreur || ' - ' || message_erreur);
                END CASE;
        END;
    END LOOP;
END;
/