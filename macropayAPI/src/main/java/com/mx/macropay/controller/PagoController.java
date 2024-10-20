package com.mx.macropay.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mx.macropay.dto.CobroRequest;
import com.mx.macropay.service.PagoService;

@RestController
@RequestMapping("/pagos")
public class PagoController {

    @Autowired
    private PagoService pagoService;

    @PostMapping("/ejecutar")
    @PreAuthorize("hasRole('ROLE_ADMINISTRATOR')")
    public ResponseEntity<?> ejecutarCobro(@RequestBody CobroRequest cobroRequest) {
        Map<String, Object> response = pagoService.ejecutarCobro(cobroRequest);
        return ResponseEntity.ok(response);
    }
}
