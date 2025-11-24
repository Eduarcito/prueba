package com.panaderia.dao;

import com.panaderia.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VentaDAO {

    public List<Map<String,Object>> listarVentasPorFecha(String fechaISO) throws SQLException {
        List<Map<String,Object>> lista = new ArrayList<>();

        String sql = "SELECT v.id_venta, v.id_cajero, p.nombre AS producto, d.cantidad, d.subtotal_linea, " +
                     "CONVERT(varchar(10), v.fecha_hora, 23) AS fecha " +
                     "FROM Ventas v " +
                     "INNER JOIN DetalleVenta d ON d.id_venta = v.id_venta " +
                     "INNER JOIN Productos p ON p.id_producto = d.id_producto ";

        if (fechaISO != null && !fechaISO.isEmpty()) {
            sql += "WHERE CONVERT(date, v.fecha_hora) = ? ";
        }

        sql += "ORDER BY v.fecha_hora DESC, v.id_venta DESC, d.id_detalle";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (fechaISO != null && !fechaISO.isEmpty()) {
                ps.setDate(1, Date.valueOf(fechaISO));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("idventas", rs.getInt("id_venta"));
                    m.put("cajero", rs.getInt("id_cajero"));
                    m.put("producto", rs.getString("producto"));
                    m.put("cantidad", rs.getInt("cantidad"));
                    m.put("total", rs.getBigDecimal("subtotal_linea").doubleValue());
                    m.put("fecha", rs.getString("fecha"));
                    lista.add(m);
                }
            }
        }
        return lista;
    }
}
