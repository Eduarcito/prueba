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
    <link rel="stylesheet" href="../css/produccion.css">
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
    <div class="carrito-panel">
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

<script>
const productosGrid = document.getElementById('productos-grid');
const produccionList = document.getElementById('produccion-list');
const registrarBtn = document.getElementById('registrar-produccion');

productosGrid.addEventListener('click', e => {
    const card = e.target.closest('.producto-card');
    if (!card) return;

    const id = card.dataset.id;
    const nombre = card.dataset.name || card.querySelector('.nombre-producto').textContent.trim();
    const imgSrc = card.dataset.img;

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

// 🔹 BLOQUE CORREGIDO PARA ENVÍO AL SERVLET
registrarBtn.addEventListener('click', () => {
    const items = [...produccionList.querySelectorAll('.item')];
    if (items.length === 0) {
        alert("Selecciona al menos un pan para registrar la producción.");
        return;
    }

    const registro = items.map(item => ({
        idProducto: parseInt(item.dataset.id),
        cantidad: parseInt(item.querySelector('.cantidad-produccion').value)
    }));

    fetch('<%= request.getContextPath() %>/ProduccionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(registro)
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            alert(data.message || "Producción registrada correctamente.");
            produccionList.innerHTML = '<p>Selecciona uno o varios panes del catálogo para registrar su producción</p>';
        } else {
            alert("Error al registrar la producción: " + (data.error || "Desconocido"));
        }
    })
    .catch(err => {
        console.error(err);
        alert("Fallo al conectar con el servidor.");
    });

    console.log("✅ Producción registrada:", registro);
});

const menuToggle = document.getElementById('menu-toggle');
const userMenu = document.getElementById('user-menu');

if (menuToggle && userMenu) {
    menuToggle.addEventListener('click', (event) => {
        event.stopPropagation();
        userMenu.classList.toggle('show');
        menuToggle.classList.toggle('active');
    });

    document.addEventListener('click', (event) => {
        if (!userMenu.contains(event.target) && !menuToggle.contains(event.target)) {
            userMenu.classList.remove('show');
            menuToggle.classList.remove('active');
        }
    });
}

const cambiarFotoBtn = document.getElementById('cambiar-foto-btn');
const avatarInput = document.getElementById('avatar-input');
const uploadForm = document.getElementById('upload-form');
const currentAvatar = document.getElementById('current-avatar');

if (cambiarFotoBtn && avatarInput && uploadForm && currentAvatar) {
    cambiarFotoBtn.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        avatarInput.click();
    });

    avatarInput.addEventListener('change', () => {
        if (avatarInput.files.length > 0) {
            const file = avatarInput.files[0];

            const reader = new FileReader();
            reader.onload = function(e) {
                currentAvatar.src = e.target.result;
            }
            reader.readAsDataURL(file);

            const formData = new FormData(uploadForm);
            fetch('../UploadAvatarServlet', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    console.error("Error al subir la imagen.");
                    alert("No se pudo guardar la imagen.");
                }
            })
            .catch(error => {
                console.error("Error de red:", error);
                alert("Fallo de conexión.");
            });
        }
    });
}
</script>

</body>
</html>
