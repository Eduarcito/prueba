package com.panaderia.controller;

import com.panaderia.dao.UsuarioDAO;
import com.panaderia.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/actualizarCredenciales")
public class ActualizarCredencialesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String nuevoUsername = request.getParameter("nuevoUsername").trim();
        String nuevaContrasena = request.getParameter("nuevaContrasena").trim();

        if (nuevoUsername.isEmpty() || nuevaContrasena.isEmpty()) {
            response.sendRedirect("cambiarCredenciales.jsp?error=1");
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();
        try {
            boolean actualizado = dao.actualizarCredenciales(usuario.getId(), nuevoUsername, nuevaContrasena);
            if (actualizado) {
                // Actualiza la sesión con el nuevo username y marca como no temporal
                usuario.setUsername(nuevoUsername);
                usuario.setUsernameTemporal(false);
                usuario.setPasswordTemporal(false);
                session.setAttribute("usuario", usuario);

                // Redirige al dashboard según rol
                switch (usuario.getRol()) {
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
                        response.sendRedirect("login.jsp");
                }
            } else {
                response.sendRedirect("cambiarCredenciales.jsp?error=1");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cambiarCredenciales.jsp?error=1");
        }
    }
}
