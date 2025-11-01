<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Panadería USO - Login</title>
  <link rel="stylesheet" type="text/css" href="./css/login.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="login-page">

<div class="login-wrapper">

  <div class="login-image">
    <img src="./img/pan1.jpg" alt="Panadería" />
  </div>

  <div class="login-container">
      <h2>Iniciar sesión</h2>
      <form action="login" method="post">
        <div class="input-group">
          <i class="fas fa-user"></i>
          <input type="text" name="username" placeholder="Usuario" required>
        </div>
        <div class="input-group">
          <i class="fas fa-lock"></i>
          <input type="password" name="password" placeholder="Contraseña" required>
        </div>
        <button type="submit">Ingresar</button>
      </form>

      <% if (request.getParameter("error") != null) { %>
        <p class="error-msg">
          <%= "Credenciales incorrectas o usuario inactivo" %>
        </p>
      <% } %>
  </div>

</div>

</body>
</html>
