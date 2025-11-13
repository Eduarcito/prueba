<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.panaderia.model.Usuario" %>
<%
    Usuario user = (Usuario) session.getAttribute("usuario");
    if (user == null || !"Administrador".equals(user.getRol())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String url = "jdbc:sqlserver://DESKTOP-2NOT164\\SQLEXPRESS:1433;databaseName=panaderia;encrypt=false;";
    String usuarioDB = "userDS1";
    String claveDB = "newPassword";

    String fechaFiltro = request.getParameter("fecha");
    if(fechaFiltro == null) fechaFiltro = "";
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
    <div class="main-header">
        <span class="reportes"><i class="fas fa-file-alt"></i> Reportes</span>
        <form class="date-filter" method="get">
            <input type="date" name="fecha" value="<%= fechaFiltro %>">
            <button type="submit"><i class="fas fa-search"></i> Buscar</button>
        </form>
    </div>

<%
Connection con = null;
Statement st = null;
ResultSet rs = null;
try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, usuarioDB, claveDB);
    st = con.createStatement();

    // ====================== USUARIOS ======================
    out.println("<h2>Usuarios</h2>");
    rs = st.executeQuery("SELECT id_usuario, nombre, username AS Usuario, rol, activo FROM Usuarios");
    out.println("<table class='vision-table'><thead><tr><th>ID</th><th>Nombre</th><th>Usuario</th><th>Rol</th><th>Activo</th></tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id_usuario") + "</td>");
        out.println("<td>" + rs.getString("nombre") + "</td>");
        out.println("<td>" + rs.getString("Usuario") + "</td>");
        out.println("<td>" + rs.getString("rol") + "</td>");
        out.println("<td>" + (rs.getBoolean("activo") ? "<span class='badge online'>Sí</span>" : "<span class='badge offline'>No</span>") + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

    // ====================== PRODUCTOS ======================
    out.println("<h2>Productos</h2>");
    rs = st.executeQuery("SELECT id_producto AS ID, nombre AS NOMBRE, precio_unitario AS PRECIO, stock_actual AS STOCK FROM Productos");
    out.println("<table class='vision-table'><thead><tr><th>ID</th><th>NOMBRE</th><th>PRECIO</th><th>STOCK</th></tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        out.println("<td>" + rs.getInt("ID") + "</td>");
        out.println("<td>" + rs.getString("NOMBRE") + "</td>");
        out.println("<td>" + rs.getDouble("PRECIO") + "</td>");
        out.println("<td>" + rs.getInt("STOCK") + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

    // ====================== PRODUCCIÓN ======================
    out.println("<h2>Producción</h2>");
    String prodQuery = "SELECT p.id_produccion, u.nombre AS panadero, pr.nombre AS producto, p.cantidad_producida " +
                       "FROM Produccion p " +
                       "INNER JOIN Usuarios u ON p.id_panadero = u.id_usuario " +
                       "INNER JOIN Productos pr ON p.id_producto = pr.id_producto ";
    if(!fechaFiltro.isEmpty()) prodQuery += "WHERE p.fecha = '" + fechaFiltro + "' ";
    rs = st.executeQuery(prodQuery);
    out.println("<table class='vision-table'><thead><tr><th>ID Producción</th><th>Panadero</th><th>Producto</th><th>Cantidad</th></tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id_produccion") + "</td>");
        out.println("<td>" + rs.getString("panadero") + "</td>");
        out.println("<td>" + rs.getString("producto") + "</td>");
        out.println("<td>" + rs.getInt("cantidad_producida") + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

    // ====================== VENTAS ======================
    out.println("<h2>Ventas</h2>");
    String ventasQuery = "SELECT v.id_venta, u.nombre AS Cajero, v.tipo_pago, v.total " +
                         "FROM Ventas v " +
                         "INNER JOIN Usuarios u ON v.id_cajero = u.id_usuario ";
    if(!fechaFiltro.isEmpty()) ventasQuery += "WHERE CAST(v.fecha_hora AS DATE) = '" + fechaFiltro + "' ";
    rs = st.executeQuery(ventasQuery);
    out.println("<table class='vision-table'><thead><tr><th>ID Venta</th><th>Cajero</th><th>Tipo Pago</th><th>Total</th></tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id_venta") + "</td>");
        out.println("<td>" + rs.getString("Cajero") + "</td>");
        out.println("<td>" + rs.getString("tipo_pago") + "</td>");
        out.println("<td>" + rs.getDouble("total") + "</td>");
        out.println("</tr>");
    }
    out.println("</tbody></table>");

    // ====================== DETALLE VENTA ======================
    out.println("<h2>Detalle de Ventas</h2>");
    String detQuery = "SELECT dv.id_detalle, dv.id_venta, pr.nombre AS producto, dv.precio_unitario AS precio, dv.cantidad, dv.subtotal_linea " +
                      "FROM DetalleVenta dv " +
                      "INNER JOIN Productos pr ON dv.id_producto = pr.id_producto ";
    if(!fechaFiltro.isEmpty()) detQuery += "WHERE dv.id_venta IN (SELECT id_venta FROM Ventas WHERE CAST(fecha_hora AS DATE) = '" + fechaFiltro + "') ";
    rs = st.executeQuery(detQuery);
    out.println("<table class='vision-table'><thead><tr><th>ID Detalle</th><th>ID Venta</th><th>Producto</th><th>Precio</th><th>Cantidad</th><th>Subtotal</th></tr></thead><tbody>");
    while(rs.next()){
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id_detalle") + "</td>");
        out.println("<td>" + rs.getInt("id_venta") + "</td>");
        out.println("<td>" + rs.getString("producto") + "</td>");
        out.println("<td>" + rs.getDouble("precio") + "</td>");
        out.println("<td>" + rs.getInt("cantidad") + "</td>");
        out.println("<td>" + rs.getDouble("subtotal_linea") + "</td>");
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
</body>
</html>
