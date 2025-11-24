package com.panaderia.dao;

import com.panaderia.model.ProduccionItem;
import com.panaderia.util.ConexionDB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

public class ProduccionDAO {

    private static final String INSERT_SQL = "INSERT INTO Produccion (id_producto, cantidad_producida, fecha) VALUES (?, ?, GETDATE())";

    public boolean registrarProduccion(List<ProduccionItem> items) {

        try (Connection conn = ConexionDB.getConnection()) {

            conn.setAutoCommit(false);
            PreparedStatement stmt = conn.prepareStatement(INSERT_SQL);

            for (ProduccionItem item : items) {
                stmt.setInt(1, item.getIdProducto());
                stmt.setInt(2, item.getCantidad());
                stmt.addBatch();
            }

            stmt.executeBatch();
            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<java.util.Map<String, Object>> listarProduccionPorFecha(String fecha, int idPanadero) {
        List<java.util.Map<String, Object>> lista = new java.util.ArrayList<>();

        String sql = "SELECT p.id_produccion, pr.nombre as producto, p.cantidad_producida, p.fecha, u.nombre as panadero "
                +
                "FROM Produccion p " +
                "JOIN Productos pr ON p.id_producto = pr.id_producto " +
                "JOIN Usuarios u ON p.id_panadero = u.id_usuario " +
                "WHERE p.id_panadero = ? ";

        if (fecha != null && !fecha.isEmpty()) {
            sql += "AND CONVERT(DATE, p.fecha) = ? ";
        }

        sql += "ORDER BY p.fecha DESC";

        try (Connection conn = ConexionDB.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            System.out.println("ProduccionDAO: Executing query for idPanadero=" + idPanadero + ", fecha=" + fecha);
            ps.setInt(1, idPanadero);

            if (fecha != null && !fecha.isEmpty()) {
                ps.setString(2, fecha);
            }

            try (java.sql.ResultSet rs = ps.executeQuery()) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("id_produccion", rs.getInt("id_produccion"));
                    map.put("producto", rs.getString("producto"));
                    map.put("cantidad", rs.getInt("cantidad_producida"));

                    java.sql.Timestamp ts = rs.getTimestamp("fecha");
                    map.put("fecha", (ts != null) ? sdf.format(ts) : "");

                    map.put("panadero", rs.getString("panadero"));
                    lista.add(map);
                }
            }
            System.out.println(
                    "ProduccionDAO: Found " + lista.size() + " records for baker " + idPanadero + " on date " + fecha);
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("ProduccionDAO Error: " + e.getMessage());
        }
        return lista;
    }
}
