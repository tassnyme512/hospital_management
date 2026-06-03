SET SERVEROUTPUT ON SIZE UNLIMITED;

-- =============================================================
-- DONNeES DE TEST
-- =============================================================
BEGIN
    INSERT INTO Service VALUES (1, 'Cardiologie', 2);
    INSERT INTO Service VALUES (2, 'Neurologie',  3);
    INSERT INTO Service VALUES (3, 'Pediatrie',   3);

    INSERT INTO Patient VALUES (1, 'Ben Ali',  'Ahmed', DATE '1990-05-10', 'Tunis', '12345678');
    INSERT INTO Patient VALUES (2, 'Trabelsi', 'Sarra', DATE '1985-03-22', 'Sfax',  '98765432');
    INSERT INTO Patient VALUES (3, 'Khaled',   'Mouna', DATE '2000-11-15', NULL,    NULL);

    INSERT INTO Medecin VALUES (1, 'Hamdi', 'Cardiologue', 3000, 1);
    INSERT INTO Medecin VALUES (2, 'Sami',  'Neurologue',  3500, 2);
    INSERT INTO Medecin VALUES (3, 'Lina',  'Pediatre',    2800, 3);

    INSERT INTO Medicament VALUES (1, 'Doliprane',   100, 5);
    INSERT INTO Medicament VALUES (2, 'Aspirine',     50, 3);
    INSERT INTO Medicament VALUES (3, 'Amoxicilline', 30, 10);
    INSERT INTO Medicament VALUES (4, 'Ibuprofene',    0, 8);

    INSERT INTO RendezVous VALUES (1, 1, 1, SYSDATE + 1, 'planifie');
    INSERT INTO RendezVous VALUES (2, 2, 2, SYSDATE + 2, 'planifie');
    INSERT INTO RendezVous VALUES (3, 3, 3, SYSDATE + 3, 'planifie');

    INSERT INTO Hospitalisation VALUES (1, 1, 1, SYSDATE - 5,  NULL);
    INSERT INTO Hospitalisation VALUES (2, 2, 2, SYSDATE - 10, SYSDATE - 2);
    INSERT INTO Hospitalisation VALUES (3, 3, 3, SYSDATE - 3,  NULL);

    INSERT INTO Prescription VALUES (1, 1, 1, SYSDATE);
    INSERT INTO Prescription VALUES (2, 2, 2, SYSDATE);

    INSERT INTO Ligne_Prescription VALUES (1, 1, 10);
    INSERT INTO Ligne_Prescription VALUES (1, 2, 5);
    INSERT INTO Ligne_Prescription VALUES (2, 3, 10);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('>>> Donnees inserees.');
END;
/

