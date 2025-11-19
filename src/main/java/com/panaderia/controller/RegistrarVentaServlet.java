package com.panaderia.controller;

import com.panaderia.util.ConexionDB;
import com.panaderia.model.Usuario;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import com.microsoft.sqlserver.jdbc.SQLServerDataTable;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/RegistrarVentaServlet")
public class RegistrarVentaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");

        // Leer JSON del frontend
        BufferedReader reader = request.getReader();
        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> data = mapper.readValue(reader, Map.class);

        String tipoPago = (String) data.get("tipo_pago");
        List<Map<String, Object>> detalle = (List<Map<String, Object>>) data.get("detalle");

        Usuario cajero = (Usuario) request.getSession().getAttribute("usuario");
        if (cajero == null) {
            response.getWriter().write("{\"exito\":false, \"mensaje\":\"Sesión expirada\"}");
            return;
        }

        try (Connection conn = ConexionDB.getConnection()) {

            // Crear TVP (MS SQL Server)
            SQLServerDataTable tvp = new SQLServerDataTable();
            tvp.addColumnMetadata("id_producto", Types.INTEGER);
            tvp.addColumnMetadata("cantidad", Types.INTEGER);
            tvp.addColumnMetadata("precio_unitario", Types.DECIMAL);
            tvp.addColumnMetadata("subtotal_linea", Types.DECIMAL);

            for (Map<String, Object> item : detalle) {
                tvp.addRow(
                    (int)item.get("id_producto"),
                    (int)item.get("cantidad"),
                    new BigDecimal(item.get("precio_unitario").toString()),
                    new BigDecimal(item.get("subtotal_linea").toString())
                );
            }

            CallableStatement cs = conn.prepareCall("{call sp_RegistrarVenta(?,?,?)}");

            cs.setString(1, tipoPago);
            cs.setInt(2, cajero.getId()); 
            cs.setObject(3, tvp);  

            ResultSet rs = cs.executeQuery();

            int idVenta = 0;
            if (rs.next()) {
                idVenta = rs.getInt("idVentaGenerado");
            }

            response.getWriter().write("{\"exito\":true, \"idVenta\": " + idVenta + "}");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"exito\":false, \"mensaje\":\"" + e.getMessage() + "\"}");
        }
    }
}
