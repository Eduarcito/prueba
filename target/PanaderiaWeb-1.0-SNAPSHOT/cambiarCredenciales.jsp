<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cambiar Credenciales - Panadería USO</title>
    <link rel="stylesheet" type="text/css" href="./css/estilos.css">
</head>
<body class="login-page">
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Si el usuario no tiene credenciales temporales, redirige al dashboard según rol
    if (!usuario.isUsernameTemporal() && !usuario.isPasswordTemporal()) {
        switch (usuario.getRol()) {
            case "Administrador":
                response.sendRedirect("admin/dashboard.jsp");
                break;
            case "Panadero":
                response.sendRedirect("panadero/produccion.jsp");
                break;
            case "Empleado":
                response.sendRedirect("ventas/ventas.jsp");
                break;
        }
        return;
    }

    String error = request.getParameter("error");
%>

<div class="login-container">
    <h2>Cambiar credenciales temporales</h2>
    <form action="actualizarCredenciales" method="post">
        <input type="text" name="nuevoUsername" placeholder="Nuevo usuario" required>
        <input type="password" name="nuevaContrasena" placeholder="Nueva contraseña" required>
        <button type="submit">Actualizar</button>
    </form>

    <% if (error != null) { %>
        <p class="error-msg">Hubo un error al actualizar las credenciales. Intente nuevamente.</p>
    <% } %>
</div>
</body>
</html>
