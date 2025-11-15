package com.panaderia.controller;

import com.panaderia.model.Usuario;
import com.panaderia.util.ConexionDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import org.json.*;

@WebServlet("/ProduccionServlet")
public class ProduccionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        HttpSession session = request.getSession();
        Usuario user = (Usuario) session.getAttribute("usuario");

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\":false,\"error\":\"Usuario no logueado\"}");
            return;
        }

        int idPanadero = user.getId();

        // Leer JSON
        String body = request.getReader().lines()
                .reduce("", (accumulator, actual) -> accumulator + actual);

        JSONArray items;
        try {
            items = new JSONArray(body);
        } catch (JSONException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"error\":\"JSON inválido\"}");
            return;
        }

        if (items.length() == 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"error\":\"No se enviaron productos\"}");
            return;
        }

        String sql = "INSERT INTO Produccion (cantidad_producida, id_panadero, id_producto) VALUES (?, ?, ?)";

        try (Connection conn = ConexionDB.getConnection()) {

            if (conn == null) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\":false,\"error\":\"Fallo al conectar con la base de datos\"}");
                return;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < items.length(); i++) {
                    JSONObject item = items.getJSONObject(i);
                    int cantidad = item.getInt("cantidad");
                    int idProducto = item.getInt("idProducto");

                    ps.setInt(1, cantidad);
                    ps.setInt(2, idPanadero);
                    ps.setInt(3, idProducto);
                    ps.addBatch();
                }

                ps.executeBatch();
                response.getWriter().write("{\"success\":true,\"message\":\"Producción registrada correctamente\"}");

            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"error\":\"Error inesperado: " + e.getMessage() + "\"}");
        }
    }
}
