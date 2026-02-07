CREATE TYPE adresse_type AS OBJECT (
Num_Rue NUMBER,
Rue VARCHAR(50),
Ville VARCHAR(50),
Code_Postal NUMBER
)/
CREATE TYPE permis_type AS OBJECT (

Num_Permis NUMBER,
Date_Obt DATE,
Date_Exp DATE
)/
CREATE TYPE Assiduite_Type AS OBJECT (
Nbr_Infractions NUMBER,
Nbr_Accidents NUMBER
)/
CREATE TYPE Kilometrage_Type AS OBJECT (
Annee NUMBER,
Km_Fin_Ann_Prec NUMBER
)/
CREATE TYPE ENS_Km AS TABLE OF Kilometrage_Type/
CREATE TYPE Controle_Tech_Type AS OBJECT (
Date_Dernier_CT DATE,
Date_Prochain_CT DATE
)/
CREATE TYPE ENS_Controle_Tech AS TABLE OF Controle_Tech_Type/
CREATE TYPE Vidange_Type AS OBJECT (
Date_Derniere_Vid DATE,
Km_Derniere_Vid NUMBER
)/
CREATE TYPE ENS_Vid AS TABLE OF Vidange_Type /
CREATE TYPE Courroie_Type AS OBJECT (
Km_Derniere_Cour NUMBER,
Date_Derniere_Cour DATE
)/
CREATE TYPE ENS_Courroie AS TABLE OF COURROIE_TYPE /
CREATE TYPE Interventions_Type AS OBJECT (
Reparations VARCHAR(500),

Pieces_Endomg VARCHAR(500),
Date_Intrv DATE,
Cout NUMBER
)/
CREATE TYPE ENS_Interv AS TABLE OF INTERVENTIONS_TYPE /
CREATE TYPE Client_Type AS OBJECT(
ID_Client VARCHAR(50),
Nom_Client VARCHAR(20),
Prenom_Client VARCHAR(20),
Date_Naiss_Client DATE,
Adresse_Client REF ADRESSE_TYPE,
Num_Tel_Client_1 NUMBER,
Num_Tel_Client_2 NUMBER,
Num_Tel_Fixe NUMBER,
Num_Secu_Sociale NUMBER
) FINAL /
CREATE TYPE Conducteur_Type
CREATE TYPE Vehicule_Type AS OBJECT (
Num_ID_Vehicule NUMBER,
Num_Imm NUMBER,
Type_Vehicule VARCHAR(50),
Marque_V VARCHAR(50),
Modele_V VARCHAR(50),
Carburant_Utilise VARCHAR(50),
CO2 NUMBER,
Consomm_Moy NUMBER,
Date_Prem_Imm DATE,
Date_Acqui DATE,
Poids_Vide NUMBER,
PTC NUMBER,
Km_Actuel NUMBER,

Kilometrage ENS_Km,
Cadence_Vid NUMBER,
Vidange ENS_Vid,
Etat_general VARCHAR(15),
Interventions ENS_Interv,
Controle_Tech ENS_Controle_Tech,
Cadence_Cour NUMBER,
Courroie ENS_Courroie,
Conducteur_Affecte REF CONDUCTEUR_TYPE
)FINAL /
CREATE TYPE Conducteur_Type AS OBJECT (
ID_Conduct VARCHAR(50),
Nom_Conduct VARCHAR(20),
Prenom_Conduct VARCHAR(20),
Date_Naiss_Conduct DATE,
Adresse_Conduct REF ADRESSE_TYPE,
Num_Tel_Conduct_1 NUMBER,
Num_Tel_Conduct_2 NUMBER,
Permis_Conduire PERMIS_TYPE,
Date_Recrut_Conduct DATE,
Zone_Activité_Conduct NUMBER,
Assiduite_Conduite ASSIDUITE_TYPE,
Vehicule_Affecte REF VEHICULE_TYPE
)FINAL /
CREATE TYPE Louer_Type AS OBJECT(
ID_Location NUMBER,
Date_Deb_Location DATE,
Date_Restitu_Prevu DATE,
Kilometrage_Contract NUMBER,
Type_Location VARCHAR(10),
Date_Restitu DATE,
Kilometrage_Reel NUMBER,

Etat_Vehicule VARCHAR(10),
Ref_Client REF CLIENT_TYPE,
Ref_Vehicule REF VEHICULE_TYPE
)FINAL /
CREATE TABLE ADRESSES OF ADRESSE_TYPE(
CONSTRAINT pk_adr PRIMARY KEY (Num_Rue)
)/
CREATE TABLE CLIENTS OF CLIENT_TYPE(
CONSTRAINT pk_client PRIMARY KEY (ID_Client),
CONSTRAINT unq_num_secu UNIQUE (Num_Secu_Sociale)
)/
CREATE TABLE CONDUCTEURS OF CONDUCTEUR_TYPE(
CONSTRAINT pk_conducteur PRIMARY KEY (ID_Conduct)
)/
CREATE TABLE VEHICULES OF VEHICULE_TYPE(
CONSTRAINT pk_vehicule PRIMARY KEY (Num_ID_Vehicule),
CONSTRAINT chk_type_vehicule CHECK (Type_Vehicule IN
('Voiture', 'Bus', 'Fourgon', 'Camion')),
CONSTRAINT chk_etat_general CHECK (Etat_general IN
('Accidenté', 'Non accidenté'))
)NESTED TABLE Kilometrage STORE AS Le_Kilometrage,
NESTED TABLE Vidange STORE AS La_Vidange,
NESTED TABLE Interventions STORE AS Les_Interventions,
NESTED TABLE Controle_Tech STORE AS Le_Controle_Tech,
NESTED TABLE Courroie STORE AS La_Courroie/
CREATE TABLE LOUER OF LOUER_TYPE(
CONSTRAINT pk_location PRIMARY KEY (ID_Location),
CONSTRAINT chk_type_location CHECK (Type_Location IN ('Courte', 'Longue')),
CONSTRAINT chk_etat_vehicule_location CHECK (Etat_Vehicule IN
('Bon', 'Moyen', 'Grave'))
)/
-- Contrainte : Date de restitution >= Date de début de location
ALTER TABLE LOUER
ADD CONSTRAINT chk_dates_location
CHECK (Date_Restitu IS NULL OR Date_Restitu >= Date_Deb_Location)/
-- Contrainte : Date de restitution prévue >= Date de début
ALTER TABLE LOUER
ADD CONSTRAINT chk_dates_prevues
CHECK (Date_Restitu_Prevu >= Date_Deb_Location)/
-- Contrainte : Kilométrage réel >= 0
ALTER TABLE LOUER
ADD CONSTRAINT chk_km_reel
CHECK (Kilometrage_Reel >= 0)/
-- Contrainte : Kilométrage contractuel >= 0
ALTER TABLE LOUER
ADD CONSTRAINT chk_km_contract
CHECK (Kilometrage_Contract >= 0)/
-- Contrainte : Consommation moyenne > 0
ALTER TABLE VEHICULES
ADD CONSTRAINT chk_consomm
CHECK (Consomm_Moy > 0)/
-- Contrainte : Kilométrage actuel >= 0
ALTER TABLE VEHICULES
ADD CONSTRAINT chk_km_actuel
CHECK (Km_Actuel >= 0)/
-- Contrainte : Date d'acquisition >= Date première immatriculation
ALTER TABLE VEHICULES
ADD CONSTRAINT chk_dates_vehicule
CHECK (Date_Acqui >= Date_Prem_Imm)/
-- Contrainte : PTC > Poids_Vide
ALTER TABLE VEHICULES
ADD CONSTRAINT chk_poids
CHECK (PTC > Poids_Vide)/

