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

<<<<<<< HEAD
    <link rel="stylesheet" href="../css/ventas.css">
=======
    <!-- ✅ CSS -->
    <link rel="stylesheet" href="../css/estilos.css?v=<%= System.currentTimeMillis() %>">
>>>>>>> parent of fdf3c8f (git commit)
</head>

<body>
    <div class="aplicacion-tpv">
        <header class="header-tpv">
            <div class="header-content">
                <div class="app-branding">
                    <img src="../img/logo.png" alt="Logo Panadería" class="app-logo"> 
                    <h1>Panadería USO</h1>
                </div>

                <nav class="top-nav">
                    <ul>
                        <li><a href="#" class="nav-link">Cobros</a></li>
                        <li><a href="#" class="nav-link"><%= user.getNombre() %></a></li>
                    </ul>
                </nav>
            </div>
        </header>

        <!-- ===== CONTENIDO PRINCIPAL ===== -->
        <div class="main-content">
            
            <!-- Panel del carrito -->
            <div class="carrito-panel">
                <div class="search-bar">
                    <input type="text" placeholder="Buscar Producto...">
                </div>

                <div class="carrito-list" id="carrito-list">
                    <div class="carrito-item" data-price="0.25" data-id="1">
                        <span>Concha Azúcar</span>
                        <span class="cantidad">2</span>
                        <div class="controles">
                            <button class="control-btn menos" data-id="1">-</button>
                            <button class="control-btn mas" data-id="1">+</button>
                        </div>
                    </div>
                </div>

                <div class="resumen-totales">
                    <p>Subtotal: <span id="subtotal">$125.00</span></p>
                    <p>Impuestos (8%): <span id="impuestos">$10.00</span></p>
                    <p class="total-final">TOTAL: <span id="total">$335.00</span></p>
                </div>

                <div class="botones-accion">
                    <button class="btn cobrar">COBRAR</button>
                    <button class="btn cancelar">CANCELAR</button>
                </div>
            </div>

            <!-- Panel del catálogo -->
            <div class="catalogo-panel">
                <div class="categorias-nav">
                    <span>Categorías:</span>
                    <button class="categoria-btn active">Pan Dulce</button>
                    <button class="categoria-btn">Pasteles</button>
                    <button class="categoria-btn">Bebidas</button>
                </div>
                
                <div class="productos-grid" id="productos-grid">
                    <!-- 🥯 Catálogo de productos -->
                    <div class="producto-card" data-id="1" data-name="Concha" data-price="0.25">
                        <img src="../img/concha.png" alt="Concha">
                        <p class="nombre-producto">Concha</p>
                        <p class="precio-producto">$0.25</p>
                    </div>

                    <div class="producto-card" data-id="2" data-name="marialuisa" data-price="0.30">
                        <img src="../img/marialuisa.png"marialuisa">
                        <p class="nombre-producto">Maria Luisa</p>
                        <p class="precio-producto">$0.30</p>
                    </div>

                    <div class="producto-card" data-id="3" data-name="quesadilla" data-price="0.35">
                        <img src="../img/quesadilla.png" alt="quesadilla">
                        <p class="nombre-producto">Quesadilla</p>
                        <p class="precio-producto">$0.35</p>
                    </div>

                    <div class="producto-card" data-id="4" data-name="roseta" data-price="0.20">
                        <img src="../img/roseta.png" alt="roseta">
                        <p class="nombre-producto">Roseta</p>
                        <p class="precio-producto">$0.20</p>
                    </div>

                </div>
            </div>

        </div> <!-- Fin main-content -->
    </div> <!-- Fin aplicacion-tpv -->

    <!-- ✅ JS -->
    <script src="../js/app.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
