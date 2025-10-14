package com.panaderia.controller;

import java.io.IOException;
import com.panaderia.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Credenciales de prueba (solo desarrollo)
    private static final String ADMIN_USER = "eduardo";
    private static final String ADMIN_PASS = "01302005";

    private static final String PANADERO_USER = "chavarria";
    private static final String PANADERO_PASS = "chaper";

    private static final String EMPLEADO_USER = "kc";
    private static final String EMPLEADO_PASS = "polluela";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        HttpSession session = request.getSession(true);
        Usuario user = null;

        // Administrador
        if (ADMIN_USER.equals(username) && ADMIN_PASS.equals(password)) {
            user = new Usuario();
            user.setNombre("Administrador de prueba");
            user.setUsername(username);
            user.setRol("Administrador");
            user.setActivo(true);
        }

        // Panadero
        else if (PANADERO_USER.equals(username) && PANADERO_PASS.equals(password)) {
            user = new Usuario();
            user.setNombre("Panadero de prueba");
            user.setUsername(username);
            user.setRol("Panadero");
            user.setActivo(true);
        }

        // Empleado
        else if (EMPLEADO_USER.equals(username) && EMPLEADO_PASS.equals(password)) {
            user = new Usuario();
            user.setNombre("Empleado de prueba");
            user.setUsername(username);
            user.setRol("Empleado");
            user.setActivo(true);
        }

        // Credenciales correctas: guardar en sesión y redirigir al dashboard según rol
        if (user != null) {
            session.setAttribute("usuario", user);

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
            return;
        }

        // Credenciales incorrectas
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
    }
}
