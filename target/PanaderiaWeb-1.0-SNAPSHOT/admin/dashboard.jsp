<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%
Usuario user = (Usuario) session.getAttribute("usuario");
if (user == null || !"Administrador".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}
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

    <!-- ===== NAVBAR ===== -->
    <nav class="navbar">
        <img src="../img/logo.png" alt="Logo" class="logo">
        <ul>
            <li><a href="dashboard.jsp" class="active">Inicio</a></li>
            <li><a href="reportes.jsp">Reportes</a></li>
            <li><a href="usuarios.jsp">Usuarios</a></li>
        </ul>
    </nav>

    <!-- ===== CONTENIDO ===== -->
    <main class="admin-content">
        <h2>Bienvenido, <%= user.getNombre() %> (Administrador)</h2>

        <!-- ===== INCLUDE: usuarios.jsp ===== -->
    </main>

    <!-- ===== FOOTER ===== -->
    <footer class="footer">
        <p>Panadería USO</p>
    </footer>

</body>
</html>
