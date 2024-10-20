package com.mx.macropay.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.mx.macropay.persistence.entity.Menu;
import com.mx.macropay.persistence.repository.MenuRepository;

@Service
public class MenuService {

    @Autowired
    private MenuRepository menuRepository;

    public void guardarMenus(List<Menu> menus) {
        for (Menu menu : menus) {
            guardarMenu(menu, null);
        }
    }

    private void guardarMenu(Menu menu, Long parentId) {
        menu.setParentId(parentId);
        menuRepository.save(menu);
        if (menu.getChildren() != null) {
            for (Menu child : menu.getChildren()) {
                guardarMenu(child, menu.getId());
            }
        }
    }

    public List<Menu> obtenerMenus() {
        return menuRepository.findAll();
    }
}
