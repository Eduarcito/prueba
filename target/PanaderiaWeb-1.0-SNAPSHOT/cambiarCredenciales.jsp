<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Cambiar Credenciales - Panadería USO</title>
  <link rel="stylesheet" type="text/css" href="./css/credenciales.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="login-page">

<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }

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

<div class="login-wrapper reverse-layout"><!-- NUEVO -->
  <div class="login-container">
      <h2>Cambiar credenciales temporales</h2>
      <form action="actualizarCredenciales" method="post">
        <div class="input-group">
          <i class="fas fa-user"></i>
          <input type="text" name="nuevoUsername" placeholder="Nuevo usuario" required>
        </div>
        <div class="input-group">
          <i class="fas fa-lock"></i>
          <input type="password" name="nuevaContrasena" placeholder="Nueva contraseña" required>
        </div>
        <button type="submit">Actualizar</button>
      </form>

      <% if (error != null) { %>
        <p class="error-msg">Hubo un error al actualizar las credenciales. Intente nuevamente.</p>
      <% } %>
  </div>

  <div class="login-image">
    <img src="./img/pan1.jpg" alt="Panadería" />
  </div>
</div>

</body>
</html>
