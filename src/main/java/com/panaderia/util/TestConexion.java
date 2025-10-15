package com.panaderia.util;

import java.sql.Connection;

public class TestConexion {
    public static void main(String[] args) {
        try (Connection con = ConexionDB.getConnection()) {
            if (con != null) {
                System.out.println("✅ Conexión exitosa");
            } else {
                System.out.println("❌ Conexión fallida");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
