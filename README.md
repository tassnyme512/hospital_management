# hospital_management
Hospital Management System (Oracle PL/SQL)
Overview

This project is an Oracle PL/SQL-based Hospital Management System designed to manage:

Services (hospital departments)
Patients
Doctors
Appointments
Hospitalizations
Medications
Prescriptions

The system combines a relational database schema with a PL/SQL package that implements business logic, CRUD operations, validation rules, and healthcare-specific functionalities.

Database Schema
Entities
Table	Description
Service	Hospital departments and their capacities
Patient	Patient personal information
Medecin	Doctors and their specialties
RendezVous	Medical appointments
Hospitalisation	Patient admissions and stays
Medicament	Medication inventory
Prescription	Prescriptions issued by doctors
Ligne_Prescription	Prescription details and quantities

Main Features:
 Doctor Management:
-Add a doctor
-Update doctor information
-Delete a doctor
-List all doctors
 Validate:
-Positive salary
-Existing service assignment
-Valid specialty
 Patient Management:
-Add patients
-Update patient records
-Delete patients
-Display patient lists
 Medication Management:
-Add medications
-Update stock and price
-Delete medications
-Inventory validation
-Low-stock monitoring
 Appointment Management:
-Create appointments
-Modify appointments
-Cancel appointments
-Display appointment schedules
 Prescription Management:
-Create prescriptions
-Add prescribed medications
-Check stock availability
-Calculate prescription cost
-Update medication inventory automatically
 Hospitalization Management:
-Track admissions
-Track discharges
-Monitor service occupancy

Project Structure
.
├── CreateTables.sql
│   ├── Service
│   ├── Patient
│   ├── Medecin
│   ├── RendezVous
│   ├── Hospitalisation
│   ├── Medicament
│   ├── Prescription
│   └── Ligne_Prescription
│
└── package+triggers.sql
    ├── Package Specification
    ├── Package Body
    ├── CRUD Procedures
    ├── Business Functions
    └── Triggers
Data Integrity Constraints
Primary Keys

Implemented on all major entities:

Service
Patient
Medecin
RendezVous
Hospitalisation
Medicament
Prescription
Foreign Keys

Ensure consistency between:

Doctors ↔ Services
Appointments ↔ Patients
Appointments ↔ Doctors
Hospitalizations ↔ Patients
Hospitalizations ↔ Services
Prescriptions ↔ Patients
Prescriptions ↔ Doctors
Prescription Lines ↔ Medications


Technologies Used
Oracle Database
PL/SQL
SQL DDL
SQL Constraints
Packages
Procedures
Functions
Triggers
Exception Handling