CREATE OR REPLACE FUNCTION Get_Vehicules_Disponibles
RETURN NUMBER
IS
v_count NUMBER := 0;
BEGIN
SELECT COUNT(*)
INTO v_count
FROM VEHICULES V
WHERE NOT EXISTS (
SELECT 1
FROM LOUER L
WHERE L.Ref_Vehicule = REF(V)
AND L.Date_Restitu IS NULL
AND SYSDATE BETWEEN L.Date_Deb_Location AND L.Date_Restitu_Prevu
);
RETURN v_count;
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
RETURN -1;
END;

CREATE OR REPLACE PROCEDURE Ajouter_Client(
p_nom IN VARCHAR2,
p_prenom IN VARCHAR2,
p_date_naiss IN DATE,
p_num_rue IN NUMBER,
p_tel1 IN NUMBER,
p_tel2 IN NUMBER DEFAULT NULL,
p_tel_fixe IN NUMBER DEFAULT NULL,
p_num_secu IN NUMBER,
p_id_client OUT VARCHAR2
)
IS
v_ref_adresse REF Adresse_Type;
v_id_client VARCHAR2(50);
BEGIN
v_id_client := 'CLI_' || seq_client_id.NEXTVAL;
SELECT REF(A) INTO v_ref_adresse
FROM ADRESSES A
WHERE A.Num_Rue = p_num_rue;
INSERT INTO CLIENTS VALUES (
Client_Type(
v_id_client,
p_nom,
p_prenom,
p_date_naiss,
v_ref_adresse,
p_tel1,
p_tel2,
p_tel_fixe,
p_num_secu
)
);
p_id_client := v_id_client;
COMMIT;
DBMS_OUTPUT.PUT_LINE('Client ajouté avec succès - ID: ' || v_id_client);
EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
ROLLBACK;
RAISE_APPLICATION_ERROR(-20001, 'Numéro de sécurité sociale déjà existant');
WHEN NO_DATA_FOUND THEN
ROLLBACK;
RAISE_APPLICATION_ERROR(-20002, 'Adresse introuvable');
WHEN OTHERS THEN
ROLLBACK;
RAISE_APPLICATION_ERROR(-20003, 'Erreur lors de l''ajout: ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE Supprimer_Client(
p_id_client IN VARCHAR2
)
IS
v_count NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count
FROM CLIENTS C
WHERE C.ID_Client = p_id_client;
IF v_count = 0 THEN
RAISE_APPLICATION_ERROR(-20004, 'Client introuvable');
END IF;
SELECT COUNT(*) INTO v_count
FROM LOUER L, CLIENTS C
WHERE L.Ref_Client = REF(C)
AND C.ID_Client = p_id_client
AND L.Date_Restitu IS NULL;
IF v_count > 0 THEN
RAISE_APPLICATION_ERROR(-20005, 'Impossible de supprimer: locations en cours');
END IF;
DELETE FROM CLIENTS C
WHERE C.ID_Client = p_id_client;
COMMIT;
DBMS_OUTPUT.PUT_LINE('Client supprimé avec succès');
EXCEPTION
WHEN OTHERS THEN
ROLLBACK;
RAISE;
END;

