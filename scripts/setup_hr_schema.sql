-- Connect as SYSDBA
CONNECT / AS SYSDBA

-- Create tablespace for HR schema
CREATE TABLESPACE hr_data
  DATAFILE 'hr_data01.dbf'
  SIZE 100M
  AUTOEXTEND ON
  NEXT 50M
  MAXSIZE UNLIMITED;

-- Unlock HR user and set password
ALTER USER hr ACCOUNT UNLOCK;
ALTER USER hr IDENTIFIED BY "SecretDataStack5623#";

-- Grant necessary privileges
GRANT CREATE SESSION TO hr;
GRANT CREATE TABLE TO hr;
GRANT CREATE VIEW TO hr;
GRANT CREATE PROCEDURE TO hr;
GRANT CREATE SEQUENCE TO hr;
GRANT UNLIMITED TABLESPACE TO hr;

-- Connect as HR and import sample data
CONNECT hr/"SecretDataStack5623#"

-- Create tables and import data (example for EMPLOYEES table)
CREATE TABLE employees (
    employee_id    NUMBER(6) PRIMARY KEY,
    first_name     VARCHAR2(20),
    last_name      VARCHAR2(25) NOT NULL,
    email          VARCHAR2(25) NOT NULL,
    phone_number   VARCHAR2(20),
    hire_date      DATE NOT NULL,
    job_id         VARCHAR2(10) NOT NULL,
    salary         NUMBER(8,2),
    commission_pct NUMBER(2,2),
    manager_id     NUMBER(6),
    department_id  NUMBER(4)
);
