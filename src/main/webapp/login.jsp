<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Login Panadería USO</title>
</head>
<body>
  <h2>Iniciar sesión</h2>
  <form action="login" method="post">
    <label>Usuario:</label><br>
    <input type="text" name="username" required><br>
    <label>Contraseña:</label><br>
    <input type="password" name="password" required><br><br>
    <button type="submit">Ingresar</button>
  </form>

  <% if (request.getParameter("error") != null) { %>
    <p style="color:red;">
      <%= "Credenciales incorrectas o usuario inactivo" %>
    </p>
  <% } %>
</body>
</html>
