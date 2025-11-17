const contextPath = '<%= request.getContextPath() %>';

const productosGrid = document.getElementById('productos-grid');
const produccionList = document.getElementById('produccion-list');
const registrarBtn = document.getElementById('registrar-produccion');
const buscarInput = document.getElementById('buscar-producto-input');
let produccion = [];

// Renderizar lista de producción
function renderProduccion() {
    produccionList.innerHTML = '';
    if (produccion.length === 0) {
        produccionList.innerHTML = '<p>Selecciona uno o varios panes del catálogo para registrar su producción</p>';
        return;
    }

    produccion.forEach(item => {
        const div = document.createElement('div');
        div.classList.add('carrito-item', 'item');
        div.dataset.id = item.id;

        div.innerHTML = `
            <div style="display:flex; justify-content:space-between; align-items:center; gap:10px;">
                <img src="${item.img}" alt="${item.name}" class="img-mini" style="width:50px; height:50px; object-fit:cover; border-radius:6px;">
                <div style="flex:1; display:flex; flex-direction:column; gap:4px;">
                    <strong style="font-size:0.95rem;">${item.name}</strong>
                </div>
                <div class="controles" style="display:flex; align-items:center; gap:6px;">
                    <button class="control-btn menos" data-id="${item.id}">-</button>
                    <input type="number" 
                           class="input-cantidad" 
                           data-id="${item.id}"
                           value="${item.cantidad}"
                           min="0"
                           style="width:45px; text-align:center; padding:4px 6px; border-radius:6px; border:none;">
                    <button class="control-btn mas" data-id="${item.id}">+</button>
                    <button class="control-btn eliminar" data-id="${item.id}">🗑️</button>
                </div>
            </div>
        `;
        produccionList.appendChild(div);
    });
}
produccionList.addEventListener('click', (e) => {
    const btn = e.target.closest('.control-btn');
    if (!btn) return;

    const id = btn.dataset.id;
    const item = produccion.find(i => i.id === id);
    if (!item) return;

    if (btn.classList.contains('mas')) item.cantidad++;
    else if (btn.classList.contains('menos')) {
        item.cantidad--;
        if (item.cantidad <= 0) produccion = produccion.filter(i => i.id !== id);
    } else if (btn.classList.contains('eliminar')) {
        produccion = produccion.filter(i => i.id !== id);
    }

    renderProduccion();
});

// Editar cantidad manualmente
produccionList.addEventListener('input', (e) => {
    const input = e.target.closest('.input-cantidad');
    if (!input) return;

    const id = input.dataset.id;
    const item = produccion.find(i => i.id === id);
    if (!item) return;

    let value = parseInt(input.value);
    if (isNaN(value) || value < 0) value = 0;

    item.cantidad = value;

    if (value === 0) produccion = produccion.filter(i => i.id !== id);
});


// Selección de productos
productosGrid.addEventListener('click', e => {
    const card = e.target.closest('.producto-card');
    if (!card) return;

    const id = card.dataset.id.toString();
    const name = card.dataset.name || card.querySelector('.nombre-producto')?.textContent.trim() || 'Producto';
    const img = card.dataset.img || card.querySelector('img')?.src || '';

    if (!produccion.find(p => p.id === id)) {
        produccion.push({ id, name, img, cantidad: 1 });
        renderProduccion();
    }
});

// Registrar producción
registrarBtn.addEventListener('click', async () => {
    // Actualizar cantidades desde inputs
    produccion.forEach(item => {
        const input = produccionList.querySelector(`.item[data-id='${item.id}'] .cantidad-produccion`);
        if (input) item.cantidad = parseInt(input.value) || 1;
    });

    if (produccion.length === 0) {
        alert("Selecciona al menos un pan para registrar la producción.");
        return;
    }

    const registro = produccion.map(item => ({
        idProducto: parseInt(item.id),
        cantidad: item.cantidad
    }));

    console.log("[DEBUG] Enviando registro:", registro);

    try {
        const res = await fetch(`${contextPath}/ProduccionServlet`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(registro)
        });

        const text = await res.text();
        let data;
        try {
            data = JSON.parse(text);
        } catch {
            console.error("[ERROR] JSON inválido recibido:", text);
            alert("Error: El servidor no devolvió respuesta válida.");
            return;
        }

        if (data.success) {
            alert(data.message || "Producción registrada correctamente.");
            produccion = [];
            renderProduccion();
        } else {
            alert("Error al registrar producción: " + (data.error || "Desconocido"));
        }

    } catch (err) {
        console.error("[ERROR] Fetch fallo:", err);
        alert("Error al conectar con el servidor. Revisa la consola.");
    }
});
if (buscarInput) {
    buscarInput.addEventListener('input', (e) => {
        const q = (e.target.value || '').trim().toLowerCase();
        const cards = productosGrid.querySelectorAll('.producto-card');

        cards.forEach(card => {
            const name = (card.dataset.name || '').toLowerCase();
            const desc = (card.querySelector('.descripcion-producto')?.textContent || '').toLowerCase();

            // Solo ocultar o mostrar; no cambiar display flex
            if (name.includes(q) || desc.includes(q)) {
                card.style.display = ''; // Deja que el CSS original aplique (flex)
            } else {
                card.style.display = 'none';
            }
        });
    });
}

// Cancelar selección
document.getElementById('btn-cancelar').addEventListener('click', () => {
    if (confirm('¿Deseas vaciar la selección de panes?')) {
        produccion = [];
        renderProduccion();
    }
});
const menuToggle = document.getElementById('menu-toggle');
const userMenu = document.getElementById('user-menu');

menuToggle?.addEventListener('click', e => {
    e.stopPropagation();
    userMenu.classList.toggle('show');
    menuToggle.classList.toggle('active');
});

document.addEventListener('click', e => {
    if (!userMenu.contains(e.target) && !menuToggle.contains(e.target)) {
        userMenu.classList.remove('show');
        menuToggle.classList.remove('active');
    }
});

// Cambiar foto de avatar
const cambiarFotoBtn = document.getElementById('cambiar-foto-btn');
const avatarInput = document.getElementById('avatar-input');
const uploadForm = document.getElementById('upload-form');
const currentAvatar = document.getElementById('current-avatar');

if (cambiarFotoBtn && avatarInput && uploadForm && currentAvatar) {
    cambiarFotoBtn.addEventListener('click', e => {
        e.preventDefault();
        e.stopPropagation();
        avatarInput.click();
    });

    avatarInput.addEventListener('change', () => {
        if (avatarInput.files.length > 0) {
            const file = avatarInput.files[0];
            const reader = new FileReader();
            reader.onload = e => currentAvatar.src = e.target.result;
            reader.readAsDataURL(file);

            const formData = new FormData(uploadForm);
            fetch(`${contextPath}/UploadAvatarServlet`, {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    console.error("[ERROR] Subida avatar:", response.statusText);
                    alert("No se pudo guardar la imagen.");
                }
            })
            .catch(error => {
                console.error("[ERROR] Fallo de red al subir avatar:", error);
                alert("Fallo de conexión al subir avatar.");
            });
        }
    });
}

// Render inicial
renderProduccion();
