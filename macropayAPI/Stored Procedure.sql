DELIMITER //

CREATE PROCEDURE CobroAutomatico(
    IN fecha_actual DATE,
    IN tasa_interes DECIMAL(5,2),
    IN dias_anio_comercial INT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE clientId VARCHAR(255);
    DECLARE loanId INT;
    DECLARE loanAmount DECIMAL(10, 2);
    DECLARE loanDate DATE;
    DECLARE accountAmount DECIMAL(10, 2);
    DECLARE interest DECIMAL(10, 2);
    DECLARE iva DECIMAL(10, 2);
    DECLARE paymentAmount DECIMAL(10, 2);
    DECLARE sucursalIVA DECIMAL(4, 2);
    DECLARE plazo INT;

    -- Cursor para recorrer las cuentas activas
    DECLARE loan_cursor CURSOR FOR
        SELECT l.Client, l.Id, l.Amount, l.Date_Loan, a.Amount, s.IVA
        FROM loans l
        JOIN Accounts a ON l.Client = a.Client
        JOIN Sucursales s ON l.IdSucursal = s.ID
        WHERE l.Status = 'Pendiente' AND a.Status = 'Activa'
        ORDER BY l.Date_Loan;

    -- Handler para terminar el cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Iniciar la transacción
    START TRANSACTION;

    -- Abrir el cursor
    OPEN loan_cursor;

    read_loop: LOOP
        FETCH loan_cursor INTO clientId, loanId, loanAmount, loanDate, accountAmount, sucursalIVA;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calcular el plazo
        SET plazo = DATEDIFF(fecha_actual, loanDate);

        -- Calcular interés
        SET interest = ROUND((loanAmount * plazo * tasa_interes) / dias_anio_comercial, 2);

        -- Calcular IVA
        SET iva = ROUND(interest * (sucursalIVA / 100), 2);

        -- Calcular monto total del pago
        SET paymentAmount = loanAmount + interest + iva;

        -- Validar si hay suficiente saldo en la cuenta para hacer el cobro
        IF accountAmount >= paymentAmount THEN
            -- Actualizar el préstamo como pagado
            UPDATE loans
            SET Status = 'Pagado'
            WHERE Client = clientId AND Id = loanId;

            -- Descontar el pago del saldo de la cuenta
            UPDATE Accounts
            SET Amount = Amount - paymentAmount
            WHERE Client = clientId;

            -- (Opcional) Insertar registro en tabla de auditoría
            INSERT INTO CobrosAuditoria (Client, LoanId, MontoCobrado, FechaCobro)
            VALUES (clientId, loanId, paymentAmount, fecha_actual);
        END IF;
    END LOOP;

    -- Cerrar el cursor
    CLOSE loan_cursor;

    -- Crear tabla temporal para almacenar los resultados
    CREATE TEMPORARY TABLE Resultados (
        Cliente VARCHAR(255),
        Plazo INT,
        Monto DECIMAL(10, 2),
        Interes DECIMAL(10, 2),
        Iva DECIMAL(10, 2),
        Pago DECIMAL(10, 2)
    );

    -- Insertar los resultados de los pagos en la tabla temporal
    INSERT INTO Resultados (Cliente, Plazo, Monto, Interes, Iva, Pago)
    SELECT ca.Client AS Cliente,
           DATEDIFF(fecha_actual, ca.FechaCobro) AS Plazo,
           ca.MontoCobrado AS Monto,
           ROUND((ca.MontoCobrado * DATEDIFF(fecha_actual, ca.FechaCobro) * tasa_interes) / dias_anio_comercial, 2) AS Interes,
           ROUND((ROUND((ca.MontoCobrado * DATEDIFF(fecha_actual, ca.FechaCobro) * tasa_interes) / dias_anio_comercial, 2) * (s.IVA / 100)), 2) AS Iva,
           (ca.MontoCobrado + ROUND((ca.MontoCobrado * DATEDIFF(fecha_actual, ca.FechaCobro) * tasa_interes) / dias_anio_comercial, 2) +
           ROUND((ROUND((ca.MontoCobrado * DATEDIFF(fecha_actual, ca.FechaCobro) * tasa_interes) / dias_anio_comercial, 2) * (s.IVA / 100)), 2)) AS Pago
    FROM CobrosAuditoria ca
    JOIN loans l ON ca.LoanId = l.Id
    JOIN Sucursales s ON l.IdSucursal = s.ID
    WHERE ca.FechaCobro = fecha_actual;

    -- Seleccionar los resultados finales
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