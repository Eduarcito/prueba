<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%
Usuario user = (Usuario) session.getAttribute("usuario");
if (user == null || !"Panadero".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Producción - Panadería USO</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/produccion.css">
</head>
<body data-contextPath="${pageContext.request.contextPath}">

<div class="aplicacion-tpv">
<header class="header-tpv">
    <div class="header-content">
        <div class="app-branding">
            <div class="logo-coin" aria-hidden="false" title="Panadería USO">
                <div class="coin-surface">
                    <img src="<%= request.getContextPath() %>/img/logoBlanco.png" alt="Logo Panadería" class="app-logo-coin">
                </div>
            </div>
            <h1>Panadería USO</h1>
        </div>

        <nav class="top-nav">
            <ul>
                <li> Panadero </li>
                <li class="menu-usuario-contenedor">
                    <button class="menu-toggle" id="menu-toggle" aria-label="Menú de Usuario">
                        <span class="bar"></span>
                        <span class="bar"></span>
                        <span class="bar"></span>
                    </button>

                    <div class="menu-flotante" id="user-menu">
                        <div class="user-info-header">
                            <%
                                String contextPath = request.getContextPath();
                                String fotoUrl = user.getFotoUrl() != null && !user.getFotoUrl().isEmpty()
                                        ? user.getFotoUrl()
                                        : contextPath + "/img/default-avatar.png";
                            %>
                            <img src="<%= fotoUrl %>" alt="Foto de Usuario" class="user-avatar" id="current-avatar">
                            <p class="user-fullname"><%= user.getNombre() %> <%= user.getApellido() != null ? user.getApellido() : "" %></p>
                            <p class="user-username">@<%= user.getUsername() %></p>
                        </div>
                        <ul class="menu-opciones">
                            <li class="menu-element">
                                <a href="#" id="cambiar-foto-btn" class="nav-link">
                                    <i class="fa fa-camera"></i>
                                    <span class="label">Cambiar Foto</span>
                                </a>
                            </li>
                            <li class="menu-element menu-element-produccion">
                                <a href="<%= request.getContextPath() %>/produccion.jsp" class="nav-link">
                                    <i class="fa fa-bread-slice"></i>
                                    <span class="label">Produccion</span>
                                </a>
                            </li>
                            <li class="menu-element delete">
                                <a href="<%= request.getContextPath() %>/login.jsp" class="logout-btn">
                                    <i class="fa fa-sign-out-alt"></i>
                                    <span class="label">Cerrar Sesión</span>
                                </a>
                            </li>
                        </ul>

                        <form id="upload-form" action="<%= request.getContextPath() %>/UploadAvatarServlet" method="post" enctype="multipart/form-data" style="display: none;">
                            <input type="hidden" name="userId" value="<%= user.getId() %>">
                            <input type="file" name="avatarFile" id="avatar-input" accept="image/*">
                        </form>
                    </div>
                </li>
            </ul>
        </nav>
    </div>
</header>

<div class="main-content">
    <div class="carrito-panel">
                <div class="search-bar">
                    <input type="text" placeholder="Buscar Producto..." id="buscar-producto-input">
                </div>
        <h3>Panes Seleccionados</h3>
        <div id="produccion-list" class="carrito-list">
            <p>Selecciona uno o varios panes del catálogo para registrar su producción</p>
        </div>
        <div class="carrito-botones">
            <button id="registrar-produccion" class="btn cobrar">Registrar Producción</button>
            <button class="btn cancelar" id="btn-cancelar">CANCELAR</button>
        </div>
    </div>

    <div class="catalogo-panel">
        <div class="productos-grid" id="productos-grid">
            <!-- Cada producto tiene data-name para que JS lo lea correctamente -->
            <div class="producto-card" data-id="1" data-name="Concha" data-img="<%= request.getContextPath() %>/img/concha.png">
                <img src="<%= request.getContextPath() %>/img/concha.png" alt="Concha">
                <p class="nombre-producto">Concha</p>
            </div>
            <div class="producto-card" data-id="2" data-name="Maria Luisa" data-img="<%= request.getContextPath() %>/img/marialuisa.png">
                <img src="<%= request.getContextPath() %>/img/marialuisa.png" alt="Maria Luisa">
                <p class="nombre-producto">Maria Luisa</p>
            </div>
            <div class="producto-card" data-id="3" data-name="Quesadilla" data-img="<%= request.getContextPath() %>/img/quesadilla.png">
                <img src="<%= request.getContextPath() %>/img/quesadilla.png" alt="Quesadilla">
                <p class="nombre-producto">Quesadilla</p>
            </div>
            <div class="producto-card" data-id="4" data-name="Roseta" data-img="<%= request.getContextPath() %>/img/roseta.png">
                <img src="<%= request.getContextPath() %>/img/roseta.png" alt="Roseta">
                <p class="nombre-producto">Roseta</p>
            </div>           
        </div>
    </div>
</div>
</div>

<script src="${pageContext.request.contextPath}/js/produccion.js"></script>

</body>
</html>
