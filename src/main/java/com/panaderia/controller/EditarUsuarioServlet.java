package com.panaderia.controller;

import com.panaderia.dao.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/EditarUsuarioServlet")
public class EditarUsuarioServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private UsuarioDAO dao;

    @Override
    public void init() throws ServletException {
        super.init();
        dao = new UsuarioDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener parámetros del formulario
        int id = Integer.parseInt(request.getParameter("id"));
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String telefono = request.getParameter("telefono");
        String rol = request.getParameter("rol");

        try {
            // Llamamos al método del DAO para editar usuario
            boolean exito = dao.editarUsuario(id, nombre, apellido, telefono, rol);

            if (exito) {
                // Redirige de vuelta a usuarios.jsp dentro de /admin
                response.sendRedirect(request.getContextPath() + "/admin/usuarios.jsp");
            } else {
                // Error al actualizar
                request.setAttribute("error", "No se pudo actualizar el usuario.");
                request.getRequestDispatcher("/admin/usuarios.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al actualizar usuario: " + e.getMessage());
            request.getRequestDispatcher("/admin/usuarios.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirige GET al JSP correcto en /admin
        response.sendRedirect(request.getContextPath() + "/admin/usuarios.jsp");
    }
}
