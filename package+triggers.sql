-- =============================================================
-- PACKAGE SPECIFICATION
-- =============================================================
CREATE OR REPLACE PACKAGE pkg_hopital AS

    ex_stock_insuffisant EXCEPTION;
    ex_rdv_conflit       EXCEPTION;
    ex_capacite_depassee EXCEPTION;

    -- CRUD MEDECIN
    PROCEDURE ajouter_medecin(
        p_idMedecin  IN Medecin.idMedecin%TYPE,
        p_nom        IN Medecin.nom%TYPE,
        p_specialite IN Medecin.specialite%TYPE,
        p_salaire    IN Medecin.salaire%TYPE,
        p_idService  IN Medecin.idService%TYPE DEFAULT NULL
    );

    PROCEDURE modifier_medecin(
        p_idMedecin  IN Medecin.idMedecin%TYPE,
        p_nom        IN Medecin.nom%TYPE,
        p_specialite IN Medecin.specialite%TYPE,
        p_salaire    IN Medecin.salaire%TYPE,
        p_idService  IN Medecin.idService%TYPE DEFAULT NULL
    );

    PROCEDURE supprimer_medecin(
        p_idMedecin IN Medecin.idMedecin%TYPE
    );

    PROCEDURE afficher_medecins;

    -- CRUD MEDICAMENT
    PROCEDURE ajouter_medicament(
        p_idMed IN Medicament.idMed%TYPE,
        p_nom   IN Medicament.nom%TYPE,
        p_stock IN Medicament.stock%TYPE,
        p_prix  IN Medicament.prix%TYPE
    );

    PROCEDURE modifier_medicament(
        p_idMed IN Medicament.idMed%TYPE,
        p_nom   IN Medicament.nom%TYPE,
        p_stock IN Medicament.stock%TYPE,
        p_prix  IN Medicament.prix%TYPE
    );

    PROCEDURE supprimer_medicament(
        p_idMed IN Medicament.idMed%TYPE
    );

    PROCEDURE afficher_medicament;

    -- CRUD PATIENT
    PROCEDURE ajouter_patient(
        p_idPatient     IN Patient.idPatient%TYPE,
        p_nom           IN Patient.nom%TYPE,
        p_prenom        IN Patient.prenom%TYPE,
        p_dateNaissance IN Patient.dateNaissance%TYPE,
        p_adresse       IN Patient.adresse%TYPE DEFAULT NULL,
        p_telephone     IN Patient.telephone%TYPE DEFAULT NULL
    );

    PROCEDURE modifier_patient(
        p_idPatient     IN Patient.idPatient%TYPE,
        p_nom           IN Patient.nom%TYPE,
        p_prenom        IN Patient.prenom%TYPE,
        p_dateNaissance IN Patient.dateNaissance%TYPE,
        p_adresse       IN Patient.adresse%TYPE DEFAULT NULL,
        p_telephone     IN Patient.telephone%TYPE DEFAULT NULL
    );

    PROCEDURE supprimer_patient(
        p_idPatient IN Patient.idPatient%TYPE
    );

    PROCEDURE lister_patients;

    -- CRUD RENDEZ-VOUS
    PROCEDURE ajouter_rendezvous(
        p_idRdv     IN RendezVous.idRdv%TYPE,
        p_idPatient IN RendezVous.idPatient%TYPE,
        p_idMedecin IN RendezVous.idMedecin%TYPE,
        p_dateRdv   IN RendezVous.dateRdv%TYPE,
        p_statut    IN RendezVous.statut%TYPE DEFAULT 'planifie'
    );

    PROCEDURE modifier_rendezvous(
        p_idRdv     IN RendezVous.idRdv%TYPE,
        p_idPatient IN RendezVous.idPatient%TYPE,
        p_idMedecin IN RendezVous.idMedecin%TYPE,
        p_dateRdv   IN RendezVous.dateRdv%TYPE,
        p_statut    IN RendezVous.statut%TYPE
    );

    PROCEDURE supprimer_rendezvous(
        p_idRdv IN RendezVous.idRdv%TYPE
    );

    PROCEDURE afficher_rendezvous;

    -- PROCEDURES ET FONCTIONS METIERS
    PROCEDURE afficher_rdv_medecin(
        p_idMedecin IN Medecin.idMedecin%TYPE
    );

    PROCEDURE liste_hospitalisations;

    PROCEDURE medicaments_rupture;

    FUNCTION nb_patients_service(
        p_idService Service.idService%TYPE
    ) RETURN NUMBER;

    FUNCTION total_medicaments_patient(
        p_idPatient Patient.idPatient%TYPE
    ) RETURN NUMBER;

    FUNCTION cout_prescription(
        p_idPresc Prescription.idPresc%TYPE
    ) RETURN NUMBER;

    PROCEDURE prescrire_medicament(
        p_idPresc   Prescription.idPresc%TYPE,
        p_idPatient Prescription.idPatient%TYPE,
        p_idMedecin Prescription.idMedecin%TYPE,
        p_idMed     Ligne_Prescription.idMed%TYPE,
        p_quantite  Ligne_Prescription.quantite%TYPE
    );

