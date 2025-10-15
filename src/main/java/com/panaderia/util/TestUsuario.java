package com.panaderia.util;

import com.panaderia.dao.UsuarioDAO;
import com.panaderia.model.Usuario;

public class TestUsuario {
    public static void main(String[] args) {
        UsuarioDAO dao = new UsuarioDAO();

        Usuario u = new Usuario();
        u.setNombre("Admin");
        u.setApellido("Prueba");
        u.setUsername("admin.prueba");
        u.setRol("Administrador");
        u.setTelefono("12345678");
        u.setDireccion("Tienda Central");
        u.setActivo(true);

        String password = "Admin1234";

        try {
            // Registramos como usuario con credenciales temporales
            int id = dao.registrarUsuario(u, password, true);
            if(id != -1){
                System.out.println("✅ Usuario creado con ID: " + id);
            } else {
                System.out.println("❌ No se pudo crear el usuario");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
