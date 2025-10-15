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
    <title>Usuarios - Panel Administrador</title>
    <link rel="stylesheet" href="../css/estilos.css">
</head>
<body>

<nav class="navbar">
    <img src="../img/logo.png" alt="Logo" class="logo">
    <ul>
        <li><a href="dashboard.jsp">Inicio</a></li>
        <li><a href="reportes.jsp">Reportes</a></li>
        <li><a href="usuarios.jsp">Usuarios</a></li>
    </ul>
</nav>

<main class="admin-content">
    <h2>Gestión de Usuarios</h2>

    <form action="../RegistrarUsuarioServlet" method="post" class="form-admin">
        <input type="text" name="nombre" placeholder="Nombre" required>
        <input type="text" name="apellido" placeholder="Apellido" required>
        <input type="text" name="telefono" placeholder="Teléfono">
        <input type="text" name="direccion" placeholder="Dirección">
        <select name="rol" required>
            <option value="">Seleccionar rol</option>
            <option value="Administrador">Administrador</option>
            <option value="Panadero">Panadero</option>
            <option value="Empleado">Empleado</option>
        </select>
        <button type="submit">Registrar Usuario</button>
    </form>

    <%
        String nuevoUsuario = (String) request.getAttribute("nuevoUsuario");
        String nuevaClave = (String) request.getAttribute("nuevaClave");
        String error = (String) request.getAttribute("error");
        if (nuevoUsuario != null) {
    %>
        <div class="mensaje-exito">
            <p>✅ Usuario registrado correctamente:</p>
            <p><strong>Usuario:</strong> <%= nuevoUsuario %></p>
            <p><strong>Contraseña:</strong> <%= nuevaClave %></p>
        </div>
    <% } else if (error != null) { %>
        <div class="mensaje-error">
            <p>❌ <%= error %></p>
        </div>
    <% } %>

</main>
<footer class="footer">
    <p>Panadería USO</p>
</footer>

</body>
</html>
