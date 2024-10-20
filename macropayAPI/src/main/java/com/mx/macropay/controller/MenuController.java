package com.mx.macropay.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mx.macropay.persistence.entity.Menu;
import com.mx.macropay.service.MenuService;

@RestController
@RequestMapping("/api/menu")
public class MenuController {

    @Autowired
    private MenuService menuService;

    @PostMapping("/cargar")
    public ResponseEntity<?> cargarMenuDesdeJson(@RequestBody List<Menu> menus) {
        menuService.guardarMenus(menus);
        return ResponseEntity.ok("Menú cargado exitosamente");
    }

    @GetMapping
    public ResponseEntity<List<Menu>> obtenerMenu() {
        return ResponseEntity.ok(menuService.obtenerMenus());
    }
}