END pkg_hopital;
/


-- =============================================================
-- PACKAGE BODY
-- =============================================================
CREATE OR REPLACE PACKAGE BODY pkg_hopital AS

    -- ----------------------------------------------------------
    -- CRUD MEDECIN
    -- ----------------------------------------------------------

    PROCEDURE ajouter_medecin(
        p_idMedecin  IN Medecin.idMedecin%TYPE,
        p_nom        IN Medecin.nom%TYPE,
        p_specialite IN Medecin.specialite%TYPE,
        p_salaire    IN Medecin.salaire%TYPE,
        p_idService  IN Medecin.idService%TYPE DEFAULT NULL
    )
    IS
        v_count NUMBER;
    BEGIN
        IF p_salaire <= 0 THEN
            RAISE_APPLICATION_ERROR(-20030, 'Erreur : le salaire doit etre strictement positif.');
        END IF;

        IF TRIM(p_specialite) IS NULL OR LENGTH(TRIM(p_specialite)) < 2 THEN
            RAISE_APPLICATION_ERROR(-20032, 'Erreur : la specialite doit contenir au moins 2 caracteres.');
        END IF;

        IF p_idService IS NOT NULL THEN
            SELECT COUNT(*) INTO v_count
            FROM Service
            WHERE idService = p_idService;

            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20033, 'Erreur : le service ID=' || p_idService || ' n''existe pas.');
            END IF;
        END IF;

        INSERT INTO Medecin (idMedecin, nom, specialite, salaire, idService)
        VALUES (p_idMedecin, p_nom, p_specialite, p_salaire, p_idService);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Medecin "Dr ' || p_nom || '" (' || p_specialite || ') ajoute avec succes (ID=' || p_idMedecin || ').');

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : l''ID ' || p_idMedecin || ' est deja utilise.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur ' || SQLERRM);
    END ajouter_medecin;


    PROCEDURE modifier_medecin(
        p_idMedecin  IN Medecin.idMedecin%TYPE,
        p_nom        IN Medecin.nom%TYPE,
        p_specialite IN Medecin.specialite%TYPE,
        p_salaire    IN Medecin.salaire%TYPE,
        p_idService  IN Medecin.idService%TYPE DEFAULT NULL
    )
    IS
        v_count      NUMBER;
        v_ancien_sal Medecin.salaire%TYPE;
    BEGIN
        SELECT COUNT(*), MAX(salaire) INTO v_count, v_ancien_sal
        FROM Medecin
        WHERE idMedecin = p_idMedecin;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20040, 'Erreur : aucun medecin trouve avec l''ID ' || p_idMedecin || '.');
        END IF;

        IF p_salaire <= 0 THEN
            RAISE_APPLICATION_ERROR(-20041, 'Erreur : le salaire doit etre strictement positif.');
        END IF;

        IF TRIM(p_specialite) IS NULL OR LENGTH(TRIM(p_specialite)) < 2 THEN
            RAISE_APPLICATION_ERROR(-20043, 'Erreur : la specialite doit contenir au moins 2 caracteres.');
        END IF;

        IF p_idService IS NOT NULL THEN
            SELECT COUNT(*) INTO v_count
            FROM Service
            WHERE idService = p_idService;

            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20044, 'Erreur : le service ID=' || p_idService || ' n''existe pas.');
            END IF;
        END IF;

        UPDATE Medecin
        SET nom        = p_nom,
            specialite = p_specialite,
            salaire    = p_salaire,
            idService  = p_idService
        WHERE idMedecin = p_idMedecin;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Medecin ID=' || p_idMedecin || ' modifie avec succes.');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur:' || SQLERRM);
    END modifier_medecin;


    PROCEDURE supprimer_medecin(
        p_idMedecin IN Medecin.idMedecin%TYPE
    )
    IS
        v_count      NUMBER;
        v_nb_consult NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM Medecin
        WHERE idMedecin = p_idMedecin;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20050, 'Erreur : aucun medecin trouve avec l''ID ' || p_idMedecin || '.');
        END IF;

        SELECT COUNT(*) INTO v_nb_consult
        FROM RendezVous
        WHERE idMedecin = p_idMedecin AND dateRdv >= TRUNC(SYSDATE);

        IF v_nb_consult > 0 THEN
            RAISE_APPLICATION_ERROR(-20051,
                'Erreur : le medecin ID=' || p_idMedecin ||
                ' a ' || v_nb_consult || ' consultation(s) future(s) planifiee(s). Suppression impossible.');
        END IF;

        DELETE FROM Medecin WHERE idMedecin = p_idMedecin;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Medecin ID=' || p_idMedecin || ' supprime avec succes.');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue : ' || SQLERRM);
    END supprimer_medecin;


    PROCEDURE afficher_medecins
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID | NOM | SPECIALITE | SALAIRE | SERVICE');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

        FOR rec IN (
            SELECT m.idMedecin, m.nom, m.specialite, m.salaire, s.nomService
            FROM Medecin m LEFT JOIN Service s ON m.idService = s.idService
            ORDER BY m.idMedecin
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                rec.idMedecin  || ' | ' ||
                rec.nom        || ' | ' ||
                rec.specialite || ' | ' ||
                rec.salaire    || ' | ' ||
                NVL(rec.nomService, 'Non affecte')
            );
        END LOOP;
    END afficher_medecins;


    -- ----------------------------------------------------------
    -- CRUD MEDICAMENT
    -- ----------------------------------------------------------

    PROCEDURE ajouter_medicament(
        p_idMed IN Medicament.idMed%TYPE,
        p_nom   IN Medicament.nom%TYPE,
        p_stock IN Medicament.stock%TYPE,
        p_prix  IN Medicament.prix%TYPE
    )
    IS
    BEGIN
        IF TRIM(p_nom) IS NULL OR LENGTH(TRIM(p_nom)) < 2 THEN
            RAISE_APPLICATION_ERROR(-20100, 'Erreur : le nom du medicament doit contenir au moins 2 caracteres.');
        END IF;

        IF p_stock < 0 THEN
            RAISE_APPLICATION_ERROR(-20101, 'Erreur : le stock ne peut pas etre negatif.');
        END IF;

        IF p_prix <= 0 THEN
            RAISE_APPLICATION_ERROR(-20102, 'Erreur : le prix doit etre strictement positif.');
        END IF;

        INSERT INTO Medicament (idMed, nom, stock, prix)
        VALUES (p_idMed, p_nom, p_stock, p_prix);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Medicament "' || p_nom || '" ajoute avec succes (ID=' || p_idMed || ').');

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : l''ID ' || p_idMed || ' est deja utilise.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur:' || SQLERRM);
    END ajouter_medicament;


    PROCEDURE modifier_medicament(
        p_idMed IN Medicament.idMed%TYPE,
        p_nom   IN Medicament.nom%TYPE,
        p_stock IN Medicament.stock%TYPE,
        p_prix  IN Medicament.prix%TYPE
    )
    IS
        v_count         NUMBER;
        v_ancien_prix   Medicament.prix%TYPE;
        v_ancien_stock  Medicament.stock%TYPE;
        v_qte_prescrite NUMBER;
    BEGIN
        SELECT COUNT(*), MAX(prix), MAX(stock)
        INTO v_count, v_ancien_prix, v_ancien_stock
        FROM Medicament
        WHERE idMed = p_idMed;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20110, 'Erreur : aucun medicament trouve avec l''ID ' || p_idMed || '.');
        END IF;

        IF TRIM(p_nom) IS NULL OR LENGTH(TRIM(p_nom)) < 2 THEN
            RAISE_APPLICATION_ERROR(-20111, 'Erreur : le nom du medicament doit contenir au moins 2 caracteres.');
        END IF;

        IF p_stock < 0 THEN
            RAISE_APPLICATION_ERROR(-20112, 'Erreur : le stock ne peut pas etre negatif.');
        END IF;

        IF p_prix <= 0 THEN
            RAISE_APPLICATION_ERROR(-20113, 'Erreur : le prix doit etre strictement positif.');
        END IF;

        SELECT NVL(SUM(lp.quantite), 0)
        INTO v_qte_prescrite
        FROM Ligne_Prescription lp
        WHERE lp.idMed = p_idMed;

        IF p_stock < v_qte_prescrite THEN
            RAISE ex_stock_insuffisant;
        END IF;

        UPDATE Medicament
        SET nom   = p_nom,
            stock = p_stock,
            prix  = p_prix
        WHERE idMed = p_idMed;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Medicament ID=' || p_idMed || ' modifie avec succes.');

    EXCEPTION
        WHEN ex_stock_insuffisant THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : stock insuffisant par rapport aux prescriptions actives.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END modifier_medicament;


    PROCEDURE supprimer_medicament(
        p_idMed IN Medicament.idMed%TYPE
    )
    IS
        v_count     NUMBER;
        v_nb_lignes NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM Medicament
        WHERE idMed = p_idMed;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20120, 'Erreur : aucun medicament trouve avec l''ID ' || p_idMed || '.');
        END IF;

        SELECT COUNT(*) INTO v_nb_lignes
        FROM Ligne_Prescription
        WHERE idMed = p_idMed;

        IF v_nb_lignes > 0 THEN
            RAISE_APPLICATION_ERROR(-20121,
                'Erreur : impossible de supprimer le medicament ID=' || p_idMed ||
                '. Il est reference dans ' || v_nb_lignes || ' ligne(s) de prescription. Suppression interdite.');
        END IF;

        DELETE FROM Medicament WHERE idMed = p_idMed;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Medicament ID=' || p_idMed || ' supprime avec succes.');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END supprimer_medicament;


    PROCEDURE afficher_medicament
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID | NOM | STOCK | PRIX');
        DBMS_OUTPUT.PUT_LINE('----------------------------------');
        FOR rec IN (SELECT * FROM Medicament)
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                rec.idMed || ' | ' ||
                rec.nom   || ' | ' ||
                rec.stock || ' | ' ||
                rec.prix
            );
        END LOOP;
    END afficher_medicament;


    -- ----------------------------------------------------------
    -- CRUD PATIENT
    -- ----------------------------------------------------------

    PROCEDURE ajouter_patient(
        p_idPatient     IN Patient.idPatient%TYPE,
        p_nom           IN Patient.nom%TYPE,
        p_prenom        IN Patient.prenom%TYPE,
        p_dateNaissance IN Patient.dateNaissance%TYPE,
        p_adresse       IN Patient.adresse%TYPE DEFAULT NULL,
        p_telephone     IN Patient.telephone%TYPE DEFAULT NULL
    )
    IS
    BEGIN
        IF p_dateNaissance >= TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Erreur : la date de naissance doit etre anterieure a aujourd''hui.');
        END IF;

        IF p_dateNaissance < ADD_MONTHS(SYSDATE, -1800) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erreur : date de naissance invalide (plus de 150 ans).');
        END IF;

        IF p_telephone IS NOT NULL THEN
            IF NOT REGEXP_LIKE(p_telephone, '^[0-9\+\-\s]{7,20}$') THEN
                RAISE_APPLICATION_ERROR(-20004, 'Erreur : format du numero de telephone invalide.');
            END IF;
        END IF;

        INSERT INTO Patient (idPatient, nom, prenom, dateNaissance, adresse, telephone)
        VALUES (p_idPatient, p_nom, p_prenom, p_dateNaissance, p_adresse, p_telephone);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Patient "' || p_prenom || ' ' || p_nom || '" ajoute avec succes (ID=' || p_idPatient || ').');

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : l''ID ' || p_idPatient || ' est deja utilise.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue : ' || SQLERRM);
    END ajouter_patient;


    PROCEDURE modifier_patient(
        p_idPatient     IN Patient.idPatient%TYPE,
        p_nom           IN Patient.nom%TYPE,
        p_prenom        IN Patient.prenom%TYPE,
        p_dateNaissance IN Patient.dateNaissance%TYPE,
        p_adresse       IN Patient.adresse%TYPE DEFAULT NULL,
        p_telephone     IN Patient.telephone%TYPE DEFAULT NULL
    )
    IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM Patient
        WHERE idPatient = p_idPatient;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Erreur : aucun patient trouve avec l''ID ' || p_idPatient || '.');
        END IF;

        IF p_dateNaissance >= TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20011, 'Erreur : la date de naissance doit etre anterieure a aujourd''hui.');
        END IF;

        IF p_dateNaissance < ADD_MONTHS(SYSDATE, -1800) THEN
            RAISE_APPLICATION_ERROR(-20012, 'Erreur : date de naissance invalide (plus de 150 ans).');
        END IF;

        IF p_telephone IS NOT NULL THEN
            IF NOT REGEXP_LIKE(p_telephone, '^[0-9\+\-\s]{7,20}$') THEN
                RAISE_APPLICATION_ERROR(-20013, 'Erreur : format du numero de telephone invalide.');
            END IF;
        END IF;

        UPDATE Patient
        SET nom           = p_nom,
            prenom        = p_prenom,
            dateNaissance = p_dateNaissance,
            adresse       = p_adresse,
            telephone     = p_telephone
        WHERE idPatient = p_idPatient;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Patient ID=' || p_idPatient || ' modifie avec succes.');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue : ' || SQLERRM);
    END modifier_patient;


    PROCEDURE supprimer_patient(
        p_idPatient IN Patient.idPatient%TYPE
    )
    IS
        v_exist      NUMBER;
        v_nb_rdv     NUMBER;
        v_nb_hosp    NUMBER;
        v_nb_presc   NUMBER;
        v_msg_erreur VARCHAR2(500);
    BEGIN
        SELECT COUNT(*) INTO v_exist
        FROM Patient
        WHERE idPatient = p_idPatient;

        IF v_exist = 0 THEN
            RAISE_APPLICATION_ERROR(-20050, 'Erreur : aucun patient trouve avec l''ID ' || p_idPatient || '.');
        END IF;

        SELECT COUNT(*) INTO v_nb_rdv
        FROM RendezVous
        WHERE idPatient = p_idPatient;

        SELECT COUNT(*) INTO v_nb_hosp
        FROM Hospitalisation
        WHERE idPatient = p_idPatient;

        SELECT COUNT(*) INTO v_nb_presc
        FROM Prescription
        WHERE idPatient = p_idPatient;

        IF v_nb_rdv > 0 OR v_nb_hosp > 0 OR v_nb_presc > 0 THEN
            v_msg_erreur := 'Erreur : impossible de supprimer le patient ID=' || p_idPatient || '. Donnees liees existantes :';
            IF v_nb_rdv > 0 THEN
                v_msg_erreur := v_msg_erreur || ' | RendezVous : ' || v_nb_rdv;
            END IF;
            IF v_nb_hosp > 0 THEN
                v_msg_erreur := v_msg_erreur || ' | Hospitalisations : ' || v_nb_hosp;
            END IF;
            IF v_nb_presc > 0 THEN
                v_msg_erreur := v_msg_erreur || ' | Prescriptions : ' || v_nb_presc || ' (avec leurs lignes de prescription associees)';
            END IF;
            RAISE_APPLICATION_ERROR(-20051, v_msg_erreur);
        END IF;

        DELETE FROM Patient WHERE idPatient = p_idPatient;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Patient ID=' || p_idPatient || ' supprime avec succes.');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
    END supprimer_patient;


    PROCEDURE lister_patients
    IS
        v_age NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID | NOM | PRENOM | AGE | ADRESSE | TELEPHONE');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
        FOR rec IN (SELECT * FROM Patient)
        LOOP
            v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, rec.dateNaissance) / 12);
            DBMS_OUTPUT.PUT_LINE(
                rec.idPatient || ' | ' ||
                rec.nom       || ' | ' ||
                rec.prenom    || ' | ' ||
                v_age || ' ans | ' ||
                NVL(rec.adresse,   'N/A') || ' | ' ||
                NVL(rec.telephone, 'N/A')
            );
        END LOOP;
    END lister_patients;


    -- ----------------------------------------------------------
    -- CRUD RENDEZ-VOUS
    -- ----------------------------------------------------------

    PROCEDURE ajouter_rendezvous(
        p_idRdv     IN RendezVous.idRdv%TYPE,
        p_idPatient IN RendezVous.idPatient%TYPE,
        p_idMedecin IN RendezVous.idMedecin%TYPE,
        p_dateRdv   IN RendezVous.dateRdv%TYPE,
        p_statut    IN RendezVous.statut%TYPE DEFAULT 'planifie'
    )
    IS
        v_count NUMBER;
    BEGIN
        IF p_dateRdv <= TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20200, 'Erreur : la date du rendez-vous doit etre dans le futur.');
        END IF;

        IF p_statut <> 'planifie' THEN
            RAISE_APPLICATION_ERROR(-20202, 'Erreur : un nouveau rendez-vous doit obligatoirement avoir le statut "planifie".');
        END IF;

        SELECT COUNT(*) INTO v_count
        FROM Patient WHERE idPatient = p_idPatient;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20203, 'Erreur : le patient ID=' || p_idPatient || ' n''existe pas.');
        END IF;

        SELECT COUNT(*) INTO v_count
        FROM Medecin WHERE idMedecin = p_idMedecin;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20204, 'Erreur : le medecin ID=' || p_idMedecin || ' n''existe pas.');
        END IF;

        SELECT COUNT(*) INTO v_count
        FROM RendezVous
        WHERE idMedecin = p_idMedecin
          AND TRUNC(dateRdv) = TRUNC(p_dateRdv)
          AND statut = 'planifie';

        IF v_count > 0 THEN
            RAISE ex_rdv_conflit;
        END IF;

        SELECT COUNT(*) INTO v_count
        FROM RendezVous
        WHERE idPatient = p_idPatient
          AND TRUNC(dateRdv) = TRUNC(p_dateRdv)
          AND statut = 'planifie';

        IF v_count > 0 THEN
            RAISE ex_rdv_conflit;
        END IF;

        INSERT INTO RendezVous (idRdv, idPatient, idMedecin, dateRdv, statut)
        VALUES (p_idRdv, p_idPatient, p_idMedecin, p_dateRdv, p_statut);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Rendez-vous ID=' || p_idRdv ||
            ' cre avec succes pour le ' || TO_CHAR(p_dateRdv, 'DD/MM/YYYY') || '.');

    EXCEPTION
        WHEN ex_rdv_conflit THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : conflit des rendez-vous, il y a deja un rendez-vous planifie pour le medecin ou pour le patient pour la date ' ||
                TO_CHAR(p_dateRdv, 'DD/MM/YYYY') || '.');
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : l''ID ' || p_idRdv || ' est deja utilise.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur:' || SQLERRM);
    END ajouter_rendezvous;


    PROCEDURE modifier_rendezvous(
        p_idRdv     IN RendezVous.idRdv%TYPE,
        p_idPatient IN RendezVous.idPatient%TYPE,
        p_idMedecin IN RendezVous.idMedecin%TYPE,
        p_dateRdv   IN RendezVous.dateRdv%TYPE,
        p_statut    IN RendezVous.statut%TYPE
    )
    IS
        v_count         NUMBER;
        v_statut_actuel RendezVous.statut%TYPE;
    BEGIN
        SELECT COUNT(*), MAX(statut)
        INTO v_count, v_statut_actuel
        FROM RendezVous
        WHERE idRdv = p_idRdv;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20210, 'Erreur : aucun rendez-vous trouve avec l''ID ' || p_idRdv || '.');
        END IF;

        IF v_statut_actuel IN ('termine', 'annule') THEN
            RAISE_APPLICATION_ERROR(-20211,
                'Erreur : impossible de modifier un rendez-vous ayant le statut "' || v_statut_actuel || '".');
        END IF;

        IF p_statut NOT IN ('planifie', 'annule', 'termine') THEN
            RAISE_APPLICATION_ERROR(-20212,
                'Erreur : statut invalide "' || p_statut || '". Valeurs acceptees : planifie, annule, termine.');
        END IF;

        IF p_statut = 'planifie' AND p_dateRdv <= TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20213, 'Erreur : la date du rendez-vous planifie doit etre dans le futur.');
        END IF;

        SELECT COUNT(*) INTO v_count
        FROM Patient WHERE idPatient = p_idPatient;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20214, 'Erreur : le patient ID=' || p_idPatient || ' n''existe pas.');
        END IF;

        SELECT COUNT(*) INTO v_count
        FROM Medecin WHERE idMedecin = p_idMedecin;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20215, 'Erreur : le medecin ID=' || p_idMedecin || ' n''existe pas.');
        END IF;

        IF p_statut = 'planifie' THEN
            SELECT COUNT(*) INTO v_count
            FROM RendezVous
            WHERE idMedecin = p_idMedecin
              AND TRUNC(dateRdv) = TRUNC(p_dateRdv)
              AND statut = 'planifie'
              AND idRdv <> p_idRdv;

            IF v_count > 0 THEN
                RAISE ex_rdv_conflit;
            END IF;

            SELECT COUNT(*) INTO v_count
            FROM RendezVous
            WHERE idPatient = p_idPatient
              AND TRUNC(dateRdv) = TRUNC(p_dateRdv)
              AND statut = 'planifie'
              AND idRdv <> p_idRdv;

            IF v_count > 0 THEN
                RAISE ex_rdv_conflit;
            END IF;
        END IF;

        UPDATE RendezVous
        SET idPatient = p_idPatient,
            idMedecin = p_idMedecin,
            dateRdv   = p_dateRdv,
            statut    = p_statut
        WHERE idRdv = p_idRdv;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Rendez-vous ID=' || p_idRdv ||
            ' modifie avec succes. Nouveau statut : ' || p_statut || '.');

    EXCEPTION
        WHEN ex_rdv_conflit THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : conflit des rendez-vous, il y a deja un rendez-vous planifie pour le medecin ou pour le patient pour la date ' ||
                TO_CHAR(p_dateRdv, 'DD/MM/YYYY') || '.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END modifier_rendezvous;


    PROCEDURE supprimer_rendezvous(
        p_idRdv IN RendezVous.idRdv%TYPE
    )
    IS
        v_count   NUMBER;
        v_statut  RendezVous.statut%TYPE;
        v_dateRdv RendezVous.dateRdv%TYPE;
    BEGIN
        SELECT COUNT(*), MAX(statut), MAX(dateRdv)
        INTO v_count, v_statut, v_dateRdv
        FROM RendezVous
        WHERE idRdv = p_idRdv;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20220, 'Erreur : aucun rendez-vous trouve avec l''ID ' || p_idRdv || '.');
        END IF;

        IF v_statut = 'termine' THEN
            RAISE_APPLICATION_ERROR(-20221,
                'Erreur : impossible de supprimer un rendez-vous termine. Il fait partie de l''historique medical du patient.');
        END IF;

        IF v_statut = 'planifie' AND v_dateRdv < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20222,
                'Erreur : ce rendez-vous est passe et toujours "planifie". Mettez d''abord son statut a "annule" ou "termine" avant suppression.');
        END IF;

        DELETE FROM RendezVous WHERE idRdv = p_idRdv;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Rendez-vous ID=' || p_idRdv || ' supprime avec succes.');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END supprimer_rendezvous;


    PROCEDURE afficher_rendezvous
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID | DATE | STATUT | NOM_PATIENT | PRENOM_PATIENT | NOM_MEDECIN | SPECIALITE');
        DBMS_OUTPUT.PUT_LINE('----------------------------------');
        FOR rec IN (
            SELECT r.idRdv,
                   r.dateRdv,
                   r.statut,
                   p.nom    AS nom_patient,
                   p.prenom AS prenom_patient,
                   m.nom    AS nom_medecin,
                   m.specialite
            FROM RendezVous r
            JOIN Patient p ON r.idPatient = p.idPatient
            JOIN Medecin m ON r.idMedecin = m.idMedecin
            ORDER BY r.dateRdv
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                rec.idRdv || ' | ' ||
                TO_CHAR(rec.dateRdv, 'DD/MM/YYYY') || ' | ' ||
                rec.statut || ' | ' ||
                rec.prenom_patient || ' ' || rec.nom_patient || ' | ' ||
                'Dr ' || rec.nom_medecin || ' (' || rec.specialite || ')'
            );
        END LOOP;
    END afficher_rendezvous;


    -- ----------------------------------------------------------
    -- PROCEDURES ET FONCTIONS METIERS
    -- ----------------------------------------------------------

    PROCEDURE afficher_rdv_medecin(
        p_idMedecin IN Medecin.idMedecin%TYPE
    )
    IS
        CURSOR rdv(idmedc Medecin.idMedecin%TYPE) IS
            SELECT * FROM RendezVous WHERE idMedecin = idmedc;

        nompat VARCHAR2(100);
        ligne  rdv%ROWTYPE;
    BEGIN
        OPEN rdv(p_idMedecin);
        LOOP
            FETCH rdv INTO ligne;
            EXIT WHEN rdv%NOTFOUND;

            SELECT nom INTO nompat
            FROM Patient
            WHERE idPatient = ligne.idPatient;

            DBMS_OUTPUT.PUT_LINE(
                'date: ' || ligne.dateRdv ||
                ' | Nom de patient: ' || nompat ||
                ' | statut: ' || ligne.statut
            );
        END LOOP;

        IF rdv%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Aucun rendez-vous pour ce medecin.');
        END IF;

        CLOSE rdv;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : patient n''existe pas.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur:' || SQLERRM);
    END afficher_rdv_medecin;


    FUNCTION nb_patients_service(
        p_idService Service.idService%TYPE
    ) RETURN NUMBER
    IS
        somme      NUMBER;
        v_capacite Service.capacite%TYPE;
    BEGIN
        SELECT COUNT(DISTINCT idPatient)
        INTO somme
        FROM Hospitalisation
        WHERE idService = p_idService AND dateSortie IS NULL;

        SELECT capacite INTO v_capacite
        FROM Service
        WHERE idService = p_idService;

        IF somme >= v_capacite THEN
            RAISE ex_capacite_depassee;
        END IF;

        RETURN somme;
    EXCEPTION
        WHEN ex_capacite_depassee THEN
            DBMS_OUTPUT.PUT_LINE('Capacite depassee pour le service ID=' || p_idService || '.');
            RETURN somme;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur:' || SQLERRM);
            RETURN NULL;
    END nb_patients_service;


    FUNCTION total_medicaments_patient(
        p_idPatient Patient.idPatient%TYPE
    ) RETURN NUMBER
    IS
        somme NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(lp.quantite), 0) INTO somme
        FROM Ligne_Prescription lp
        INNER JOIN Prescription p ON lp.idPresc = p.idPresc
        WHERE p.idPatient = p_idPatient;

        RETURN somme;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur:' || SQLERRM);
            RETURN NULL;
    END total_medicaments_patient;


    FUNCTION cout_prescription(
        p_idPresc Prescription.idPresc%TYPE
    ) RETURN NUMBER
    IS
        cout NUMBER;
    BEGIN
        SELECT SUM(lp.quantite * m.prix) INTO cout
        FROM Ligne_Prescription lp
        INNER JOIN Medicament m ON lp.idMed = m.idMed
        WHERE lp.idPresc = p_idPresc;

        RETURN NVL(cout, 0);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur:' || SQLERRM);
            RETURN NULL;
    END cout_prescription;


    PROCEDURE liste_hospitalisations
    IS
        CURSOR hospitalisations IS SELECT * FROM Hospitalisation;

        ligne      hospitalisations%ROWTYPE;
        nomServ    Service.nomService%TYPE;
        nomPatient Patient.nom%TYPE;
        dureeSej   VARCHAR2(50);
    BEGIN
        OPEN hospitalisations;
        LOOP
            FETCH hospitalisations INTO ligne;
            EXIT WHEN hospitalisations%NOTFOUND;

            SELECT nom INTO nomPatient
            FROM Patient
            WHERE idPatient = ligne.idPatient;

            SELECT nomService INTO nomServ
            FROM Service
            WHERE idService = ligne.idService;

            IF ligne.dateSortie IS NULL THEN
                dureeSej := 'indeterminee';
            ELSIF ligne.dateSortie < ligne.dateEntree THEN
                dureeSej := 'date sortie invalide';
            ELSE
                dureeSej := TO_CHAR(ligne.dateSortie - ligne.dateEntree) || ' jours';
            END IF;

            DBMS_OUTPUT.PUT_LINE(
                'patient: ' || nomPatient ||
                ' | service: ' || nomServ ||
                ' | duree de sejour: ' || dureeSej
            );
        END LOOP;
        CLOSE hospitalisations;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Donnee introuvable.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur:' || SQLERRM);
    END liste_hospitalisations;


    PROCEDURE medicaments_rupture
    IS
        TYPE tableau IS TABLE OF Medicament.nom%TYPE INDEX BY BINARY_INTEGER;
        medRupturees tableau;
        CURSOR medrupt IS SELECT nom FROM Medicament WHERE stock = 0;
        i BINARY_INTEGER := 1;
    BEGIN
        FOR rec IN medrupt LOOP
            medRupturees(i) := rec.nom;
            i := i + 1;
        END LOOP;

        IF medRupturees.COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Aucun medicament en rupture.');
        ELSE
            i := medRupturees.FIRST;
            WHILE i IS NOT NULL LOOP
                DBMS_OUTPUT.PUT_LINE('- ' || medRupturees(i));
                i := medRupturees.NEXT(i);
            END LOOP;
        END IF;
    END medicaments_rupture;


    PROCEDURE prescrire_medicament(
        p_idPresc   Prescription.idPresc%TYPE,
        p_idPatient Prescription.idPatient%TYPE,
        p_idMedecin Prescription.idMedecin%TYPE,
        p_idMed     Ligne_Prescription.idMed%TYPE,
        p_quantite  Ligne_Prescription.quantite%TYPE
    )
    IS
        v_count  NUMBER;
        v_stock  Medicament.stock%TYPE;
    BEGIN
        SELECT stock INTO v_stock
        FROM Medicament
        WHERE idMed = p_idMed;

        IF v_stock < p_quantite THEN
            RAISE ex_stock_insuffisant;
        END IF;

        SELECT COUNT(*) INTO v_count
        FROM Prescription
        WHERE idPresc = p_idPresc;

        IF v_count = 0 THEN
            INSERT INTO Prescription (idPresc, idPatient, idMedecin, datePresc)
            VALUES (p_idPresc, p_idPatient, p_idMedecin, SYSDATE);
        END IF;

        INSERT INTO Ligne_Prescription (idPresc, idMed, quantite)
        VALUES (p_idPresc, p_idMed, p_quantite);

        UPDATE Medicament
        SET stock = stock - p_quantite
        WHERE idMed = p_idMed;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Prescription realisee avec succes.');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : medicament introuvable.');
        WHEN ex_stock_insuffisant THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : stock insuffisant.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
    END prescrire_medicament;



