package com.mx.macropay.service;

import java.util.Optional;

import com.mx.macropay.dto.SaveUser;
import com.mx.macropay.persistence.entity.User;

public interface UserService {
	User registrOneCustomer(SaveUser newUser);

	Optional<User> findOneByUsername(String username);
}
