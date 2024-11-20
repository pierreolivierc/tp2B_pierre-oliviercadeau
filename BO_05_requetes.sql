-- 1.	Combien y a-t-il eu d’emprunts par genre au cours des 3 derniers mois d’emprunts à partir de la plus récente date du jeu de données (vous ne pouvez pas « hard coder » la date)? 
-- Trier de la catégorie la moins populaire à la plus populaire, puis par nom de genre. Vous devrez utiliser la fonction add_months. De plus, ajoutez un alias de colonne pour Nb. Emprunts.
SELECT 
    g.NOM_GENRE AS "Nom du Genre", 
    COUNT(e.ID) AS "Nb. Emprunts"
FROM 
    BO.EMPRUNTS e
INNER JOIN 
    BO.LIVRES l ON e.LIVRES_ID = l.ID
INNER JOIN 
    BO.GENRES g ON l.GENRES_ID = g.ID
WHERE 
    e.DATE_EMPRUNT >= ADD_MONTHS((SELECT MAX(DATE_EMPRUNT) FROM BO.EMPRUNTS), -3)
GROUP BY 
    g.NOM_GENRE
ORDER BY 
    COUNT(e.id) ASC, g.NOM_GENRE ASC;

-- 2.	Afficher la quantité de livres par genre (roman, science-fiction, etc.) ainsi que la part (%) de ce genre sur la quantité totale de livres. Triez en ordre décroissant de part.
SELECT 
    g.NOM_GENRE AS "Nom du Genre", 
    COUNT(l.ID) AS "Quantité par genre",
    ROUND(COUNT(l.ID) * 100.0 / (SELECT COUNT(*) FROM BO.LIVRES), 2) AS "Part du genre (%)" 
FROM 
    BO.LIVRES l
INNER JOIN 
    BO.GENRES g ON l.GENRES_ID = g.ID
GROUP BY
    g.NOM_GENRE
ORDER BY 
    "Part du genre (%)" DESC;
    
-- 3.	Quel est le genre de livre le plus populaire auprès de la clientèle masculine? Afficher le nombre d’emprunts à ce jour ainsi que le genre de livre.
SELECT 
    g.NOM_GENRE AS "Genre",
    COUNT(e.ID) AS "Nombre d'emprunts"
FROM
    BO.EMPRUNTS e
INNER JOIN
    BO.MEMBRES m ON e.MEMBRES_ID = m.ID
INNER JOIN
    BO.LIVRES l ON e.LIVRES_ID = l.ID
INNER JOIN
    BO.GENRES g ON l.GENRES_ID = g.ID
WHERE
    m.GENRE = 'M'
GROUP BY 
    g.NOM_GENRE
ORDER BY 
    COUNT(e.ID) DESC
FETCH FIRST 1 ROWS ONLY;

-- 4.	Lister les membres (concaténation du prénom et du nom) qui ont fait plus de 3 emprunts au cours des 6 derniers mois à partir de la plus récente date du jeu de données (il y a une date d’emprunt, peu importe s’il a été retourné ou pas). Trier en ordre alphabétique de nom complet de membre.
SELECT
    m.PRENOM || ' ' || m.NOM AS "Prénom et nom"
FROM
    BO.EMPRUNTS e
INNER JOIN
    BO.MEMBRES m ON e.MEMBRES_ID = m.ID
WHERE
    e.DATE_EMPRUNT >= ADD_MONTHS((SELECT MAX(DATE_EMPRUNT) FROM BO.EMPRUNTS), -6)
GROUP BY 
    m.PRENOM || ' ' || m.NOM
HAVING 
    COUNT(e.ID) > 3
ORDER BY 
    "Prénom et nom";

-- 5.	Afficher la liste des membres qui ont des livres en retard. On ne veut voir que ceux dont le retard est supérieur à la moyenne des retards de tous les membres. Dans le résultat, nous aimerions avoir les colonnes Membre (concaténation de prénom et nom), Date_Emprunt, Titre et le nombre de jours en ordre décroissant. (*voir note).
SELECT
    m.PRENOM || ' ' || m.NOM AS "Prénom et nom",
    e.DATE_EMPRUNT AS "Date d'emprunt",
    l.TITRE AS "Titre",
    (e.DATE_RETOUR - e.DATE_RETOUR_PREVU) AS "Jours de retard"
