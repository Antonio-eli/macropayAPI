package com.mx.macropay.service.impl;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.mx.macropay.dto.SaveUser;
import com.mx.macropay.exception.InvalidPasswordException;
import com.mx.macropay.persistence.entity.User;
import com.mx.macropay.persistence.repository.UserRepository;
import com.mx.macropay.persistence.util.Role;
import com.mx.macropay.service.UserService;

@Service
public class UserServiceImpl implements UserService {

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private PasswordEncoder passwordEncoder;

	@Override
	public User registrOneCustomer(SaveUser newUser) {
		validatePassword(newUser);

		User user = new User();
		user.setPassword(passwordEncoder.encode(newUser.getPassword()));
		user.setUsername(newUser.getUsername());
		user.setName(newUser.getName());
		user.setRole(Role.ROLE_CUSTOMER);

		return userRepository.save(user);
	}

	@Override
	public Optional<User> findOneByUsername(String username) {
		return userRepository.findByUsername(username);
	}

	private void validatePassword(SaveUser dto) {

		if (!StringUtils.hasText(dto.getPassword()) || !StringUtils.hasText(dto.getRepeatedPassword())) {
			throw new InvalidPasswordException("Passwords don't match");
		}

		if (!dto.getPassword().equals(dto.getRepeatedPassword())) {
			throw new InvalidPasswordException("Passwords don't match");
		}

	}

}
