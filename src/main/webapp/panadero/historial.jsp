<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.panaderia.model.Usuario" %>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

            <% Usuario user=(Usuario) session.getAttribute("usuario"); if (user==null) {
                response.sendRedirect("../login.jsp"); return; } %>
                <!DOCTYPE html>
                <html lang="es">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Historial de Producción - Panadería USO</title>
                    <link rel="stylesheet" href="../css/historial2.0.css">
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

                </head>

                <body>
                    <div class="aplicacion-tpv">
                        <header class="header-tpv">
                            <div class="header-content">
                                <div class="app-branding">
                                    <div class="coin-surface"><img src="../img/logoBlanco.png" alt="Logo"></div>
                                    <h1>Panadería USO</h1>
                                </div>
                                <nav class="top-nav">
                                    <ul>
                                        <li onclick="window.location.href='produccion.jsp'" style="cursor:pointer;">
                                            Volver
                                        </li>
                                    </ul>
                                </nav>
                            </div>
                        </header>

                        <main class="admin-content">
                            <div class="main-header">
                                <span class="usuarios"><i class="fas fa-boxes"></i> Historial de Producción</span>

                                <div class="acciones-header">
                                    <input type="date" id="filtroFecha" onchange="filtrarPorFecha()">
                                    <button id="btnExportPdf" onclick="exportarPDF()">Exportar PDF</button>
                                </div>
                            </div>

                            <section class="table-container">
                                <table class="vision-table">
                                    <thead>
                                        <tr>
                                            <th>ID Producción</th>
                                            <th>Panadero</th>
                                            <th>Producto</th>
                                            <th>Cantidad Producida</th>
                                            <th>Fecha</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tablaProduccion">
                                    </tbody>
                                </table>
                            </section>

                            <div class="footer-info">
                                <strong>Total producido: </strong><span id="totalProducido">0 unidades</span>
                            </div>
                        </main>
                    </div>

                    <script>
                        function filtrarPorFecha() {
                            const fecha = document.getElementById('filtroFecha').value;

                            fetch('<%= request.getContextPath() %>/HistorialProduccion?fecha=' + (fecha || ''))
                                .then(r => r.json())
                                .then(data => {
                                    console.log('Data received:', data);
                                    const tabla = document.getElementById('tablaProduccion');
                                    tabla.innerHTML = '';

                                    if (data.error) {
                                        console.error('Server Error:', data.error);
                                        alert('Error del servidor: ' + data.error);
                                        return;
                                    }

                                    if (!Array.isArray(data) || data.length === 0) {
                                        tabla.innerHTML = '<tr><td colspan="5">No hay producción registrada para esta fecha.</td></tr>';
                                        document.getElementById('totalProducido').textContent = '0 unidades';
                                        return;
                                    }

                                    let totalSum = 0;

                                    data.forEach(p => {
                                        totalSum += parseInt(p.cantidad || 0);

                                        tabla.innerHTML += `
                    <tr>
                        <td>\${p.id_produccion}</td>
                        <td>\${p.panadero}</td>
                        <td>\${p.producto}</td>
                        <td>\${p.cantidad}</td>
                        <td>\${p.fecha}</td>
                    </tr>
                `;
                                    });

                                    document.getElementById('totalProducido').textContent =
                                        totalSum + ' unidades';
                                })
                                .catch(err => {
                                    console.error(err);
                                    alert('Error al cargar historial: ' + err.message);
                                });
                        }

                        function exportarPDF() {
                            const fecha = document.getElementById('filtroFecha').value;
                            window.open('<%= request.getContextPath() %>/ExportProduccionPDF?fecha=' + encodeURIComponent(fecha), '_blank');
                        }

                        function exportarXLS() {
                            const fecha = document.getElementById('filtroFecha').value;
                            window.location.href = '<%= request.getContextPath() %>/ExportProduccionXLS?fecha=' + encodeURIComponent(fecha);
                        }

                        window.addEventListener('load', () => {
                            const hoy = new Date().toISOString().split('T')[0];
                            document.getElementById('filtroFecha').value = hoy;
                            filtrarPorFecha();
                        });
                    </script>

                </body>

                </html>