-- =============================================================
-- TRIGGERS
-- =============================================================

CREATE OR REPLACE TRIGGER trg_rdv_before_insert
BEFORE INSERT ON RendezVous
FOR EACH ROW
DECLARE
    v_n NUMBER;
BEGIN
    IF :NEW.dateRdv <= SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20042, 'La date du RDV doit etre dans le futur.');
    END IF;

    SELECT COUNT(*) INTO v_n
    FROM RendezVous
    WHERE idMedecin = :NEW.idMedecin
      AND TRUNC(dateRdv, 'HH') = TRUNC(:NEW.dateRdv, 'HH');

    IF v_n > 0 THEN
        RAISE_APPLICATION_ERROR(-20043, 'Conflit de rendez-vous : ce creneau est deja pris pour ce medecin.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('[TRIGGER] RDV valide pour medecin ID ' || :NEW.idMedecin);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        RAISE;
END trg_rdv_before_insert;
/


CREATE OR REPLACE TRIGGER trg_update_ligne_presc
AFTER UPDATE ON Ligne_Prescription
FOR EACH ROW
DECLARE
    v_stock Medicament.stock%TYPE;
BEGIN
    IF :NEW.quantite > :OLD.quantite THEN
        SELECT stock INTO v_stock
        FROM Medicament
        WHERE idMed = :NEW.idMed;

        IF v_stock < (:NEW.quantite - :OLD.quantite) THEN
            RAISE_APPLICATION_ERROR(-20500, 'Erreur : stock insuffisant pour modification de la prescription.');
        END IF;

        UPDATE Medicament
        SET stock = stock - (:NEW.quantite - :OLD.quantite)
        WHERE idMed = :NEW.idMed;

    ELSIF :NEW.quantite < :OLD.quantite THEN
        UPDATE Medicament
        SET stock = stock + (:OLD.quantite - :NEW.quantite)
        WHERE idMed = :NEW.idMed;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20501, 'Erreur : medicament introuvable.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20502, 'Erreur : ' || SQLERRM);
END trg_update_ligne_presc;
/


CREATE OR REPLACE TRIGGER trg_ddl_operations
AFTER CREATE OR DROP OR ALTER ON SCHEMA
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        'Operation: ' || ORA_SYSEVENT ||
        ' | Objet: '  || ORA_DICT_OBJ_NAME ||
        ' | Type: '   || ORA_DICT_OBJ_TYPE
    );
