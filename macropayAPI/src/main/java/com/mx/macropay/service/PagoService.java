package com.mx.macropay.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.mx.macropay.dto.CobroRequest;

@Service
public class PagoService {

	@Autowired
	private JdbcTemplate jdbcTemplate;

	public Map<String, Object> ejecutarCobro(CobroRequest cobroRequest) {
		String sql = "{CALL CobroAutomatico(?, ?, ?)}";

		// Ejecutar el procedimiento
		jdbcTemplate.update(sql, cobroRequest.getFechaActual(), cobroRequest.getTasaInteres(),
				cobroRequest.getDiasAnioComercial());

		// Consulta para obtener los pagos y cuentas después de ejecutar el cobro
		String pagosSql = "SELECT l.Client, DATEDIFF(CURRENT_DATE, l.Date_Loan) AS Plazo, l.Amount AS Monto, " +
                "ROUND((l.Amount * DATEDIFF(CURRENT_DATE, l.Date_Loan) * ?) / ?, 2) AS Interes, " +
                "ROUND((ROUND((l.Amount * DATEDIFF(CURRENT_DATE, l.Date_Loan) * ?) / ?, 2) * (s.IVA / 100)), 2) AS Iva, " +
                "(l.Amount + ROUND((l.Amount * DATEDIFF(CURRENT_DATE, l.Date_Loan) * ?) / ?, 2) + " +
                "ROUND((ROUND((l.Amount * DATEDIFF(CURRENT_DATE, l.Date_Loan) * ?) / ?, 2) * (s.IVA / 100)), 2)) AS Pago " +
                "FROM loans l " +
                "JOIN Accounts a ON l.Client = a.Client " +
                "JOIN Sucursales s ON l.IdSucursal = s.ID " +
                "WHERE l.Status = 'Pagado' AND a.Status = 'Activa'";


		// Obtener los pagos
		List<Map<String, Object>> pagos = jdbcTemplate.queryForList(pagosSql, cobroRequest.getFechaActual(),
				cobroRequest.getFechaActual(), cobroRequest.getTasaInteres(), cobroRequest.getDiasAnioComercial(),
				cobroRequest.getFechaActual(), cobroRequest.getTasaInteres(), cobroRequest.getDiasAnioComercial(),
				cobroRequest.getFechaActual(), cobroRequest.getTasaInteres(), cobroRequest.getDiasAnioComercial());

		// Consulta para obtener las cuentas
		String cuentasSql = "SELECT Client, Amount FROM Accounts WHERE Status = 'Activa'";
		List<Map<String, Object>> cuentas = jdbcTemplate.queryForList(cuentasSql);

		// Crear la respuesta
		Map<String, Object> response = new HashMap<>();
		response.put("Pagos", pagos);
		response.put("Cuentas", cuentas);
		return response;
	}
}
