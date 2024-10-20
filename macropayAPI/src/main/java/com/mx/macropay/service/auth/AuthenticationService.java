package com.mx.macropay.service.auth;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import com.mx.macropay.dto.auth.AuthenticationRequest;
import com.mx.macropay.dto.auth.AuthenticationResponse;
import com.mx.macropay.persistence.entity.User;
import com.mx.macropay.service.UserService;

@Service
public class AuthenticationService {

	@Autowired
	private UserService userService;

	@Autowired
	private JwtService jwtService;

	@Autowired
	private AuthenticationManager authenticationManager;

	private Map<String, Object> generateExtraClaims(User user) {
		Map<String, Object> extraClaims = new HashMap<>();
		extraClaims.put("name", user.getName());
		extraClaims.put("role", user.getRole().name());
		extraClaims.put("authorities", user.getAuthorities());

		return extraClaims;
	}

	public AuthenticationResponse login(AuthenticationRequest autRequest) {

		Authentication authentication = new UsernamePasswordAuthenticationToken(autRequest.getUsername(),
				autRequest.getPassword());

		authenticationManager.authenticate(authentication);

		UserDetails user = userService.findOneByUsername(autRequest.getUsername()).get();
		String jwt = jwtService.generateToken(user, generateExtraClaims((User) user));
		
		System.out.println(user.toString());
		System.out.println(jwt.toString());

		AuthenticationResponse authRsp = new AuthenticationResponse();
		System.out.println(authRsp.toString());
		authRsp.setJwt(jwt);

		return authRsp;
	}

	public boolean validateToken(String jwt) {

		try {
			jwtService.extractUsername(jwt);
			return true;
		} catch (Exception e) {
			System.out.println(e.getMessage());
			return false;
		}

	}
}
