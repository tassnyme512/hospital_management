-- Table Service
CREATE TABLE Service (
    idService INT,
    nomService VARCHAR2(100) NOT NULL,
    capacite INT NOT NULL,
    CONSTRAINT PK_Service PRIMARY KEY (idService),
    CONSTRAINT CHK_Service_Capacite CHECK (capacite > 0)
);

-- Table Patient
CREATE TABLE Patient (
    idPatient INT,
    nom VARCHAR2(100) NOT NULL,
    prenom VARCHAR2(100) NOT NULL,
    dateNaissance DATE NOT NULL,
    adresse VARCHAR2(255),
    telephone VARCHAR2(20),
    CONSTRAINT PK_Patient PRIMARY KEY (idPatient)
);

-- Table Medecin
CREATE TABLE Medecin (
    idMedecin INT,
    nom VARCHAR2(100) NOT NULL,
    specialite VARCHAR2(100) NOT NULL,
    salaire DECIMAL(10,2) NOT NULL,
    idService INT,
    CONSTRAINT PK_Medecin PRIMARY KEY (idMedecin),
    CONSTRAINT FK_Medecin_Service 
        FOREIGN KEY (idService) REFERENCES Service(idService),
    CONSTRAINT CHK_Medecin_Salaire CHECK (salaire > 0)
);

-- Table RendezVous
CREATE TABLE RendezVous (
    idRdv INT,
    idPatient INT,
    idMedecin INT,
    dateRdv DATE NOT NULL,
    statut VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_RendezVous PRIMARY KEY (idRdv),
    CONSTRAINT FK_Rdv_Patient 
        FOREIGN KEY (idPatient) REFERENCES Patient(idPatient),
    CONSTRAINT FK_Rdv_Medecin 
        FOREIGN KEY (idMedecin) REFERENCES Medecin(idMedecin),
    CONSTRAINT CHK_Rdv_Statut 
        CHECK (statut IN ('planifie', 'annule', 'termine'))
);

-- Table Hospitalisation
CREATE TABLE Hospitalisation (
    idHosp INT,
    idPatient INT,
    idService INT,
    dateEntree DATE NOT NULL,
    dateSortie DATE,
    CONSTRAINT PK_Hospitalisation PRIMARY KEY (idHosp),
    CONSTRAINT FK_Hosp_Patient 
        FOREIGN KEY (idPatient) REFERENCES Patient(idPatient),
    CONSTRAINT FK_Hosp_Service 
        FOREIGN KEY (idService) REFERENCES Service(idService),
    CONSTRAINT CHK_Hosp_Dates 
        CHECK (dateSortie IS NULL OR dateSortie >= dateEntree)
);

-- Table Medicament
CREATE TABLE Medicament (
    idMed INT,
    nom VARCHAR2(100) NOT NULL,
    stock INT NOT NULL,
    prix DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Medicament PRIMARY KEY (idMed),
    CONSTRAINT CHK_Med_Stock CHECK (stock >= 0),
    CONSTRAINT CHK_Med_Prix CHECK (prix > 0)
);

-- Table Prescription
CREATE TABLE Prescription (
    idPresc INT,
    idPatient INT,
    idMedecin INT,
    datePresc DATE NOT NULL,
    CONSTRAINT PK_Prescription PRIMARY KEY (idPresc),
    CONSTRAINT FK_Presc_Patient 
        FOREIGN KEY (idPatient) REFERENCES Patient(idPatient),
    CONSTRAINT FK_Presc_Medecin 
        FOREIGN KEY (idMedecin) REFERENCES Medecin(idMedecin)
);

-- Table Ligne_Prescription
CREATE TABLE Ligne_Prescription (
    idPresc INT,
    idMed INT,
    quantite INT NOT NULL,
    CONSTRAINT PK_Ligne_Prescription PRIMARY KEY (idPresc, idMed),
    CONSTRAINT FK_Ligne_Presc 
        FOREIGN KEY (idPresc) REFERENCES Prescription(idPresc),
    CONSTRAINT FK_Ligne_Med 
        FOREIGN KEY (idMed) REFERENCES Medicament(idMed),
    CONSTRAINT CHK_Quantite CHECK (quantite > 0)
);