CREATE DATABASE macropayDb;
USE macropayDb;
CREATE TABLE loans (
    Client VARCHAR(255),
    Id INT,
    Date_Loan DATE,
    Amount DECIMAL(10, 2),
    Status VARCHAR(50),
    IdSucursal INT,
    PRIMARY KEY (Client, Id)
);
CREATE TABLE Sucursales (
    ID INT PRIMARY KEY,
    Name VARCHAR(255),
    IVA DECIMAL(4, 2)
);
CREATE TABLE Accounts (
    Client VARCHAR(255) PRIMARY KEY,
    Amount DECIMAL(10, 2),
    Status VARCHAR(50)
);
INSERT INTO loans (Client, Id, Date_Loan, Amount, Status, IdSucursal) VALUES
('911ac37c-5990-4bf8-8cf0-b51f21c8ecbe', 1, '2021-01-15', 37500.00, 'Pendiente', 3),
('911ac37c-5990-4bf8-8cf0-b51f21c8ecbe', 2, '2021-01-24', 725.18, 'Pendiente', 3),
('911ac37c-5990-4bf8-8cf0-b51f21c8ecbe', 3, '2021-02-05', 1578.22, 'Pendiente', 3),
('911ac37c-5990-4bf8-8cf0-b51f21c8ecbe', 4, '2021-02-09', 380.00, 'Pendiente', 3),
('8482bcae-0b2b-45bb-9012-59ec93978265', 1, '2021-01-12', 2175.25, 'Pagado', 2),
('8482bcae-0b2b-45bb-9012-59ec93978265', 2, '2021-01-18', 499.99, 'Pagado', 2),
('8482bcae-0b2b-45bb-9012-59ec93978265', 3, '2021-01-29', 5725.18, 'Pendiente', 2),
('8482bcae-0b2b-45bb-9012-59ec93978265', 4, '2021-02-12', 876.13, 'Pendiente', 2),
('78be3a77-698d-43ef-b113-a598eb1fb791', 1, '2021-02-09', 545.55, 'Pendiente', 1),
('cee008ca-c715-456b-96c6-74ff9bd22dd3', 1, '2020-12-31', 15220.00, 'Pagado', 1);

INSERT INTO Sucursales (ID, Name, IVA) VALUES
(1, 'Tijuana', 8.00),
(2, 'Nuevo Leon', 16.00),
(3, 'Tamaulipas', 10.00);

INSERT INTO Accounts (Client, Amount, Status) VALUES
('911ac37c-5990-4bf8-8cf0-b51f21c8ecbe', 15375.28, 'Activa'),
('8482bcae-0b2b-45bb-9012-59ec93978265', 3728.51, 'Bloqueada'),
('78be3a77-698d-43ef-b113-a598eb1fb791', 0.00, 'Cancelada'),
('cee008ca-c715-456b-96c6-74ff9bd22dd3', 235.28, 'Activa');

commit;

select * from loans;
select * from Sucursales;
select * from Accounts;

SELECT * FROM loans WHERE Status = 'Pendiente';
SELECT * FROM Accounts WHERE Status = 'Activa';

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

INSERT INTO roles (name) VALUES ('ROLE_USER'), ('ROLE_ADMIN');

CREATE TABLE CobrosAuditoria (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Client VARCHAR(255),
    LoanId INT,
    MontoCobrado DECIMAL(10, 2),
    FechaCobro DATE
);


SELECT * FROM loans;
SELECT * FROM CobrosAuditoria;

SHOW TABLES;
select  * from users;

select u1_0.id,u1_0.name,u1_0.password,u1_0.role,u1_0.username from users u1_0 where u1_0.username='macropay';

INSERT INTO `users` (username, name, password, role) 
VALUES ('macropay', 'sa de cv', '123', 'ROLE_ADMINISTRATOR');


