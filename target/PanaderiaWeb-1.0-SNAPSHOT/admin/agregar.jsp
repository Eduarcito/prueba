<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%
    // Validación de sesión
    Usuario user = (Usuario) session.getAttribute("usuario");
    if (user == null || !"Administrador".equals(user.getRol())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Recuperar mensajes de la sesión (POST-REDIRECT-GET)
    String nuevoUsuario = (String) session.getAttribute("nuevoUsuario");
    String nuevaClave = (String) session.getAttribute("nuevaClave");
    String error = (String) session.getAttribute("error");

    // Limpiar los atributos para que no aparezcan al recargar
    session.removeAttribute("nuevoUsuario");
    session.removeAttribute("nuevaClave");
    session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agregar Usuario - Panel Administrador</title>
    <link rel="stylesheet" href="../css/agregar.css">
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

<aside class="sidebar">
    <div class="sidebar-header">
        <img src="../img/logo.png" alt="Logo" class="logo">
        <h2>PANADERÍA USO</h2>
    </div>
    <ul class="sidebar-menu">
        <li><a href="dashboard.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
        <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
        <li><a href="agregar.jsp" class="active"><i class="fas fa-user-plus"></i> Agregar</a></li>
    </ul>
    <div class="logout">
        <a href="../login.jsp"><i class="fas fa-sign-out-alt"></i> Salir</a>
    </div>
</aside>


<!-- Contenido principal -->
<main class="admin-content">
    <div class="admin-content-inner">
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

        <% if (nuevoUsuario != null && nuevaClave != null) { %>
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
    </div>
</main>

</body>
</html>