CREATE OR REPLACE FUNCTION Get_Ville_Conducteur(
p_id_conducteur IN VARCHAR2
)
RETURN VARCHAR2
IS
v_ville VARCHAR2(50);
BEGIN
16
SELECT DEREF(C.Adresse_Conduct).Ville
INTO v_ville
FROM CONDUCTEURS C
WHERE C.ID_Conduct = p_id_conducteur;
RETURN v_ville;
EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN 'Conducteur introuvable';
WHEN OTHERS THEN
RETURN 'Erreur: ' || SQLERRM;
END;
Triggers pour automatiser certaines opérations
Date de remplacement de la courroie
CREATE OR REPLACE TRIGGER Notif_Courroie
BEFORE INSERT OR UPDATE ON VEHICULES
FOR EACH ROW
WHEN (NEW.Cadence_Cour IS NOT NULL AND NEW.Km_Actuel IS NOT NULL)
DECLARE
v_km_derniere NUMBER := 0;
v_km_depuis NUMBER;
BEGIN
BEGIN
IF :NEW.Courroie IS NOT NULL AND :NEW.Courroie.COUNT > 0 THEN
FOR cour IN (SELECT Km_Derniere_Cour FROM TABLE(:NEW.Courroie)
ORDER BY Date_Derniere_Cour DESC) LOOP
v_km_derniere := cour.Km_Derniere_Cour;
EXIT;
END LOOP;
END IF;
EXCEPTION
17
WHEN OTHERS THEN
v_km_derniere := 0;
END;

