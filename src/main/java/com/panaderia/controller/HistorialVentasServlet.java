package com.panaderia.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.panaderia.dao.VentaDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/HistorialVentas")
public class HistorialVentasServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        String fecha = req.getParameter("fecha"); // formato yyyy-MM-dd o vacío

        VentaDAO dao = new VentaDAO();
        try {
            List<Map<String,Object>> lista = dao.listarVentasPorFecha(fecha);
            ObjectMapper mapper = new ObjectMapper();
            mapper.writeValue(resp.getWriter(), lista);
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"" + e.getMessage().replace("\"","'") + "\"}");
        }
    }
}
