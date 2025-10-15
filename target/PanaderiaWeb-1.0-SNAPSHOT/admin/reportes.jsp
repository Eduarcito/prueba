<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.panaderia.model.Usuario" %>

<%
    Usuario user = (Usuario) session.getAttribute("usuario");
    if (user == null || !"Administrador".equals(user.getRol())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String url = "jdbc:sqlserver://localhost:1433;databaseName=Panaderia;encrypt=false;";
    String usuarioDB = "sa";
    String claveDB = "TuContraseñaFuerte123";
    Connection con = null;
    Statement st = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Reportes - Panadería USO</title>
<link rel="stylesheet" href="../css/estilos.css">
<style>
table { width:100%; border-collapse:collapse; margin:20px 0; font-size:0.9rem; }
th, td { border:1px solid #ddd; padding:8px; }
th { background:#4CAF50; color:white; }
h2 { background:#f0f0f0; padding:10px; }
</style>
</head>
<body>

<nav class="navbar">
    <img src="../img/logo.png" alt="Logo" class="logo">
    <ul>
        <li><a href="dashboard.jsp">Dashboard</a></li>
        <li><a href="usuarios.jsp">Usuarios</a></li>
        <li><a href="reportes.jsp" class="active">Reportes</a></li>
    </ul>
</nav>

<main class="admin-content">
<h1>📊 Reportes Generales</h1>

<%
try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, usuarioDB, claveDB);
    st = con.createStatement();

    // USUARIOS
    out.println("<h2>Usuarios</h2>");
    rs = st.executeQuery("SELECT id_usuario, nombre, username, rol, activo FROM Usuarios");
    out.println("<table><tr><th>ID</th><th>Nombre</th><th>Username</th><th>Rol</th><th>Activo</th></tr>");
    while(rs.next()){
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id_usuario") + "</td>");
        out.println("<td>" + rs.getString("nombre") + "</td>");
        out.println("<td>" + rs.getString("username") + "</td>");
        out.println("<td>" + rs.getString("rol") + "</td>");
        out.println("<td>" + (rs.getBoolean("activo") ? "Sí" : "No") + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");

    // PRODUCTOS
    out.println("<h2>Productos</h2>");
    rs = st.executeQuery("SELECT * FROM Productos");
    ResultSetMetaData metaProd = rs.getMetaData();
    int colsProd = metaProd.getColumnCount();
    out.println("<table><tr>");
    for(int i=1;i<=colsProd;i++) out.println("<th>" + metaProd.getColumnName(i) + "</th>");
    out.println("</tr>");
    while(rs.next()){
        out.println("<tr>");
        for(int i=1;i<=colsProd;i++) out.println("<td>" + rs.getString(i) + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");

    // PRODUCCION
    out.println("<h2>Producción</h2>");
    rs = st.executeQuery("SELECT * FROM Produccion");
    ResultSetMetaData metaProd2 = rs.getMetaData();
    int colsProd2 = metaProd2.getColumnCount();
    out.println("<table><tr>");
    for(int i=1;i<=colsProd2;i++) out.println("<th>" + metaProd2.getColumnName(i) + "</th>");
    out.println("</tr>");
    while(rs.next()){
        out.println("<tr>");
        for(int i=1;i<=colsProd2;i++) out.println("<td>" + rs.getString(i) + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");

    // VENTAS
    out.println("<h2>Ventas</h2>");
    rs = st.executeQuery("SELECT * FROM Ventas");
    ResultSetMetaData metaVentas = rs.getMetaData();
    int colsVentas = metaVentas.getColumnCount();
    out.println("<table><tr>");
    for(int i=1;i<=colsVentas;i++) out.println("<th>" + metaVentas.getColumnName(i) + "</th>");
    out.println("</tr>");
    while(rs.next()){
        out.println("<tr>");
        for(int i=1;i<=colsVentas;i++) out.println("<td>" + rs.getString(i) + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");

    // DETALLEVENTA
    out.println("<h2>Detalle de Ventas</h2>");
    rs = st.executeQuery("SELECT * FROM DetalleVenta");
    ResultSetMetaData metaDet = rs.getMetaData();
    int colsDet = metaDet.getColumnCount();
    out.println("<table><tr>");
    for(int i=1;i<=colsDet;i++) out.println("<th>" + metaDet.getColumnName(i) + "</th>");
    out.println("</tr>");
    while(rs.next()){
        out.println("<tr>");
        for(int i=1;i<=colsDet;i++) out.println("<td>" + rs.getString(i) + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");

} catch(Exception e){
    out.println("<p style='color:red;'>Error al cargar los datos: " + e.getMessage() + "</p>");
} finally {
    try{ if(rs!=null) rs.close(); if(st!=null) st.close(); if(con!=null) con.close(); } catch(Exception ex){}
}
%>

</main>
<footer class="footer">
<p>Panadería USO</p>
</footer>

</body>
</html>
