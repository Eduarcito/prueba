<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.panaderia.model.Usuario" %>
<%
    Usuario user = (Usuario) session.getAttribute("usuario");
    if (user == null || !"Administrador".equals(user.getRol())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String url="jdbc:sqlserver:GERARDO\\SQLEXPRESS:1433;databaseName=panaderia;IntegratedSecurity=true;";


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

<!-- === SIDEBAR (sin cambios) === -->
<aside class="sidebar">
    <div class="sidebar-header">
        <img src="../img/logo.png" alt="Logo" class="logo">
        <h2>PANADERIA USO</h2>
    </div>
    <nav class="menu">
        <a href="dashboard.jsp"><i class="fas fa-chart-line"></i> Dashboard</a>
        <a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a>
        <a class="active" href="reportes.jsp"><i class="fas fa-file-alt"></i> Reportes</a>
    </nav>
    <div class="logout">
        <a href="../login.jsp"><i class="fas fa-sign-out-alt"></i> Salir</a>
    </div>
</aside>

<!-- === CONTENIDO PRINCIPAL === -->
<main class="admin-content">
    <div class="main-header">
        <span class="reportes"><i class="fas fa-file-alt"></i> Reportes</span>
        <form class="date-filter" method="get">
            <input type="date" name="fecha" value="<%= fechaFiltro %>">
            <button type="submit"><i class="fas fa-search"></i> Buscar</button>
        </form>
    </div>

    <!-- === CARDS DE REPORTES === -->
    <div class="cards-container">
    <%
        Connection con = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(url, usuarioDB, claveDB);
            st = con.createStatement();

            // ========== CARD PRODUCTOS ==========
            out.println("<div class='report-card'>");
            out.println("<h3><i class='fas fa-bread-slice'></i> Productos</h3>");
            rs = st.executeQuery("SELECT TOP 4 nombre, stock_actual FROM Productos ORDER BY id_producto DESC");
            out.println("<table class='mini-table'><thead><tr><th>Producto</th><th>Stock</th></tr></thead><tbody>");
            while(rs.next()){
                out.println("<tr><td>" + rs.getString("nombre") + "</td><td>" + rs.getInt("stock_actual") + "</td></tr>");
            }
            out.println("</tbody></table>");
            // 🔹 Cambio aquí
            out.println("<button class='report-btn' onclick=\"window.open('GenerarReporte?tipo=productos', '_blank')\"><i class='fas fa-file-pdf'></i> Ver reporte completo</button>");
            out.println("</div>");

            // ========== CARD PRODUCCIÓN ==========
            out.println("<div class='report-card'>");
            out.println("<h3><i class='fas fa-industry'></i> Producción</h3>");
            String prodQuery = "SELECT TOP 4 pr.nombre AS producto, p.cantidad_producida " +
                               "FROM Produccion p INNER JOIN Productos pr ON p.id_producto = pr.id_producto ";
            // 🔧 Corrección aplicada aquí:
            if(!fechaFiltro.isEmpty()) prodQuery += "WHERE CAST(p.fecha AS DATE) = '" + fechaFiltro + "' ";
            prodQuery += "ORDER BY p.id_produccion DESC";
            rs = st.executeQuery(prodQuery);
            out.println("<table class='mini-table'><thead><tr><th>Producto</th><th>Cantidad</th></tr></thead><tbody>");
            while(rs.next()){
                out.println("<tr><td>" + rs.getString("producto") + "</td><td>" + rs.getInt("cantidad_producida") + "</td></tr>");
            }
            out.println("</tbody></table>");
            // 🔹 Cambio aquí
            out.println("<button class='report-btn' onclick=\"window.open('GenerarReporte?tipo=produccion', '_blank')\"><i class='fas fa-file-pdf'></i> Ver reporte completo</button>");
            out.println("</div>");

            // ========== CARD VENTAS ==========
            out.println("<div class='report-card'>");
            out.println("<h3><i class='fas fa-cash-register'></i> Ventas</h3>");
            String ventasQuery = "SELECT TOP 4 v.id_venta, v.total " +
                                 "FROM Ventas v ";
            if(!fechaFiltro.isEmpty()) ventasQuery += "WHERE CAST(v.fecha_hora AS DATE) = '" + fechaFiltro + "' ";
            ventasQuery += "ORDER BY v.id_venta DESC";
            rs = st.executeQuery(ventasQuery);
            out.println("<table class='mini-table'><thead><tr><th>ID</th><th>Total</th></tr></thead><tbody>");
            while(rs.next()){
                out.println("<tr><td>" + rs.getInt("id_venta") + "</td><td>$" + rs.getDouble("total") + "</td></tr>");
            }
            out.println("</tbody></table>");
            // 🔹 Cambio aquí
            out.println("<button class='report-btn' onclick=\"window.open('GenerarReporte?tipo=ventas', '_blank')\"><i class='fas fa-file-pdf'></i> Ver reporte completo</button>");
            out.println("</div>");

            // ========== CARD DETALLE DE VENTAS ==========
            out.println("<div class='report-card'>");
            out.println("<h3><i class='fas fa-list'></i> Detalle de Ventas</h3>");
            String detQuery = "SELECT TOP 4 pr.nombre AS producto, dv.cantidad, dv.subtotal_linea " +
                              "FROM DetalleVenta dv " +
                              "INNER JOIN Productos pr ON dv.id_producto = pr.id_producto ";
            if(!fechaFiltro.isEmpty())
                detQuery += "WHERE dv.id_venta IN (SELECT id_venta FROM Ventas WHERE CAST(fecha_hora AS DATE) = '" + fechaFiltro + "') ";
            detQuery += "ORDER BY dv.id_detalle DESC";
            rs = st.executeQuery(detQuery);
            out.println("<table class='mini-table'><thead><tr><th>Producto</th><th>Cant.</th><th>Subtotal</th></tr></thead><tbody>");
            while(rs.next()){
                out.println("<tr><td>" + rs.getString("producto") + "</td><td>" + rs.getInt("cantidad") + "</td><td>$" + rs.getDouble("subtotal_linea") + "</td></tr>");
            }
            out.println("</tbody></table>");
            // 🔹 Cambio aquí
            out.println("<button class='report-btn' onclick=\"window.open('GenerarReporte?tipo=detalle_venta', '_blank')\"><i class='fas fa-file-pdf'></i> Ver reporte completo</button>");
            out.println("</div>");

        } catch(Exception e){
            out.println("<p style='color:red;'>Error al cargar datos: " + e.getMessage() + "</p>");
        } finally {
            try{ if(rs!=null) rs.close(); if(st!=null) st.close(); if(con!=null) con.close(); } catch(Exception ex){}
        }
    %>
    </div>
</main>
</body>
</html>
