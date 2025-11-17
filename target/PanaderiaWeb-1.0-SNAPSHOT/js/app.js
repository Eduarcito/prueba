document.addEventListener('DOMContentLoaded', () => {
    const carritoList = document.getElementById('carrito-list');
    const productosGrid = document.getElementById('productos-grid');
    const subtotalDisplay = document.getElementById('subtotal');
    const impuestosDisplay = document.getElementById('impuestos');
    const totalDisplay = document.getElementById('total');
    const buscarInput = document.getElementById('buscar-producto-input');

    let carrito = [];
    const tasaImpuestos = 0.08;
    let lastAddedTimestamp = 0;

    function actualizarTotales() {
        let subtotal = 0;
        carrito.forEach(item => subtotal += item.price * item.quantity);
        const impuestos = subtotal * tasaImpuestos;
        const total = subtotal + impuestos;

        subtotalDisplay.textContent = `$${subtotal.toFixed(2)}`;
        impuestosDisplay.textContent = `$${impuestos.toFixed(2)}`;
        totalDisplay.textContent = `$${total.toFixed(2)}`;
    }

    function renderCarrito() {
        carritoList.innerHTML = '';

        if (carrito.length === 0) {
            const empty = document.createElement('div');
            empty.style.opacity = '0.85';
            empty.style.fontSize = '0.95rem';
            empty.textContent = 'Carrito vacío';
            carritoList.appendChild(empty);
        } else {
            carrito.forEach(item => {
                const itemDiv = document.createElement('div');
                itemDiv.classList.add('carrito-item');
                itemDiv.setAttribute('data-id', item.id);

                itemDiv.innerHTML = `
                    <img src="${item.image}" class="img-mini" alt="img">

                    <div style="display:flex; flex-direction:column; gap:6px;">
                        <strong style="font-size:0.95rem;">${item.name}</strong>
                        <small style="color:rgba(255,255,255,0.7);">$${item.price.toFixed(2)} c/u</small>
                    </div>

                    <div style="display:flex; align-items:center; gap:8px; margin-left:auto;">
                        <div class="controles">
                            <button class="control-btn menos" data-id="${item.id}">-</button>

                            <!-- CAMBIO: input editable -->
                            <input type="number" 
                                   class="input-cantidad" 
                                   data-id="${item.id}"
                                   value="${item.quantity}"
                                   min="0"
                                   style="width:45px; text-align:center; padding:4px 6px; border-radius:6px; border:none;">

                            <button class="control-btn mas" data-id="${item.id}">+</button>
                            <button class="control-btn eliminar" data-id="${item.id}">🗑️</button>
                        </div>
                    </div>
                `;

                carritoList.appendChild(itemDiv);
            });
        }

        actualizarTotales();
    }

    function agregarProducto(producto) {
        const now = Date.now();
        if (now - lastAddedTimestamp < 300) return;
        lastAddedTimestamp = now;

        const itemExistente = carrito.find(item => item.id === producto.id);
        if (itemExistente) {
            itemExistente.quantity++;
        } else {
            carrito.push({
                id: producto.id,
                name: producto.name,
                price: producto.price,
                image: producto.image,
                quantity: 1
            });
        }

        renderCarrito();
    }

    // Listener del grid
    productosGrid.addEventListener('click', (e) => {

        const addBtn = e.target.closest('.add-btn');
        if (addBtn) {
            e.stopPropagation();
            const id = addBtn.getAttribute('data-id');
            const name = addBtn.getAttribute('data-name');
            const price = parseFloat(addBtn.getAttribute('data-price'));
            const image = addBtn.getAttribute('data-image');

            agregarProducto({ id, name, price, image });
            return;
        }

        const card = e.target.closest('.producto-card');
        if (card) {
            const id = card.getAttribute('data-id');
            const name =
                card.getAttribute('data-name') ||
                (card.querySelector('.nombre-producto')
                    ? card.querySelector('.nombre-producto').textContent.trim()
                    : 'Producto');

            const price = parseFloat(
                card.getAttribute('data-price') ||
                (card.querySelector('.precio-producto')
                    ? card.querySelector('.precio-producto').textContent.replace('$', '')
                    : '0')
            );

            const image =
                card.getAttribute('data-image') ||
                (card.querySelector('img')
                    ? card.querySelector('img').src
                    : 'img/no-image.png');

            agregarProducto({ id, name, price, image });
        }
    });

    // Botones + / - / x
    carritoList.addEventListener('click', (e) => {
        const btn = e.target.closest('.control-btn');
        if (!btn) return;

        const id = btn.getAttribute('data-id');
        const item = carrito.find(i => i.id === id);
        if (!item) return;

        if (btn.classList.contains('mas')) {
            item.quantity++;
        } 
        else if (btn.classList.contains('menos')) {
            item.quantity--;
            if (item.quantity <= 0) {
                carrito = carrito.filter(i => i.id !== id);
            }
        }
        else if (btn.classList.contains('eliminar')) {
            carrito = carrito.filter(i => i.id !== id);
        }

        renderCarrito();
    });

    // *** NUEVO: editar cantidad manualmente ***
    carritoList.addEventListener('input', (e) => {
        const input = e.target.closest('.input-cantidad');
        if (!input) return;

        const id = input.getAttribute('data-id');
        const item = carrito.find(i => i.id === id);
        if (!item) return;

        let value = parseInt(input.value);

        if (isNaN(value) || value < 0) value = 0;

        item.quantity = value;

        if (value === 0) {
            carrito = carrito.filter(i => i.id !== id);
        }

        actualizarTotales();
    });

    // Al salir del input (blur), aseguramos número válido
carritoList.addEventListener('change', (e) => {
    const input = e.target.closest('.input-cantidad');
    if (!input) return;

    const id = input.getAttribute('data-id');
    const item = carrito.find(i => i.id === id);
    if (!item) return;

    let value = parseInt(input.value);

    if (isNaN(value) || value <= 0) {
        // Si el usuario deja vacío o pone 0 → eliminar
        carrito = carrito.filter(i => i.id !== id);
    } else {
        item.quantity = value;
    }

    renderCarrito();
});


    // Buscar
    if (buscarInput) {
        buscarInput.addEventListener('input', (e) => {
            const q = (e.target.value || '').trim().toLowerCase();
            const cards = productosGrid.querySelectorAll('.producto-card');
            cards.forEach(card => {
                const name = (card.getAttribute('data-name') || '').toLowerCase();
                const desc =
                    (card.querySelector('.descripcion-producto')
                        ? card.querySelector('.descripcion-producto').textContent
                        : '').toLowerCase();
                card.style.display =
                    name.includes(q) || desc.includes(q) ? 'block' : 'none';
            });
        });
    }

    // Cancelar
    const btnCobrar = document.getElementById('btn-cobrar');
    const btnCancelar = document.getElementById('btn-cancelar');

    if (btnCancelar) {
        btnCancelar.addEventListener('click', () => {
            if (confirm('¿Deseas vaciar el carrito?')) {
                carrito = [];
                renderCarrito();
            }
        });
    }

    if (btnCobrar) {
        btnCobrar.addEventListener('click', () => {
            if (carrito.length === 0) {
                alert('El carrito está vacío.');
                return;
            }
            alert('Cobro simulado — integrar backend después.');
        });
    }

    // Menú usuario
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

    // Cambio foto avatar
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
                reader.onload = e => currentAvatar.src = e.target.result;
                reader.readAsDataURL(file);

                const formData = new FormData(uploadForm);
                fetch('../UploadAvatarServlet', {
                    method: 'POST',
                    body: formData
                });
            }
        });
    }

    // Inicial
    renderCarrito();
});