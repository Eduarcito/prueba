package com.panaderia.controller;

import com.panaderia.dao.UsuarioDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class EliminarUsuarioServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain; charset=UTF-8");

        try {
            String idParam = request.getParameter("id");
            System.out.println("DEBUG: Parámetro recibido id = " + idParam); // log

            int id = Integer.parseInt(idParam);
            UsuarioDAO dao = new UsuarioDAO();

            boolean eliminado = dao.eliminarUsuario(id);
            System.out.println("DEBUG: Resultado de eliminarUsuario = " + eliminado); // log

            if (eliminado) {
                response.getWriter().write("✅ Usuario eliminado correctamente.");
            } else {
                response.getWriter().write("⚠️ No se pudo eliminar el usuario.");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.getWriter().write("❌ ID inválido.");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("❌ Error al eliminar el usuario.");
        }
    }
}
