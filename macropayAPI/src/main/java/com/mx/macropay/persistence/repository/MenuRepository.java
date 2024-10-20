package com.mx.macropay.persistence.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.mx.macropay.persistence.entity.Menu;

@Repository
public interface MenuRepository extends JpaRepository<Menu, Long> {

	// Método para obtener todos los menús sin padres (root menus)
	List<Menu> findByParentIdIsNull();

	// Método para obtener los hijos de un menú específico
	List<Menu> findByParentId(Long parentId);
}
