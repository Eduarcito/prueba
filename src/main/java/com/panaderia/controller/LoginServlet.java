package com.panaderia.controller;

import com.panaderia.dao.UsuarioDAO;
import com.panaderia.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        UsuarioDAO dao = new UsuarioDAO();

        try {
            Usuario user = dao.validarLogin(username, password);

            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("usuario", user);

                // Si el usuario tiene credenciales temporales, obligar a cambiarlas
                if (user.isUsernameTemporal() || user.isPasswordTemporal()) {
                    response.sendRedirect(request.getContextPath() + "/cambiarCredenciales.jsp");
                    return;
                }

                // Redirigir según rol
                switch (user.getRol()) {
                    case "Administrador":
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
                        break;
                    case "Panadero":
                        response.sendRedirect(request.getContextPath() + "/panadero/produccion.jsp");
                        break;
                    case "Empleado":
                        response.sendRedirect(request.getContextPath() + "/ventas/ventas.jsp");
                        break;
                    default:
                        response.sendRedirect(request.getContextPath() + "/login.jsp");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
        }
    }
}
