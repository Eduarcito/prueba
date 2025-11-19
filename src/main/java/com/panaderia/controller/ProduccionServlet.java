package com.panaderia.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.panaderia.model.Usuario;
import com.panaderia.util.ConexionDB;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/ProduccionServlet")
public class ProduccionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json; charset=UTF-8");

        // Obtener usuario panadero desde sesión
        Usuario panadero = (Usuario) request.getSession().getAttribute("usuario");
        if (panadero == null) {
            response.getWriter().write("{\"success\":false, \"error\":\"Sesión expirada\"}");
            return;
        }

        int idPanadero = panadero.getId();

        ObjectMapper mapper = new ObjectMapper();
        List<Map<String, Object>> items;

        try {
            items = mapper.readValue(request.getReader(), List.class);
        } catch (Exception e) {
            response.getWriter().write("{\"success\":false, \"error\":\"JSON inválido\"}");
            return;
        }

        if (items == null || items.isEmpty()) {
            response.getWriter().write("{\"success\":false, \"error\":\"No se enviaron productos\"}");
            return;
        }

        try (Connection conn = ConexionDB.getConnection()) {

            String sql = "INSERT INTO Produccion (id_producto, cantidad_producida, id_panadero, fecha) " +
                         "VALUES (?, ?, ?, GETDATE())";

            PreparedStatement ps = conn.prepareStatement(sql);

            for (Map<String, Object> item : items) {
                ps.setInt(1, (int) item.get("idProducto"));
                ps.setInt(2, (int) item.get("cantidad"));
                ps.setInt(3, idPanadero);
                ps.addBatch();
            }

            ps.executeBatch();

            response.getWriter().write(
                "{\"success\":true,\"message\":\"Producción registrada correctamente\"}"
            );

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write(
                "{\"success\":false,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}"
            );
        }
    }
}
