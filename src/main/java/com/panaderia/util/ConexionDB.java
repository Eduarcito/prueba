package com.panaderia.util;

import java.sql.Connection;
import java.sql.DriverManager;
public class ConexionDB {
    String url="jdbc:sqlserver:GERARDO\\SQLEXPRESS:1433;databaseName=panaderia;IntegratedSecurity=true;";
    //String url="jdbc:mysql://localhost:3306/ejemplobd";
    Connection con;
    public Connection getConnection(){
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            //Class.forName("com.mysql.cj.jdbc.Driver");
            con=DriverManager.getConnection(url);
            //con=DriverManager.getConnection(url,"root","root");
        } catch (Exception e) {  
            System.out.println("Error: " + e.getMessage());
        }
        return con;
    }
}