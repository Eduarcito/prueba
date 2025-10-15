<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Panadería USO</title>
  <link rel="stylesheet" type="text/css" href="./css/estilos.css">
</head>
<body class="login-page">
  <div class="login-container">
      <h2>Iniciar sesión</h2>
      <form action="login" method="post">
        <input type="text" name="username" placeholder="Usuario" required>
        <input type="password" name="password" placeholder="Contraseña" required>
        <button type="submit">Ingresar</button>
      </form>

      <% if (request.getParameter("error") != null) { %>
        <p class="error-msg">
          <%= "Credenciales incorrectas o usuario inactivo" %>
        </p>
      <% } %>
  </div>
</body>
</html>
