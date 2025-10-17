<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="com.panaderia.model.Usuario" %>
<%@ page import="com.panaderia.dao.*" %>

<%
Usuario user = (Usuario) session.getAttribute("usuario");
if (user == null || !"Administrador".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}

// DAO para obtener datos
UsuarioDAO usuarioDAO = new UsuarioDAO();
ProduccionDAO produccionDAO = new ProduccionDAO();
VentasDAO ventasDAO = new VentasDAO();

// Obtener resumen de usuarios por rol
Map<String, Integer> usuariosPorRol = usuarioDAO.contarUsuariosPorRol();

// Producción de hoy
List<Map<String, Object>> produccionHoy = produccionDAO.obtenerProduccionPorDia(new java.util.Date());

// Ventas de hoy
List<Map<String, Object>> ventasHoy = ventasDAO.obtenerVentasPorDia(new java.util.Date());
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Administrador - Panadería USO</title>
    <link rel="stylesheet" href="../css/estilos.css">
</head>
<body>

<nav class="navbar">
    <img src="../img/logo.png" alt="Logo" class="logo">
    <ul>
        <li><a href="dashboard.jsp" class="active">Inicio</a></li>
        <li><a href="reportes.jsp">Reportes</a></li>
        <li><a href="usuarios.jsp">Usuarios</a></li>
    </ul>
</nav>

<main class="admin-content">
    <h2>Bienvenido, <%= user.getNombre() %> (Administrador)</h2>

    <!-- ===== RESUMEN USUARIOS ===== -->
    <section>
        <h3>Usuarios por rol</h3>
        <ul>
            <% for (Map.Entry<String, Integer> entry : usuariosPorRol.entrySet()) { %>
                <li><%= entry.getKey() %>: <%= entry.getValue() %></li>
            <% } %>
        </ul>
    </section>

    <!-- ===== PRODUCCIÓN ===== -->
    <section>
        <h3>Producción del día</h3>
        <table border="1">
            <tr>
                <th>Fecha</th>
                <th>Producto</th>
                <th>Panadero</th>
                <th>Cantidad</th>
            </tr>
            <% for (Map<String, Object> p : produccionHoy) { %>
                <tr>
                    <td><%= p.get("fecha") %></td>
                    <td><%= p.get("producto") %></td>
                    <td><%= p.get("panadero") %></td>
                    <td><%= p.get("cantidad") %></td>
                </tr>
            <% } %>
        </table>
    </section>

    <!-- ===== VENTAS ===== -->
    <section>
        <h3>Ventas del día</h3>
        <table border="1">
            <tr>
                <th>Usuario</th>
                <th>Cantidad de ventas</th>
                <th>Acción</th>
            </tr>
            <% for (Map<String, Object> v : ventasHoy) { %>
                <tr>
                    <td><%= v.get("usuario") %></td>
                    <td><%= v.get("cantidad_ventas") %></td>
                    <td>
                        <form action="detalleVenta.jsp" method="get">
                            <input type="hidden" name="id_usuario" value="<%= v.get("id_usuario") %>">
                            <button type="submit">Ver detalle</button>
                        </form>
                    </td>
                </tr>
            <% } %>
        </table>
    </section>
</main>

<footer class="footer">
    <p>Panadería USO</p>
</footer>

</body>
</html>
