package com.panaderia.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ExportXLS")
public class ExportXLS extends HttpServlet {
    private static final long serialVersionUID = 1L;

    String url = "jdbc:sqlserver://localhost:1433;databaseName=Panaderia;encrypt=false;";
    String usuarioDB = "sa";
    String claveDB = "TuContraseñaFuerte123";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fecha = request.getParameter("fecha");

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=historial_ventas.csv");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter();
                Connection con = DriverManager.getConnection(url, usuarioDB, claveDB)) {

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // Encabezados CSV
            out.println("ID Venta,Cajero,Producto,Cantidad,Total,Fecha");

            String sql = "SELECT v.id_venta, u.nombre AS cajero, p.nombre AS producto, d.cantidad, d.subtotal_linea, v.fecha_hora "
                    +
                    "FROM Ventas v " +
                    "JOIN Usuarios u ON v.id_usuario = u.id_usuario " +
                    "JOIN DetalleVenta d ON v.id_venta = d.id_venta " +
                    "JOIN Productos p ON d.id_producto = p.id_producto ";

            if (fecha != null && !fecha.isEmpty()) {
                sql += "WHERE CAST(v.fecha_hora AS DATE) = ? ";
            }
            sql += "ORDER BY v.fecha_hora DESC";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                if (fecha != null && !fecha.isEmpty()) {
                    ps.setString(1, fecha);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        out.print(rs.getInt("id_venta") + ",");
                        out.print("\"" + rs.getString("cajero") + "\",");
                        out.print("\"" + rs.getString("producto") + "\",");
                        out.print(rs.getInt("cantidad") + ",");
                        out.print(rs.getDouble("subtotal_linea") + ",");
                        out.println("\"" + rs.getTimestamp("fecha_hora") + "\"");
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
