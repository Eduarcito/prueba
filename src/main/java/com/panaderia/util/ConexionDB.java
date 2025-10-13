package com.panaderia.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {

    // --- ⚠️ CONFIGURACIÓN CRÍTICA DE LA CONEXIÓN ---
    // ¡DEBES AJUSTAR ESTOS VALORES!
    private static final String JDBC_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    
    // URL de la base de datos SQL Server (Asumimos localhost:1433, base de datos 'PanaderiaDB')
    // trustServerCertificate=true es necesario si no has configurado un certificado SSL.
    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=panaderia;trustServerCertificate=true;";
    
    private static final String USER = "sa"; // Ej. sa
    private static final String PASS = "TuContraseñaFuerte123"; // Contraseña del usuario SQL
    // ----------------------------------------------------

    /**
     * Establece y retorna una nueva conexión a la base de datos.
     * * @return Objeto Connection o null si la conexión falla.
     */
    public static Connection conectar() {
        Connection conn = null;
        try {
            // 1. Cargar el driver JDBC (Ya no es estrictamente necesario en Java moderno, pero es una buena práctica)
            Class.forName(JDBC_DRIVER);

            // 2. Establecer la conexión usando los parámetros definidos
            conn = DriverManager.getConnection(DB_URL, USER, PASS);
            // System.out.println("Conexión exitosa a la base de datos."); // Útil para pruebas

        } catch (ClassNotFoundException e) {
            System.err.println("Error: No se encontró el driver JDBC. ¿Está la dependencia en pom.xml?");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Error al conectar a la base de datos.");
            System.err.println("Verifica la URL, el puerto (1433), el nombre de la DB y las credenciales.");
            e.printStackTrace();
        }
        return conn;
    }

    /**
     * Cierra de manera segura el objeto Connection.
     * * @param conn La conexión a cerrar.
     */
    public static void cerrar(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("Error al cerrar la conexión: " + e.getMessage());
            }
        }
    }
}