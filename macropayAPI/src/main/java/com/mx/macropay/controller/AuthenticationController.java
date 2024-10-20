package com.mx.macropay.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.mx.macropay.dto.auth.AuthenticationRequest;
import com.mx.macropay.dto.auth.AuthenticationResponse;
import com.mx.macropay.service.auth.AuthenticationService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/auth")
public class AuthenticationController {

	@Autowired
	private AuthenticationService authenticationService;

	@PostMapping("/authenticate")
	public ResponseEntity<AuthenticationResponse> authenticate(
			@RequestBody @Valid AuthenticationRequest authenticationRequest) {

		AuthenticationResponse rsp = authenticationService.login(authenticationRequest);
		return ResponseEntity.ok(rsp);

	}

}
