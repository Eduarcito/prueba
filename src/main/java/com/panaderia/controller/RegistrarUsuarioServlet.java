package com.panaderia.controller;

import com.panaderia.dao.UsuarioDAO;
import com.panaderia.model.Usuario;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/RegistrarUsuarioServlet")
public class RegistrarUsuarioServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Datos del formulario
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");
        String rol = request.getParameter("rol");

        // Generar credenciales temporales
        String username = nombre.toLowerCase() + "." + apellido.toLowerCase() + (int)(Math.random() * 9000 + 1000);
        String password = "user" + (int)(Math.random() * 9000 + 1000);

        // Crear objeto usuario
        Usuario nuevoUsuario = new Usuario();
        nuevoUsuario.setNombre(nombre);
        nuevoUsuario.setApellido(apellido);
        nuevoUsuario.setUsername(username);
        nuevoUsuario.setRol(rol);
        nuevoUsuario.setTelefono(telefono);
        nuevoUsuario.setDireccion(direccion);
        nuevoUsuario.setActivo(true);

        UsuarioDAO usuarioDAO = new UsuarioDAO();

        try {
            // Registrar usuario temporal
            int idUsuario = usuarioDAO.registrarUsuario(nuevoUsuario, password, true);
            if (idUsuario == -1) {
                request.setAttribute("error", "No se pudo registrar el usuario. Puede que ya exista.");
            } else {
                request.setAttribute("nuevoUsuario", username);
                request.setAttribute("nuevaClave", password);
            }

            // 👇 Cambiamos el destino para quedarnos en agregar.jsp
            request.getRequestDispatcher("admin/agregar.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al registrar el usuario: " + e.getMessage());
            request.getRequestDispatcher("admin/agregar.jsp").forward(request, response);
        }
    }
}
