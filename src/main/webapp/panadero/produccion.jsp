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

    <!-- Estilos CSS compartidos -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/estilos.css">
</head>
<body>

<div class="aplicacion-tpv">

    <!-- HEADER -->
    <header class="header-tpv">
        <div class="header-content">
            <div class="app-branding">
                <img src="<%= request.getContextPath() %>/img/logo.png" alt="Logo Panadería" class="app-logo">
                <h1>Panadería USO - Producción</h1>
            </div>
            <nav class="top-nav">
                <ul>
                    <li><a href="#" class="nav-link"><%= user.getNombre() %></a></li>
                </ul>
            </nav>
        </div>
    </header>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="main-content">

        <!-- PANEL DE PRODUCCIÓN -->
        <div class="carrito-panel">
            <h3>Panes Seleccionados</h3>
            <div id="produccion-list" class="carrito-list">
                <p>Selecciona un pan del catálogo para registrar su producción</p>
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
                <div class="producto-card" data-name="Concha" data-id="1">
                    <img src="<%= request.getContextPath() %>/img/concha.png" alt="Concha">
                    <p class="nombre-producto">Concha</p>
                </div>
                <div class="producto-card" data-name="Pan de Chocolate" data-id="2">
                    <img src="<%= request.getContextPath() %>/img/pandechocolate.png" alt="Pan de Chocolate">
                    <p class="nombre-producto">Pan de Chocolate</p>
                </div>
                <div class="producto-card" data-name="Cuerno" data-id="3">
                    <img src="<%= request.getContextPath() %>/img/cuerno.png" alt="Cuerno">
                    <p class="nombre-producto">Cuerno</p>
                </div>
                <!-- Agrega más panes aquí -->
            </div>
        </div>

    </div>
</div>

<script>
const productosGrid = document.getElementById('productos-grid');
const produccionList = document.getElementById('produccion-list');
const registrarBtn = document.getElementById('registrar-produccion');

productosGrid.addEventListener('click', e => {
    const card = e.target.closest('.producto-card');
    if (!card) return;

    const id = card.dataset.id;
    const nombre = card.dataset.name;

    // Verifica si ya está en la lista
    if (document.querySelector(`#produccion-list .item[data-id='${id}']`)) return;

    const div = document.createElement('div');
    div.classList.add('carrito-item', 'item');
    div.dataset.id = id;

    div.innerHTML = `
        <span>${nombre}</span>
        <input type="number" value="1" min="1" class="cantidad-produccion">
    `;

    produccionList.appendChild(div);
});

// Registrar producción
registrarBtn.addEventListener('click', () => {
    const items = [...produccionList.querySelectorAll('.item')];
    if(items.length === 0){
        alert("Selecciona al menos un pan para registrar la producción.");
        return;
    }

    const registro = items.map(item => ({
        nombre: item.querySelector('span').textContent,
        cantidad: item.querySelector('input').value,
        fecha: new Date().toLocaleString()
    }));

    console.log("Producción registrada:", registro);
    alert("Producción registrada correctamente en consola (simulación).");

    // Limpiar lista
    produccionList.innerHTML = '<p>Selecciona un pan del catálogo para registrar su producción</p>';
});
</script>

</body>
</html>
