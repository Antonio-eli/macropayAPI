package com.mx.macropay.dto;

import java.math.BigDecimal;

import lombok.Data;

@Data
public class CobroRequest {
	private String fechaActual;
	private BigDecimal tasaInteres;
	private int diasAnioComercial;
}