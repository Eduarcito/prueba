package com.panaderia.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.panaderia.dao.ProduccionDAO;
import com.panaderia.model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/HistorialProduccion")
public class HistorialProduccionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        String fecha = req.getParameter("fecha"); // formato yyyy-MM-dd o vacío

        // Obtener usuario panadero desde sesión
        Usuario panadero = (Usuario) req.getSession().getAttribute("usuario");
        if (panadero == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\":\"Sesión expirada\"}");
            return;
        }

        ProduccionDAO dao = new ProduccionDAO();
        try {
            System.out.println("HistorialProduccionServlet: Request for date=" + fecha + ", user=" + panadero.getId());
            List<Map<String, Object>> lista = dao.listarProduccionPorFecha(fecha, panadero.getId());
            ObjectMapper mapper = new ObjectMapper();
            mapper.writeValue(resp.getWriter(), lista);
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
