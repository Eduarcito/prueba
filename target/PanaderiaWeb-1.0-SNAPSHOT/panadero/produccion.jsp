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

    <link rel="stylesheet" href="../css/produccion.css">
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
                    <li><a href="#" class="nav-link"><%= user.getNombre() %> (Panadero)</a></li>

                    <li class="menu-usuario-contenedor">

                            <button class="menu-toggle" id="menu-toggle" aria-label="Menú de Usuario">

                                <span class="bar"></span>

                                <span class="bar"></span>

                                <span class="bar"></span>

                            </button>



                            <div class="menu-flotante" id="user-menu">

                                <div class="user-info-header">

                                    <img src="../img/default-avatar.png" alt="Foto de Usuario" class="user-avatar"> 

                                    <p class="user-fullname">**<%= user.getNombre() %> <%= user.getApellido() != null ? user.getApellido() : "" %>**</p>

                                    <p class="user-username">@<%= user.getUsername() %></p>

                                </div>

                                <ul class="menu-opciones">

                                    <li><a href="../login.jsp" class="logout-btn">🚪 Cerrar Sesión</a></li>

                                </ul>

                            </div>

                        </li>
                </ul>
                
            </nav>
        </div>
    </header>

    <div class="main-content">
        <!-- PANEL DE PRODUCCIÓN -->
        <div class="carrito-panel">
            <h3>Panes Seleccionados</h3>
            <div id="produccion-list" class="carrito-list">
                <p>Selecciona uno o varios panes del catálogo para registrar su producción</p>
            </div>

            <button id="registrar-produccion" class="btn cobrar">Registrar Producción</button>
        </div>

        <!-- PANEL DE CATÁLOGO -->
        <div class="catalogo-panel">
            <div class="categorias-nav">
                <span>Categorías:</span>
                <button class="categoria-btn active">Pan Dulce</button>
                <button class="categoria-btn">Pasteles</button>
                <button class="categoria-btn">Bebidas</button>
            </div>

            <div class="productos-grid" id="productos-grid">
                <div class="producto-card" data-name="Concha" data-id="1" data-img="../img/concha.png">
                    <img src="../img/concha.png" alt="Concha">
                    <p class="nombre-producto">Concha</p>
                </div>
                <div class="producto-card" data-name="Maria Luisa" data-id="2" data-img="../img/marialuisa.png">
                    <img src="../img/marialuisa.png" alt="Maria Luisa">
                    <p class="nombre-producto">Maria Luisa</p>
                </div>
                <div class="producto-card" data-name="Quesadilla" data-id="3" data-img="../img/quesadilla.png">
                    <img src="../img/quesadilla.png" alt="Quesadilla">
                    <p class="nombre-producto">Quesadilla</p>
                </div>
                <div class="producto-card" data-name="Roseta" data-id="4" data-img="../img/roseta.png">
                    <img src="../img/roseta.png" alt="Roseta">
                    <p class="nombre-producto">Roseta</p>
                </div>           
            </div>
        </div>
    </div>
</div>

<!-- ✅ Script JS -->
<script>
const productosGrid = document.getElementById('productos-grid');
const produccionList = document.getElementById('produccion-list');
const registrarBtn = document.getElementById('registrar-produccion');

productosGrid.addEventListener('click', e => {
    const card = e.target.closest('.producto-card');
    if (!card) return;

    const id = card.dataset.id;
    const nombre = card.dataset.name;
    const imgSrc = card.dataset.img;

    // Si ya está en la lista, evita duplicarlo
    if (document.querySelector(`#produccion-list .item[data-id='${id}']`)) return;

    const div = document.createElement('div');
    div.classList.add('carrito-item', 'item');
    div.dataset.id = id;

    div.innerHTML = `
        <img src="${imgSrc}" alt="${nombre}" class="img-mini">
        <div class="item-info">
            <span class="nombre-pan">${nombre}</span>
            <label>Cantidad:</label>
            <input type="number" value="1" min="1" class="cantidad-produccion">
        </div>
    `;

    produccionList.appendChild(div);
});

// Registrar producción
registrarBtn.addEventListener('click', () => {
    const items = [...produccionList.querySelectorAll('.item')];
    if (items.length === 0) {
        alert("Selecciona al menos un pan para registrar la producción.");
        return;
    }

    const registro = items.map(item => ({
        nombre: item.querySelector('.nombre-pan').textContent,
        cantidad: item.querySelector('.cantidad-produccion').value,
        fecha: new Date().toLocaleString()
    }));

    console.log("✅ Producción registrada:", registro);
    alert("Producción registrada correctamente (ver consola).");

    produccionList.innerHTML = '<p>Selecciona uno o varios panes del catálogo para registrar su producción</p>';
});
const menuToggle = document.getElementById('menu-toggle');
    const userMenu = document.getElementById('user-menu');

    if (menuToggle && userMenu) {
        // Muestra/Oculta el menú al hacer clic en el botón hamburguesa
        menuToggle.addEventListener('click', (event) => {
            event.stopPropagation();
            userMenu.classList.toggle('show');
            // Agregamos la clase 'active' para la animación de la X
            menuToggle.classList.toggle('active'); 
        });

        // Oculta el menú si se hace clic en cualquier otro lugar de la página
        document.addEventListener('click', (event) => {
            if (!userMenu.contains(event.target) && !menuToggle.contains(event.target)) {
                userMenu.classList.remove('show');
                // Removemos la clase 'active' para que vuelva a ser hamburguesa
                menuToggle.classList.remove('active'); 
            }
        });
    }
</script>
</body>
</html>
