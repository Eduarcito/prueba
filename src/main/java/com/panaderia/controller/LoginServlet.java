package com.panaderia.controller;

import com.panaderia.dao.UsuarioDAO;
import com.panaderia.model.Usuario;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet{
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario user = usuarioDAO.validarCredenciales(username, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("usuario", user);

            switch (user.getRol()) {
                case "Administrador":
                    response.sendRedirect("admin/dashboard.jsp");
                    break;
                case "Panadero":
                    response.sendRedirect("panadero/produccion.jsp");
                    break;
                case "Empleado":
                    response.sendRedirect("ventas/ventas.jsp");
                    break;
                default:
                    response.sendRedirect("login.jsp?error=rol_no_valido");
                    break;
            }
        } else {
            response.sendRedirect("login.jsp?error=credenciales");
        }
    }
}
