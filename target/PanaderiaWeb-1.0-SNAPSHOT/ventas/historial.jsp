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
                    <title>Historial de Ventas - Panadería USO</title>

                    <link rel="stylesheet" href="../css/historial.css">
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
                                        <li onclick="window.location.href='ventas.jsp'" style="cursor:pointer;">Volver
                                        </li>
                                    </ul>
                                </nav>
                            </div>
                        </header>

                        <main class="admin-content">
                            <div class="main-header">
                                <span class="usuarios"><i class="fas fa-receipt"></i> Historial de Ventas</span>

                                <div class="acciones-header">
                                    <input type="date" id="filtroFecha" onchange="filtrarPorFecha()">
                                    <select id="filterCajero" style="display:none;"></select>
                                    <button id="btnExportPdf" onclick="exportarPDF()">Exportar PDF</button>
                                    <button id="btnExportXls" onclick="exportarXLS()">Exportar XLSX</button>
                                </div>
                            </div>

                            <section class="table-container">
                                <table class="vision-table">
                                    <thead>
                                        <tr>
                                            <th>Ventas (ID)</th>
                                            <th>Cajero (ID)</th>
                                            <th>Producto</th>
                                            <th>Cantidad</th>
                                            <th>Total</th>
                                            <th>Fecha</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tablaVentas">
                                    </tbody>
                                </table>
                            </section>

                            <div class="footer-info">
                                <strong>Total vendido: </strong><span id="totalVendido">$0.00</span>
                            </div>
                        </main>
                    </div>

                    <script>
                        function formatMoney(n) { return Number(n).toFixed(2); }

                        function filtrarPorFecha() {
                            const fecha = document.getElementById('filtroFecha').value;

                            fetch('<%= request.getContextPath() %>/HistorialVentas?fecha=' + (fecha || ''))
                                .then(r => r.json())
                                .then(data => {
                                    const tabla = document.getElementById('tablaVentas');
                                    tabla.innerHTML = '';

                                    if (!Array.isArray(data) || data.length === 0) {
                                        tabla.innerHTML = '<tr><td colspan="6">No hay ventas registradas para esta fecha.</td></tr>';
                                        document.getElementById('totalVendido').textContent = '$0.00';
                                        return;
                                    }

                                    let totalSum = 0;

                                    data.forEach(v => {
                                        totalSum += parseFloat(v.total || 0);

                                        tabla.innerHTML += `
                    <tr>
                        <td>\${v.idventas}</td>
                        <td>\${v.cajero}</td>
                        <td>\${v.producto}</td>
                        <td>\${v.cantidad}</td>
                        <td>$\${formatMoney(v.total)}</td>
                        <td>\${v.fecha}</td>
                    </tr>
                `;
                                    });

                                    document.getElementById('totalVendido').textContent =
                                        '$' + formatMoney(totalSum);
                                })
                                .catch(err => {
                                    console.error(err);
                                    alert('Error al cargar historial.');
                                });
                        }

                        function exportarPDF() {
                            const fecha = document.getElementById('filtroFecha').value;
                            window.open('<%= request.getContextPath() %>/ExportPDF?fecha=' + encodeURIComponent(fecha), '_blank');
                        }

                        function exportarXLS() {
                            const fecha = document.getElementById('filtroFecha').value;
                            window.location.href = '<%= request.getContextPath() %>/ExportXLS?fecha=' + encodeURIComponent(fecha);
                        }

                        window.addEventListener('load', () => {
                            const hoy = new Date().toISOString().split('T')[0];
                            document.getElementById('filtroFecha').value = hoy;
                            filtrarPorFecha();
                        });
                    </script>

                </body>

                </html>