DELIMITER //

DROP PROCEDURE IF EXISTS CobroAutomatico; -- Asegúrate de eliminar la versión anterior

CREATE PROCEDURE CobroAutomatico(
    IN fecha_actual DATE,
    IN tasa_interes DECIMAL(4, 2),
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

    -- Confirmar la transacción
    COMMIT;

END //

DELIMITER ;

CALL CobroAutomatico('2021-02-20', 7.50, 360);

