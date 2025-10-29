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
    <link rel="stylesheet" href="../css/usuarios.css">
    <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<aside class="sidebar">
    <!-- Logo -->
    <div class="logo">
        <img src="../img/logo.png" alt="Logo Panadería USO" style="filter: brightness(0) invert(1);">
    </div>

    <!-- Menú principal arriba -->
    <nav class="menu">
        <a href="dashboard.jsp"><i class="fas fa-chart-line"></i> Panel</a>
        <a class="active" href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a>
        <a href="reportes.jsp"><i class="fas fa-file-alt"></i> Reportes</a>
    </nav>

    <!-- Salir abajo -->
    <div class="logout">
        <a href="../login.jsp"><i class="fas fa-sign-out-alt"></i> Salir</a>
    </div>
</aside>

<main class="admin-content">
    <div class="main-header">
        <h1>Usuarios registrados</h1>
    </div>

    <section class="table-container">
        <table class="vision-table">
            <thead>
                <tr>
                    <th>Usuario</th>
                    <th>Rol</th>
                    <th>Estado</th>
                    <th>Registrado</th>
                    <th>Acción</th>
                </tr>
            </thead>

            <tbody>
                <%
                    for (Usuario u : listaUsuarios) {
                %>
                <tr>
                    <td>
                        <div class="user-info">
                            <span class="user-name"><%= u.getNombre() %> <%= u.getApellido() %></span>
                            <span class="user-email"><%= u.getTelefono() %></span>
                        </div>
                    </td>

                    <td><%= u.getRol() %></td>

                    <td>
                        <span class="badge <%= u.isActivo() ? "online" : "offline" %>">
                            <%= u.isActivo() ? "En línea" : "Desconectado" %>
                        </span>
                    </td>

                    <td>2024</td>

                    <td><a class="action-link" href="editar.jsp?id=<%= u.getId() %>">Editar</a></td>
                </tr>
                <% } %>

                <% if (listaUsuarios.isEmpty()) { %>
                <tr>
                    <td colspan="5">No hay usuarios registrados.</td>
                </tr>
                <% } %>

            </tbody>
        </table>
    </section>
</main>

<footer class="footer">
    <p>Panadería USO</p>
</footer>

</body>
</html>
