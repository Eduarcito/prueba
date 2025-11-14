package com.panaderia.util;
import java.sql.Connection;
import java.sql.DriverManager;

public class ConexionDB {
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=panaderia;encrypt=true;trustServerCertificate=true;";
    private static final String USER = "sqlUser";
    private static final String PASS = "hola123*";

    public static Connection getConnection() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}