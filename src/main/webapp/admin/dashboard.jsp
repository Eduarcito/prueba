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
    <title>Administrador Panadería USO</title>
    <link rel="stylesheet" href="../css/dashboard.css">
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="../img/logo.png" alt="Logo" class="logo">
            <h2>Panadería USO</h2>
        </div>
        <ul class="sidebar-menu">
            <li><a href="dashboard.jsp" class="active">Dashboard</a></li>
            <li><a href="reportes.jsp">Reportes</a></li>
            <li><a href="usuarios.jsp">Usuarios</a></li>
        </ul>
    </aside>

    <!-- Main content -->
    <main class="main-content">
        <header class="main-header">
            <h1>Bienvenido, <%= user.getNombre() %></h1>
        </header>

        <section class="cards-container">
            <div class="card gradient-blue">
                <h3>Usuarios Registrados</h3>
                <p>25</p>
            </div>
            <div class="card gradient-purple">
                <h3>Ventas Hoy</h3>
                <p>$350.00</p>
            </div>
            <div class="card gradient-pink">
                <h3>Productos Disponibles</h3>
                <p>120</p>
            </div>
            <div class="card gradient-green">
                <h3>Pedidos Pendientes</h3>
                <p>8</p>
            </div>
        </section>
    </main>

</body>
</html>