-- =============================================================
-- TESTS
-- =============================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  CRUD');
    DBMS_OUTPUT.PUT_LINE('========================================');

    -- Ajout medecin valide
    pkg_hopital.ajouter_medecin(10, 'Zouari', 'Dermatologue', 3200, 1);

    -- Ajout medecin doublon (erreur attendue)
    pkg_hopital.ajouter_medecin(1, 'Doublon', 'Cardiologue', 3000, 1);

    -- Ajout medecin salaire invalide (erreur attendue)
    pkg_hopital.ajouter_medecin(11, 'Test', 'Chirurgien', -500, 1);

    -- Modifier medecin
    pkg_hopital.modifier_medecin(10, 'Zouari', 'Dermatologue', 3500, 2);

    -- Supprimer medecin avec RDV futurs (erreur attendue)
    pkg_hopital.supprimer_medecin(1);

    -- Supprimer medecin sans contrainte
    pkg_hopital.supprimer_medecin(10);

    DBMS_OUTPUT.PUT_LINE('--- Affichage medecins ---');
    pkg_hopital.afficher_medecins;

    DBMS_OUTPUT.PUT_LINE('--- Ajout patient valide ---');
    pkg_hopital.ajouter_patient(10, 'Gharbi', 'Yasmine', DATE '1995-08-20', 'Bizerte', '71234567');

    -- Date future (erreur attendue)
    pkg_hopital.ajouter_patient(11, 'Test', 'Test', SYSDATE + 1);

    -- Supprimer patient avec donnees liees (erreur attendue)
    pkg_hopital.supprimer_patient(1);

    -- Supprimer patient sans donnees liees
    pkg_hopital.supprimer_patient(10);

    DBMS_OUTPUT.PUT_LINE('--- Ajout medicament valide ---');
    pkg_hopital.ajouter_medicament(10, 'Paracetamol', 200, 4.5);

    -- Prix invalide (erreur attendue)
    pkg_hopital.ajouter_medicament(11, 'TestMed', 10, -2);

    -- Supprimer medicament avec prescription (erreur attendue)
    pkg_hopital.supprimer_medicament(1);

    -- Supprimer medicament sans prescription
    pkg_hopital.supprimer_medicament(10);

    DBMS_OUTPUT.PUT_LINE('--- Ajout RDV valide ---');
    pkg_hopital.ajouter_rendezvous(10, 1, 3, SYSDATE + 10);

    -- Conflit medecin (erreur attendue)
    pkg_hopital.ajouter_rendezvous(11, 3, 1, SYSDATE + 1);

    -- Modifier RDV -> annule
    pkg_hopital.modifier_rendezvous(10, 1, 3, SYSDATE + 10, 'annule');

    -- Supprimer RDV annule
    pkg_hopital.supprimer_rendezvous(10);

    DBMS_OUTPUT.PUT_LINE('--- Affichage RDV ---');
    pkg_hopital.afficher_rendezvous;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  CURSEURS & FONCTIONS');
    DBMS_OUTPUT.PUT_LINE('========================================');

    DBMS_OUTPUT.PUT_LINE('--- RDV medecin 1 ---');
    pkg_hopital.afficher_rdv_medecin(1);

    DBMS_OUTPUT.PUT_LINE('--- RDV medecin sans RDV (medecin 99) ---');
    pkg_hopital.afficher_rdv_medecin(99);

    DBMS_OUTPUT.PUT_LINE('--- Liste hospitalisations ---');
    pkg_hopital.liste_hospitalisations;

    DBMS_OUTPUT.PUT_LINE('--- Medicaments en rupture ---');
    pkg_hopital.medicaments_rupture;

    DBMS_OUTPUT.PUT_LINE('--- Verification patient implicite ---');
    pkg_hopital.verif_patient_implecite('Ben Ali');
    pkg_hopital.verif_patient_implecite('Inconnu');

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  FONCTIONS (resultats calcules)');
    DBMS_OUTPUT.PUT_LINE('========================================');

    DBMS_OUTPUT.PUT_LINE('Patients service 1 : ' || pkg_hopital.nb_patients_service(1));
    DBMS_OUTPUT.PUT_LINE('Total medicaments patient 1 : ' || pkg_hopital.total_medicaments_patient(1));
    DBMS_OUTPUT.PUT_LINE('Coût prescription 1 : ' || pkg_hopital.cout_prescription(1));

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  PRESCRIPTION MeDICAMENT');
    DBMS_OUTPUT.PUT_LINE('========================================');

    -- Prescription valide
    pkg_hopital.prescrire_medicament(10, 3, 2, 1, 5);
    DBMS_OUTPUT.PUT_LINE('Stock Doliprane apres prescription (attendu 95) :');

    -- Stock insuffisant (erreur attendue)
    pkg_hopital.prescrire_medicament(11, 3, 2, 4, 50);

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  TRIGGERS');
    DBMS_OUTPUT.PUT_LINE('========================================');

    -- Trigger : RDV date passee (erreur attendue)
    BEGIN
        INSERT INTO RendezVous VALUES (20, 3, 2, SYSDATE - 1, 'planifie');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Trigger RDV date passee bloque : ' || SQLERRM);
    END;

    -- Trigger : capacite service depassee (service 1 capacite=2, deja 1 actif)
    INSERT INTO Hospitalisation VALUES (10, 2, 1, SYSDATE - 1, NULL);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('2eme patient service 1 : OK');
    BEGIN
        INSERT INTO Hospitalisation VALUES (11, 3, 1, SYSDATE, NULL);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Trigger capacite depassee bloque : ' || SQLERRM);
    END;

    -- Trigger : double hospitalisation meme periode (erreur attendue)
    BEGIN
        INSERT INTO Hospitalisation VALUES (12, 1, 2, SYSDATE - 3, NULL);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Trigger double hospitalisation bloque : ' || SQLERRM);
    END;

    -- Trigger : mise a jour stock via Ligne_Prescription
    DBMS_OUTPUT.PUT_LINE('Stock Doliprane avant update ligne prescription :');
    UPDATE Ligne_Prescription SET quantite = 15 WHERE idPresc = 1 AND idMed = 1;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Stock Doliprane apres update quantite 10->15 (attendu -5) :');

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  TOUS LES TESTS TERMINeS');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- Verification stocks finaux
SELECT idMed, nom, stock FROM Medicament ORDER BY idMed;

BEGIN
    -- Tables dependantes
    DELETE FROM Ligne_Prescription;
    DELETE FROM Prescription;
    DELETE FROM RendezVous;
    DELETE FROM Hospitalisation;

    -- Tables principales
    DELETE FROM Medicament;
    DELETE FROM Patient;
    DELETE FROM Medecin;
    DELETE FROM Service;

    DBMS_OUTPUT.PUT_LINE('Nettoyage des donnees termine');
END;
/
