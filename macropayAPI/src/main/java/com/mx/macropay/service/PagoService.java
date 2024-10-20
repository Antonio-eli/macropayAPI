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
        // Llama al procedimiento almacenado
        String sqlCall = "{CALL CobroAutomatico(?, ?, ?)}";
        jdbcTemplate.update(sqlCall, cobroRequest.getFechaActual(), cobroRequest.getTasaInteres(), cobroRequest.getDiasAnioComercial());

        // Recuperar los registros de resultados
        List<Map<String, Object>> resultados = jdbcTemplate.queryForList(
            "SELECT * FROM Resultados"
        );

        // Recuperar las cuentas activas
        List<Map<String, Object>> cuentas = jdbcTemplate.queryForList(
            "SELECT a.Client AS Cliente, a.Amount AS Monto " +
            "FROM Accounts a " +
            "WHERE a.Status = 'Activa'"
        );

        // Crear la respuesta
        Map<String, Object> response = new HashMap<>();
        response.put("Pagos", resultados);
        response.put("Cuentas", cuentas);

        return response;
    }
}
