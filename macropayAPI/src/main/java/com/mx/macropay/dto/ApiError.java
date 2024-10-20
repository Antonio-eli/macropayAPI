package com.mx.macropay.dto;

import java.io.Serializable;
import java.time.LocalDateTime;

import lombok.Data;

@Data
public class ApiError implements Serializable {
	private static final long serialVersionUID = 1L;
	private String backendMessage;
	private String message;
	private String url;
	private String method;
	private LocalDateTime timestamp;

}
