DELIMITER //

CREATE PROCEDURE CobroAutomatico(
    IN fecha_actual DATE,
    IN tasa_interes DECIMAL(5,2),
    IN dias_anio_comercial INT
)
BEGIN
    DECLARE plazo INT;
    DECLARE interest DECIMAL(10, 2);
    DECLARE iva DECIMAL(10, 2);
    DECLARE paymentAmount DECIMAL(10, 2);

    -- Crear tabla temporal para almacenar los resultados del cobro
    CREATE TEMPORARY TABLE IF NOT EXISTS Resultados (
        Cliente VARCHAR(255),
        Plazo INT,
        Monto DECIMAL(10, 2),
        Interes DECIMAL(10, 2),
        Iva DECIMAL(10, 2),
        Pago DECIMAL(10, 2)
    );

    -- Iniciar la transacción
    START TRANSACTION;

    -- Actualizar préstamos pendientes y cuentas activas en un solo paso
    INSERT INTO CobrosAuditoria (Client, LoanId, MontoCobrado, FechaCobro)
    SELECT l.Client, l.Id, l.Amount + ROUND((l.Amount * DATEDIFF(fecha_actual, l.Date_Loan) * tasa_interes) / dias_anio_comercial, 2) +
           ROUND(ROUND((l.Amount * DATEDIFF(fecha_actual, l.Date_Loan) * tasa_interes) / dias_anio_comercial, 2) * (s.IVA / 100), 2) AS paymentAmount,
           fecha_actual
    FROM loans l
    JOIN Accounts a ON l.Client = a.Client
    JOIN Sucursales s ON l.IdSucursal = s.ID
    WHERE l.Status = 'Pendiente' 
    AND a.Status = 'Activa' 
    AND a.Amount >= (l.Amount + ROUND((l.Amount * DATEDIFF(fecha_actual, l.Date_Loan) * tasa_interes) / dias_anio_comercial, 2) +
           ROUND(ROUND((l.Amount * DATEDIFF(fecha_actual, l.Date_Loan) * tasa_interes) / dias_anio_comercial, 2) * (s.IVA / 100), 2));

    -- Actualizar los saldos y marcar préstamos como pagados
    UPDATE loans l
    JOIN CobrosAuditoria ca ON l.Client = ca.Client AND l.Id = ca.LoanId
    SET l.Status = 'Pagado'
    WHERE ca.FechaCobro = fecha_actual;

    UPDATE Accounts a
    JOIN CobrosAuditoria ca ON a.Client = ca.Client
    SET a.Amount = a.Amount - ca.MontoCobrado
    WHERE ca.FechaCobro = fecha_actual;

    -- Insertar resultados en la tabla temporal
    INSERT INTO Resultados (Cliente, Plazo, Monto, Interes, Iva, Pago)
    SELECT ca.Client AS Cliente,
           DATEDIFF(fecha_actual, l.Date_Loan) AS Plazo,
           l.Amount AS Monto,
           ROUND((l.Amount * DATEDIFF(fecha_actual, l.Date_Loan) * tasa_interes) / dias_anio_comercial, 2) AS Interes,
           ROUND(ROUND((l.Amount * DATEDIFF(fecha_actual, l.Date_Loan) * tasa_interes) / dias_anio_comercial, 2) * (s.IVA / 100), 2) AS Iva,
           ca.MontoCobrado AS Pago
    FROM CobrosAuditoria ca
    JOIN loans l ON ca.LoanId = l.Id
    JOIN Sucursales s ON l.IdSucursal = s.ID
    WHERE ca.FechaCobro = fecha_actual;

    -- Seleccionar los resultados
    SELECT * FROM Resultados;

    -- Cerrar la transacción
    COMMIT;

END //

DELIMITER ;






SHOW PROCEDURE STATUS WHERE Name = 'CobroAutomatico';
SHOW TABLES;
DROP PROCEDURE IF EXISTS CobroAutomatico;
DROP TABLE IF EXISTS Resultados;
DROP TABLE IF EXISTS CobrosAuditoria;
commit;

CALL CobroAutomatico('2021-02-20', 7.50, 360);


CREATE TABLE CobrosAuditoria (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Client VARCHAR(255) NOT NULL,
    LoanId INT NOT NULL,
    MontoCobrado DECIMAL(10, 2) NOT NULL,
    FechaCobro DATE NOT NULL
);

CREATE TEMPORARY TABLE Resultados (
    Cliente VARCHAR(255),
    Plazo INT,
    Monto DECIMAL(10, 2),
    Interes DECIMAL(10, 2),
    Iva DECIMAL(10, 2),
    Pago DECIMAL(10, 2)
);



-- Para ver las filas afectadas
SELECT * FROM CobrosAuditoria;
SELECT * FROM Resultados;