IF v_km_derniere > 0 THEN
v_km_depuis := :NEW.Km_Actuel - v_km_derniere;
IF v_km_depuis >= :NEW.Cadence_Cour THEN
RAISE_APPLICATION_ERROR(-20104,
'URGENT: Remplacement courroie dépassé pour véhicule '
|| :NEW.Num_ID_Vehicule ||
' - ' || v_km_depuis || ' km depuis dernier remplacement
(cadence: ' || :NEW.Cadence_Cour || ' km)');
ELSIF v_km_depuis >= (:NEW.Cadence_Cour - 1000) THEN
RAISE_APPLICATION_ERROR(-20105,
'ALERTE: Remplacement courroie proche pour véhicule ' ||
:NEW.Num_ID_Vehicule ||
' - ' || (:NEW.Cadence_Cour - v_km_depuis) || ' km restants');
END IF;
END IF;
EXCEPTION
WHEN OTHERS THEN
IF SQLCODE BETWEEN -20105 AND -20104 THEN
RAISE;
END IF;
END;

CREATE OR REPLACE TRIGGER Notif_Vidange_Date
BEFORE INSERT OR UPDATE ON VEHICULES
FOR EACH ROW
DECLARE
18
v_date_derniere DATE := NULL;
v_jours_depuis NUMBER;
BEGIN

BEGIN
IF :NEW.Vidange IS NOT NULL AND :NEW.Vidange.COUNT > 0 THEN
FOR i IN 1..:NEW.Vidange.COUNT LOOP
IF :NEW.Vidange(i).Date_Derniere_Vid IS NOT NULL THEN
IF v_date_derniere IS NULL OR
:NEW.Vidange(i).Date_Derniere_Vid > v_date_derniere THEN
v_date_derniere := :NEW.Vidange(i).Date_Derniere_Vid;
END IF;
END IF;
END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
v_date_derniere := NULL;
END;
IF v_date_derniere IS NOT NULL THEN
v_jours_depuis := TRUNC(SYSDATE - v_date_derniere);

IF v_jours_depuis >= 180 THEN
RAISE_APPLICATION_ERROR(-20110,
'URGENT: Vidange dépassée pour véhicule ' || :NEW.Num_ID_Vehicule ||
' - Dernière vidange: ' || TO_CHAR(v_date_derniere, 'DD/MM/YYYY') ||
' (' || v_jours_depuis || ' jours)');

(entre 172 et 179 jours = 8 jours avant les 6 mois)
ELSIF v_jours_depuis >= 172 AND v_jours_depuis < 180 THEN
RAISE_APPLICATION_ERROR(-20111,
19
'ALERTE: Vidange prévue dans ' || (180 - v_jours_depuis)
||' jours pour véhicule ' || :NEW.Num_ID_Vehicule ||
' - Dernière vidange: ' || TO_CHAR(v_date_derniere, 'DD/MM/YYYY'));
END IF;
END IF;
EXCEPTION
WHEN OTHERS THEN
IF SQLCODE BETWEEN -20111 AND -20110 THEN
RAISE;
END IF;
END;

CREATE OR REPLACE TRIGGER Notif_Controle_Tech
BEFORE INSERT OR UPDATE ON VEHICULES
FOR EACH ROW
DECLARE
v_date_prochain DATE := NULL;
v_jours_restants NUMBER;
BEGIN
BEGIN
IF :NEW.Controle_Tech IS NOT NULL AND :NEW.Controle_Tech.COUNT > 0 THEN
FOR ct IN (SELECT Date_Prochain_CT FROM TABLE(:NEW.Controle_Tech)
ORDER BY Date_Prochain_CT DESC) LOOP
v_date_prochain := ct.Date_Prochain_CT;
EXIT;
END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
v_date_prochain := NULL;
END;
IF v_date_prochain IS NOT NULL THEN
v_jours_restants := v_date_prochain - SYSDATE;
IF v_jours_restants < 0 THEN
RAISE_APPLICATION_ERROR(-20102,
'URGENT: Contrôle technique dépassé de ' || ABS(v_jours_restants) ||
' jours pour véhicule ' || :NEW.Num_ID_Vehicule);
ELSIF v_jours_restants <= 8 THEN
RAISE_APPLICATION_ERROR(-20103,
'ALERTE: Contrôle technique dans ' || v_jours_restants ||
' jours pour véhicule ' || :NEW.Num_ID_Vehicule ||
' (prévu le ' || TO_CHAR(v_date_prochain, 'DD/MM/YYYY') || ')');
END IF;
END IF;
EXCEPTION
WHEN OTHERS THEN
IF SQLCODE BETWEEN -20103 AND -20102 THEN
RAISE;
END IF;
END;

CREATE OR REPLACE TRIGGER Notif_Fin_Contrat
BEFORE INSERT OR UPDATE ON LOUER
FOR EACH ROW
WHEN (NEW.Date_Restitu IS NULL AND NEW.Date_Restitu_Prevu IS NOT NULL)
DECLARE
v_jours_restants NUMBER;
v_nom_client VARCHAR2(100);
BEGIN
v_jours_restants := :NEW.Date_Restitu_Prevu - SYSDATE;
BEGIN
SELECT DEREF(:NEW.Ref_Client).Nom_Client || ' ' ||
DEREF(:NEW.Ref_Client).Prenom_Client
INTO v_nom_client
FROM DUAL;
EXCEPTION
WHEN OTHERS THEN
v_nom_client := 'Client inconnu';
END;
IF v_jours_restants < 0 THEN
RAISE_APPLICATION_ERROR(-20106,
'URGENT: Contrat dépassé de ' || ABS(v_jours_restants) ||
' jours - Location #' || :NEW.ID_Location ||
' - Client: ' || v_nom_client);
ELSIF v_jours_restants <= 8 THEN
RAISE_APPLICATION_ERROR(-20107,
'ALERTE: Fin de contrat dans ' || v_jours_restants ||
' jours - Location #' || :NEW.ID_Location ||
' - Client: ' || v_nom_client ||
' - Date prévue: ' || TO_CHAR(:NEW.Date_Restitu_Prevu, 'DD/MM/YYYY'));
END IF;
EXCEPTION
WHEN OTHERS THEN
IF SQLCODE BETWEEN -20107 AND -20106 THEN
RAISE;
END IF;
END;
