package com.mx.macropay.dto.auth;

import java.io.Serializable;

import lombok.Data;

@Data
public class AuthenticationRequest implements Serializable {
	private static final long serialVersionUID = 1L;
	private String username;
	private String password;
}
