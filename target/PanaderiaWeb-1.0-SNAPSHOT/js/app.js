document.addEventListener('DOMContentLoaded', () => {
    // -----------------------------------------------------------------------
    // **LÓGICA EXISTENTE DE LA APLICACIÓN TPV (CARRITO Y CATÁLOGO)**
    // -----------------------------------------------------------------------
    const carritoList = document.getElementById('carrito-list');
    const productosGrid = document.getElementById('productos-grid');
    const subtotalDisplay = document.getElementById('subtotal');
    const impuestosDisplay = document.getElementById('impuestos');
    const totalDisplay = document.getElementById('total');

    let carrito = [];
    const tasaImpuestos = 0.08; 

    function actualizarTotales() {
        let subtotal = 0;
        
        carrito.forEach(item => {
            subtotal += item.price * item.quantity;
        });

        const impuestos = subtotal * tasaImpuestos;
        const total = subtotal + impuestos;

        subtotalDisplay.textContent = `$${subtotal.toFixed(2)}`;
        impuestosDisplay.textContent = `$${impuestos.toFixed(2)}`;
        totalDisplay.textContent = `$${total.toFixed(2)}`;
    }

    function renderCarrito() {
        // Limpiamos el contenido simulado del carrito si lo hubiera
        // Nota: En tu JSP inicial había un item simulado. Lo eliminamos al renderizar.
        const itemsSimulados = carritoList.querySelectorAll('.carrito-item');
        itemsSimulados.forEach(item => item.remove());
        
        carritoList.innerHTML = ''; 
        
        carrito.forEach(item => {
            const itemDiv = document.createElement('div');
            itemDiv.classList.add('carrito-item');
            itemDiv.setAttribute('data-id', item.id);
            
            itemDiv.innerHTML = `
                <span>${item.name}</span>
                <span class="cantidad">${item.quantity}</span>
                <div class="controles">
                    <button class="control-btn menos" data-id="${item.id}">-</button>
                    <button class="control-btn mas" data-id="${item.id}">+</button>
                </div>
            `;
            carritoList.appendChild(itemDiv);
        });

        actualizarTotales();
    }

    productosGrid.addEventListener('click', (e) => {
        const card = e.target.closest('.producto-card');
        if (card) {
            const id = card.getAttribute('data-id');
            const name = card.getAttribute('data-name');
            const price = parseFloat(card.getAttribute('data-price')); 
            
            agregarProducto({ id, name, price });
        }
    });

    function agregarProducto(producto) {
        const itemExistente = carrito.find(item => item.id === producto.id);

        if (itemExistente) {
            itemExistente.quantity++;
        } else {
            carrito.push({
                id: producto.id,
                name: producto.name,
                price: producto.price,
                quantity: 1
            });
        }
        renderCarrito();
    }

    carritoList.addEventListener('click', (e) => {
        const btn = e.target.closest('.control-btn');
        if (btn) {
            const id = btn.getAttribute('data-id');
            const item = carrito.find(i => i.id === id);

            if (item) {
                if (btn.classList.contains('mas')) {
                    item.quantity++;
                } else if (btn.classList.contains('menos')) {
                    item.quantity--;
                    
                    if (item.quantity <= 0) {
                        carrito = carrito.filter(i => i.id !== id);
                    }
                }
            }
            renderCarrito();
        }
    });

    // -----------------------------------------------------------------------
    // **NUEVA LÓGICA PARA EL MENÚ DE USUARIO (CON ANIMACIÓN)**
    // -----------------------------------------------------------------------
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

    // Inicialización
    renderCarrito();
});