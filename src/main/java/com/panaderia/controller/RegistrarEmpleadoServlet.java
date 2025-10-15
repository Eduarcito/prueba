package com.panaderia.controller;

import com.panaderia.dao.UsuarioDAO;
import com.panaderia.model.Usuario;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/RegistrarEmpleadoServlet")
public class RegistrarEmpleadoServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");

        // Generamos username y contraseña temporal
        String username = nombre.toLowerCase() + "." + apellido.toLowerCase();
        String password = "emp" + (int)(Math.random() * 9000 + 1000);

        Usuario nuevoUsuario = new Usuario();
        nuevoUsuario.setNombre(nombre);
        nuevoUsuario.setApellido(apellido);
        nuevoUsuario.setUsername(username);
        nuevoUsuario.setRol("Empleado");
        nuevoUsuario.setTelefono(telefono);
        nuevoUsuario.setDireccion(direccion);
        nuevoUsuario.setActivo(true);

        UsuarioDAO usuarioDAO = new UsuarioDAO();

        try {
            // Ahora indicamos que son credenciales temporales (true)
            int idUsuario = usuarioDAO.registrarUsuario(nuevoUsuario, password, true);

            if (idUsuario == -1) {
                response.sendRedirect("admin/usuarios.jsp?error=duplicado");
                return;
            }

            request.setAttribute("nuevoUsuario", username);
            request.setAttribute("nuevaClave", password);
            request.getRequestDispatcher("admin/usuarios.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("admin/usuarios.jsp?error=duplicado");
        }
    }
}