FROM
    BO.EMPRUNTS e
INNER JOIN
    BO.MEMBRES m ON e.MEMBRES_ID = m.ID
INNER JOIN
    BO.LIVRES l ON e.LIVRES_ID = l.ID
WHERE
    (e.DATE_RETOUR - e.DATE_RETOUR_PREVU) > 0 
    AND (e.DATE_RETOUR - e.DATE_RETOUR_PREVU) > ( 
        SELECT AVG(e2.DATE_RETOUR - e2.DATE_RETOUR_PREVU)
        FROM BO.EMPRUNTS e2
        WHERE(e2.DATE_RETOUR - e2.DATE_RETOUR_PREVU) > 0 
    )
ORDER BY 
    "Jours de retard" DESC;

-- 6.	Afficher la liste des membres n'ayant pas encore emprunté de livre. Vous devez afficher le numéro de membre, puis son nom complet dans une seule colonne avec le format « Nom, P. ». Cette liste doit s’afficher en ordre alphabétique. 
SELECT
    m.CODE AS "Numéro de membre",
    m.NOM || ', ' || SUBSTR(m.PRENOM, 1, 1) || '.' AS "Nom et prénom"
FROM
    BO.MEMBRES m
LEFT JOIN
    BO.EMPRUNTS e ON m.ID = e.MEMBRES_ID
WHERE
    e.ID IS NULL
ORDER BY
    m.NOM ASC;

-- 7.	Quels sont les 3 livres qui ont été empruntés le plus souvent en 2022? On veut voir les colonnes suivantes : « Nombre d’emprunts » (écrit de cette manière et en ordre décroissant) et Titre.
SELECT 
    l.TITRE AS "Titre",
    COUNT(e.ID) AS "Nombre d’emprunts"
FROM
    BO.EMPRUNTS e
INNER JOIN
    BO.LIVRES l ON e.LIVRES_ID = l.ID
GROUP BY 
    l.TITRE 
ORDER BY 
    COUNT(e.ID) DESC
FETCH FIRST 3 ROWS ONLY;

-- 8.	Quelle est la valeur totale des livres perdus (livres qui ont été empruntés, mais jamais retournés et dont le membre a le statut Expiré)
SELECT 
    SUM(l.PRIX) AS "Valeur totale des livres perdus"
FROM
     BO.LIVRES l
INNER JOIN
    BO.EMPRUNTS e ON e.LIVRES_ID = l.ID
INNER JOIN
    BO.MEMBRES m ON e.MEMBRES_ID = m.ID
WHERE
    e.DATE_RETOUR IS NULL AND m.STATUT_MEMBRE = 'expiré';

-- 9.	Pour chaque section, afficher le nombre de livres par genres. Trier en ordre de nom de section et de nom de genre.
SELECT
    s.Nom AS "Nom section",
    g.NOM_GENRE AS "Nom genre",
    COUNT(l.ID) AS "Nombre de livre"
FROM
    BO.SECTIONS s
INNER JOIN
    BO.LIVRES l ON l.SECTIONS_ID = s.ID
INNER JOIN
    BO.GENRES g ON l.GENRES_ID = g.ID
GROUP BY
    s.NOM, g.NOM_GENRE
ORDER BY
    s.NOM, g.NOM_GENRE;

-- 10.	Créer une vue dans le schéma BO nommée RETARDS_ MEMBRES qui ferait afficher les membres qui ont des frais de retard et afficher le total des frais par membre considérant qu’il en coûte 0,25$ par jour et par livre (arrondir à 2 décimales). Triez en ordre décroissant de frais 
CREATE VIEW RETARDS_MEMBRES AS 
SELECT
    m.PRENOM || ' ' || m.NOM AS "Prénom et nom",
    SUM((e.DATE_RETOUR - e.DATE_RETOUR_PREVU) * 0.25) AS "Frais totaux"
FROM
    BO.EMPRUNTS e
INNER JOIN
    BO.MEMBRES m ON e.MEMBRES_ID = m.ID
WHERE
    (e.DATE_RETOUR - e.DATE_RETOUR_PREVU) > 0 
GROUP BY
    m.PRENOM, m.NOM
ORDER BY 
    "Frais totaux" DESC;