<%@ page import="com.panaderia.model.Usuario" %>
<%
Usuario user = (Usuario) session.getAttribute("usuario");
if (user == null || !"Empleado".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panadería USO - Ventas</title>

    <link rel="stylesheet" href="../css/ventas.css">
</head>

<body>
    <div class="aplicacion-tpv">
        <header class="header-tpv">
            <div class="header-content">
                <div class="app-branding">
                    <div class="logo-coin" aria-hidden="false" title="Panadería USO">
                        <div class="coin-surface">
                            <img src="../img/logoBlanco.png" alt="Logo Panadería" class="app-logo-coin">
                        </div>
                    </div>
                        <h1>Panadería USO</h1>
                </div>

                <nav class="top-nav">
                    <ul>
                        <li> Cajero </li>

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
                                    <li><a href="#" id="cambiar-foto-btn" class="nav-link">📸 Cambiar Foto</a></li>
                                    <li><a href="../login.jsp" class="logout-btn">🚪 Cerrar Sesión</a></li>
                                </ul>

                                <form id="upload-form" action="../UploadAvatarServlet" method="post" enctype="multipart/form-data" style="display: none;">
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

            <aside class="carrito-panel" aria-label="Panel de cobros">
                <div class="search-bar">
                    <input type="text" placeholder="Buscar Producto..." id="buscar-producto-input">
                </div>

                <div class="carrito-list" id="carrito-list">
                    <!-- items renderizados por JS -->
                </div>

                <div class="resumen-totales">
                    <p>Subtotal: <span id="subtotal">$0.00</span></p>
                    <p>Impuestos (8%): <span id="impuestos">$0.00</span></p>
                    <p class="total-final">TOTAL: <span id="total">$0.00</span></p>
                </div>

                <div class="botones-accion">
                    <button class="btn cobrar" id="btn-cobrar">COBRAR</button>
                    <button class="btn cancelar" id="btn-cancelar">CANCELAR</button>
                </div>
            </aside>
            <section class="catalogo-panel">
                <div class="section-hero">
                    <h2>Nuestro Pan</h2>
                </div>

                <div class="productos-wrap">
                    <div class="productos-grid" id="productos-grid">

                        <div class="producto-card" data-id="1" data-name="Concha" data-price="0.25">
                            <div class="thumb">
                                <img src="../img/concha.png" alt="Concha">
                            </div>
                            <div class="content">
                                <p class="nombre-producto">Concha</p>
                                <p class="descripcion-producto">Pan dulce tradicional con cobertura azucarada — ideal para acompañar café.</p>
                                <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; width:100%;">
                                    <p class="precio-producto">$0.25</p>
                                    <button class="add-btn" data-id="1" data-name="Concha" data-price="0.25">AÑADIR AL CARRITO</button>
                                </div>
                            </div>
                        </div>

                        <div class="producto-card" data-id="2" data-name="Maria Luisa" data-price="0.30">
                            <div class="thumb"><img src="../img/marialuisa.png" alt="Maria Luisa"></div>
                            <div class="content">
                                <p class="nombre-producto">Maria Luisa</p>
                                <p class="descripcion-producto">Galleta suave y esponjosa, perfecta como snack.</p>
                                <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; width:100%;">
                                    <p class="precio-producto">$0.30</p>
                                    <button class="add-btn" data-id="2" data-name="Maria Luisa" data-price="0.30">AÑADIR AL CARRITO</button>
                                </div>
                            </div>
                        </div>

                        <div class="producto-card" data-id="3" data-name="Quesadilla" data-price="0.35">
                            <div class="thumb"><img src="../img/quesadilla.png" alt="Quesadilla"></div>
                            <div class="content">
                                <p class="nombre-producto">Quesadilla</p>
                                <p class="descripcion-producto">Recién horneada con queso y textura crujiente.</p>
                                <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; width:100%;">
                                    <p class="precio-producto">$0.35</p>
                                    <button class="add-btn" data-id="3" data-name="Quesadilla" data-price="0.35">AÑADIR AL CARRITO</button>
                                </div>
                            </div>
                        </div>

                        <div class="producto-card" data-id="4" data-name="Roseta" data-price="0.20">
                            <div class="thumb"><img src="../img/roseta.png" alt="Roseta"></div>
                            <div class="content">
                                <p class="nombre-producto">Roseta</p>
                                <p class="descripcion-producto">Clásico panecillo con un toque de mantequilla.</p>
                                <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; width:100%;">
                                    <p class="precio-producto">$0.20</p>
                                    <button class="add-btn" data-id="4" data-name="Roseta" data-price="0.20">AÑADIR AL CARRITO</button>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </section>

        </div>
    </div>

    <script src="../js/app.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>