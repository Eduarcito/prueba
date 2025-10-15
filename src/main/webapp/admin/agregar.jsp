<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%
    // Validación de sesión
    Usuario user = (Usuario) session.getAttribute("usuario");
    if (user == null || !"Administrador".equals(user.getRol())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // ✅ Recuperar los parámetros desde la URL
    String nuevoUsuario = request.getParameter("nuevoUsuario");
    String nuevaClave = request.getParameter("nuevaClave");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agregar Usuario - Panel Administrador</title>
    <link rel="stylesheet" href="../css/estilos.css">
    <style>
        .mensaje-exito {
            background: #e6ffe6;
            color: #006400;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
        }
        .mensaje-error {
            background: #ffe6e6;
            color: #b30000;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
        }
        .form-admin input, .form-admin select {
            display: block;
            width: 100%;
            margin-bottom: 10px;
            padding: 10px;
        }
        .form-admin button {
            background: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
        }
        .form-admin button:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
    <img src="../img/logo.png" alt="Logo" class="logo">
    <ul>
        <li><a href="dashboard.jsp">Dashboard</a></li>
        <li><a href="usuarios.jsp">Usuarios</a></li>
        <li><a href="agregar.jsp" class="active">Agregar</a></li>
    </ul>
</nav>

<!-- Contenido principal -->
<main class="admin-content">
    <h2>Registrar nuevo usuario</h2>

    <!-- Formulario -->
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

    <!-- 👇 Mostrar credenciales generadas o error -->
    <%
        if (nuevoUsuario != null && nuevaClave != null) {
    %>
        <div class="mensaje-exito">
            <h3>✅ Usuario registrado correctamente:</h3>
            <p><strong>Usuario:</strong> <%= nuevoUsuario %></p>
            <p><strong>Contraseña temporal:</strong> <%= nuevaClave %></p>
        </div>
    <% } else if (error != null) { %>
        <div class="mensaje-error">
            <p>❌ <%= error %></p>
        </div>
    <% } %>
</main>

<!-- Footer -->
<footer class="footer">
    <p>Panadería USO</p>
</footer>

</body>
</html>
