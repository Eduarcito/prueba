package com.panaderia.controller;

import com.panaderia.model.Usuario;
import com.panaderia.util.ConexionDB;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/ProduccionServlet")
public class ProduccionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        JSONObject resp = new JSONObject();
        try {
            Usuario user = (Usuario) request.getSession().getAttribute("usuario");

            if (user == null || !"Panadero".equals(user.getRol())) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.put("success", false);
                resp.put("error", "No autorizado o sesión expirada");
                out.print(resp);
                return;
            }

            // Leer JSON
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) sb.append(line);
            }

            if (sb.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.put("success", false);
                resp.put("error", "No se recibió JSON");
                out.print(resp);
                return;
            }

            JSONArray produccionArray = new JSONArray(sb.toString());

            if (produccionArray.length() == 0) {
                resp.put("success", false);
                resp.put("error", "No hay productos para registrar");
                out.print(resp);
                return;
            }

            // Insertar producción en BD
            String insertSQL = "INSERT INTO Produccion (cantidad_producida, id_panadero, id_producto) VALUES (?, ?, ?)";

            try (Connection conn = ConexionDB.getConnection();
                 PreparedStatement ps = conn.prepareStatement(insertSQL)) {

                for (int i = 0; i < produccionArray.length(); i++) {
                    JSONObject obj = produccionArray.getJSONObject(i);
                    int cantidad = Math.max(1, obj.getInt("cantidad")); // mínimo 1
                    ps.setInt(1, cantidad);
                    ps.setInt(2, user.getId());
                    ps.setInt(3, obj.getInt("idProducto"));
                    ps.addBatch();
                }

                ps.executeBatch();

                // Obtener stock actualizado
                JSONArray stockArray = new JSONArray();
                StringBuilder ids = new StringBuilder();
                for (int i = 0; i < produccionArray.length(); i++) {
                    if (i > 0) ids.append(",");
                    ids.append(produccionArray.getJSONObject(i).getInt("idProducto"));
                }

                String stockSQL = "SELECT id_producto, stock_actual FROM Productos WHERE id_producto IN (" + ids + ")";
                try (PreparedStatement psStock = conn.prepareStatement(stockSQL);
                     ResultSet rs = psStock.executeQuery()) {
                    while (rs.next()) {
                        JSONObject prodStock = new JSONObject();
                        prodStock.put("idProducto", rs.getInt("id_producto"));
                        prodStock.put("stock_actual", rs.getInt("stock_actual"));
                        stockArray.put(prodStock);
                    }
                }

                resp.put("success", true);
                resp.put("message", "Producción registrada correctamente");
                resp.put("stockActualizado", stockArray);
                out.print(resp);

            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.put("success", false);
                resp.put("error", "Error al registrar la producción: " + e.getMessage());
                out.print(resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.put("success", false);
            resp.put("error", "Error inesperado: " + e.getMessage());
            out.print(resp);
        }
    }
}
