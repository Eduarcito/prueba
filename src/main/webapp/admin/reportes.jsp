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
<link rel="stylesheet" href="../css/reportes.css">
<link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<aside class="sidebar">
    <div class="logo">
        <img src="../img/logo.png" alt="Logo Panadería USO">
    </div>

    <nav class="menu">
        <a href="dashboard.jsp"><i class="fas fa-chart-line"></i> Panel</a>
        <a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a>
        <a class="active" href="reportes.jsp"><i class="fas fa-file-alt"></i> Reportes</a>
    </nav>

    <div class="logout">
        <a href="../login.jsp"><i class="fas fa-sign-out-alt"></i> Salir</a>
    </div>
</aside>

<main class="admin-content">
<h1>📊 Reportes Generales</h1>

<%
try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, usuarioDB, claveDB);
    st = con.createStatement();

    // ====================== USUARIOS ======================
    out.println("<h2>Usuarios</h2>");
    rs = st.executeQuery("SELECT id_usuario, nombre, username, rol, activo FROM Usuarios");
    out.println("<table class='vision-table'><thead><tr><th>ID</th><th>Nombre</th><th>Username</th><th>Rol</th><th>Activo</th></tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id_usuario") + "</td>");
        out.println("<td>" + rs.getString("nombre") + "</td>");
        out.println("<td>" + rs.getString("username") + "</td>");
        out.println("<td>" + rs.getString("rol") + "</td>");
        out.println("<td>" + (rs.getBoolean("activo") ? "<span class='badge online'>Sí</span>" : "<span class='badge offline'>No</span>") + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

    // ====================== PRODUCTOS ======================
    out.println("<h2>Productos</h2>");
    rs = st.executeQuery("SELECT * FROM Productos");
    ResultSetMetaData metaProd = rs.getMetaData();
    int colsProd = metaProd.getColumnCount();
    out.println("<table class='vision-table'><thead><tr>");
    for(int i=1;i<=colsProd;i++) out.println("<th>" + metaProd.getColumnName(i) + "</th>");
    out.println("</tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        for(int i=1;i<=colsProd;i++) out.println("<td>" + rs.getString(i) + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

    // ====================== PRODUCCIÓN ======================
    out.println("<h2>Producción</h2>");
    rs = st.executeQuery("SELECT * FROM Produccion");
    ResultSetMetaData metaProd2 = rs.getMetaData();
    int colsProd2 = metaProd2.getColumnCount();
    out.println("<table class='vision-table'><thead><tr>");
    for(int i=1;i<=colsProd2;i++) out.println("<th>" + metaProd2.getColumnName(i) + "</th>");
    out.println("</tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        for(int i=1;i<=colsProd2;i++) out.println("<td>" + rs.getString(i) + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

    // ====================== VENTAS ======================
    out.println("<h2>Ventas</h2>");
    rs = st.executeQuery("SELECT * FROM Ventas");
    ResultSetMetaData metaVentas = rs.getMetaData();
    int colsVentas = metaVentas.getColumnCount();
    out.println("<table class='vision-table'><thead><tr>");
    for(int i=1;i<=colsVentas;i++) out.println("<th>" + metaVentas.getColumnName(i) + "</th>");
    out.println("</tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        for(int i=1;i<=colsVentas;i++) out.println("<td>" + rs.getString(i) + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

    // ====================== DETALLE VENTA ======================
    out.println("<h2>Detalle de Ventas</h2>");
    rs = st.executeQuery("SELECT * FROM DetalleVenta");
    ResultSetMetaData metaDet = rs.getMetaData();
    int colsDet = metaDet.getColumnCount();
    out.println("<table class='vision-table'><thead><tr>");
    for(int i=1;i<=colsDet;i++) out.println("<th>" + metaDet.getColumnName(i) + "</th>");
    out.println("</tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        for(int i=1;i<=colsDet;i++) out.println("<td>" + rs.getString(i) + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

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