END trg_ddl_operations;
/


CREATE OR REPLACE TRIGGER trg_logon
AFTER LOGON ON DATABASE
BEGIN
    DBMS_OUTPUT.PUT_LINE('Connexion de l''utilisateur : ' || USER);
END trg_logon;
/


CREATE OR REPLACE TRIGGER trg_capacite_service
BEFORE INSERT OR UPDATE ON Hospitalisation
FOR EACH ROW
DECLARE
    v_nb_patients NUMBER;
    v_capacite    Service.capacite%TYPE;
BEGIN
    SELECT capacite INTO v_capacite
    FROM Service
    WHERE idService = :NEW.idService;

    SELECT COUNT(*) INTO v_nb_patients
    FROM Hospitalisation
    WHERE idService = :NEW.idService
      AND dateSortie IS NULL;

    IF :NEW.dateSortie IS NULL THEN
        IF v_nb_patients >= v_capacite THEN
            RAISE_APPLICATION_ERROR(-20167, 'Capacite du service depassee.');
        END IF;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20068, 'Service introuvable.');
END trg_capacite_service;
/


CREATE OR REPLACE TRIGGER trg_double_hospitalisation
BEFORE INSERT OR UPDATE ON Hospitalisation
FOR EACH ROW
DECLARE
    v_nb NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_nb
    FROM Hospitalisation
    WHERE idPatient = :NEW.idPatient
      AND idHosp <> NVL(:NEW.idHosp, -1)
      AND (
            -- chevauchement des periodes
            :NEW.dateEntree <= NVL(dateSortie, DATE '9999-12-31')
        AND NVL(:NEW.dateSortie, DATE '9999-12-31') >= dateEntree
          );

    IF v_nb > 0 THEN
        RAISE_APPLICATION_ERROR(-20010,'Patient deja hospitalise sur cette periode.');
    END IF;

END trg_double_hospitalisation;
/