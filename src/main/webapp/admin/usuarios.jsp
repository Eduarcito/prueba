<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%@ page import="com.panaderia.dao.UsuarioDAO" %>
<%
    // Verificar sesión y rol
    Usuario user = (Usuario) session.getAttribute("usuario");
    if (user == null || !"Administrador".equals(user.getRol())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Obtener lista de usuarios
    UsuarioDAO dao = new UsuarioDAO();
    java.util.List<Usuario> listaUsuarios = new java.util.ArrayList<>();
    try {
        listaUsuarios = dao.listarUsuarios();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Mensajes de error
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Usuarios - Panel Administrador</title>
    <link rel="stylesheet" href="../css/estilos.css">
    <style>
        section { padding: 20px 0; margin-bottom: 40px; }
        .navbar ul li a { padding: 10px 15px; display: inline-block; text-decoration: none; }
        .mensaje-error { color: red; margin-bottom: 20px; }
        .tabla-usuarios { width: 100%; border-collapse: collapse; }
        .tabla-usuarios th, .tabla-usuarios td { padding: 8px; text-align: left; }
    </style>
</head>
<body>

<!-- Menú superior -->
<nav class="navbar">
    <img src="../img/logo.png" alt="Logo" class="logo">
    <ul>
        <li><a href="dashboard.jsp">Inicio</a></li>
        <li><a href="usuarios.jsp">Historial</a></li>
        <li><a href="agregar.jsp">Agregar</a></li>
    </ul>
</nav>

<main class="admin-content">
    <h2>Historial de Usuarios</h2>

    <!-- Mensajes -->
    <% if (error != null) { %>
        <div class="mensaje-error">
            <p>❌ <%= error %></p>
        </div>
    <% } %>

    <!-- Tabla de usuarios -->
    <section id="historial">
        <table border="1" class="tabla-usuarios">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Apellido</th>
                    <th>Teléfono</th>
                    <th>Dirección</th>
                    <th>Rol</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Usuario u : listaUsuarios) {
                %>
                    <tr>
                        <td><%= u.getNombre() %></td>
                        <td><%= u.getApellido() %></td>
                        <td><%= u.getTelefono() %></td>
                        <td><%= u.getDireccion() %></td>
                        <td><%= u.getRol() %></td>
                    </tr>
                <%
                    }
                    if(listaUsuarios.isEmpty()){
                %>
                    <tr>
                        <td colspan="5">No hay usuarios registrados.</td>
                    </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </section>

</main>

<footer class="footer">
    <p>Panadería USO</p>
</footer>

</body>
</html>
