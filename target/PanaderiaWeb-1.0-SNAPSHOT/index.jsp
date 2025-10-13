<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panadería USO</title>
    <link rel="stylesheet" href="recursos/css/estilos.css"> 
</head>
<body>

    <div class="aplicacion-tpv">
        <header class="header-tpv">
            <div class="header-content">
                <div class="app-branding">
                    <img src="recursos/img/logo.png" alt="Logo Panadería" class="app-logo"> 
                    <h1>Panadería USO</h1>
                </div>

                <nav class="top-nav">
                    <ul>
                        <li><a href="#" class="nav-link">Cobros</a></li>
                        <li><a href="#" class="nav-link">Usuario</a></li>
                    </ul>
                </nav>
            </div>
        </header>

        <div class="main-content">
            
            <div class="carrito-panel">
                
                <div class="search-bar">
                    <input type="text" placeholder="Buscar Producto...">
                </div>

                <div class="carrito-list" id="carrito-list">
                    <div class="carrito-item" data-price="15.00" data-id="1">
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

            <div class="catalogo-panel">
                <div class="categorias-nav">
                    <span>Categorías:</span>
                    <button class="categoria-btn active">Pan Dulce</button>
                    <button class="categoria-btn">Pasteles</button>
                    <button class="categoria-btn">Bebidas</button>
                </div>
                
                <div class="productos-grid" id="productos-grid">
                    <div class="producto-card" data-id="1" data-name="Concha" data-price="15.00">
                        <img src="recursos/img/concha.png" alt="Concha">
                        <p class="nombre-producto">Concha</p>
                        <p class="precio-producto">$15.00</p>
                    </div>
                    </div>
            </div>

        </div>
    </div>
    
    <script src="recursos/js/app.js"></script> 

</body>
</html>