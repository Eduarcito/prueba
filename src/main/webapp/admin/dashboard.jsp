<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
Usuario user = (Usuario) session.getAttribute("usuario");
if (user == null || !"Administrador".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}

int totalUsuarios = 0;
double ventasTotales = 0.0;

List<String> dias = new ArrayList<>();
List<Double> totales = new ArrayList<>();
List<Map<String, Object>> productos = new ArrayList<>();

// NUEVAS LISTAS PARA LA GRÁFICA DE PRODUCTOS
List<String> nombresProductos = new ArrayList<>();
List<Double> ventasPorProducto = new ArrayList<>();
String url = "jdbc:sqlserver://localhost:1433;databaseName=Panaderia;encrypt=false;";
String usuarioDB = "sa";
String claveDB = "TuContraseñaFuerte123";
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, usuarioDB, claveDB);

    // Total usuarios
    ps = con.prepareStatement("SELECT COUNT(*) AS total FROM Usuarios");
    rs = ps.executeQuery();
    if (rs.next()) totalUsuarios = rs.getInt("total");
    rs.close(); ps.close();

    // Ventas totales del año
    ps = con.prepareStatement("SELECT ISNULL(SUM(total), 0) AS total FROM Ventas WHERE YEAR(fecha_hora) = YEAR(GETDATE())");
    rs = ps.executeQuery();
    if (rs.next()) ventasTotales = rs.getDouble("total");
    rs.close(); ps.close();

    // Ventas por día (últimos 7 días) — incluye días sin ventas (devuelve 0)
    ps = con.prepareStatement(
        "WITH fechas AS ( " +
        "  SELECT CAST(DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) AS DATE) AS d " +
        "  UNION ALL " +
        "  SELECT DATEADD(DAY, 1, d) FROM fechas WHERE d < CAST(GETDATE() AS DATE) " +
        ") " +
        "SELECT CONVERT(VARCHAR(10), f.d, 103) AS dia, ISNULL(SUM(v.total), 0) AS total " +
        "FROM fechas f " +
        "LEFT JOIN Ventas v ON CAST(v.fecha_hora AS DATE) = f.d " +
        "GROUP BY f.d " +
        "ORDER BY f.d"
    );
    rs = ps.executeQuery();
    while (rs.next()) {
        dias.add(rs.getString("dia"));
        totales.add(rs.getDouble("total"));
    }
    rs.close(); ps.close();

    // Productos y stock actual
    ps = con.prepareStatement("SELECT nombre, stock_actual FROM Productos ORDER BY nombre");
    rs = ps.executeQuery();
    while (rs.next()) {
        Map<String, Object> p = new HashMap<>();
        p.put("nombre", rs.getString("nombre"));
        p.put("stock", rs.getInt("stock_actual"));
        productos.add(p);
    }
    rs.close(); ps.close();

    // Ventas por producto (usando DetalleVenta) — suma cantidad * precio_unitario
    // LEFT JOIN para incluir productos sin ventas (total = 0)
    ps = con.prepareStatement(
        "SELECT p.nombre, ISNULL(SUM(d.cantidad * d.precio_unitario), 0) AS total " +
        "FROM Productos p " +
        "LEFT JOIN DetalleVenta d ON p.id_producto = d.id_producto " +
        "LEFT JOIN Ventas v ON d.id_venta = v.id_venta AND YEAR(v.fecha_hora) = YEAR(GETDATE()) " +
        "GROUP BY p.nombre " +
        "ORDER BY total DESC"
    );
    rs = ps.executeQuery();
    while (rs.next()) {
        nombresProductos.add(rs.getString("nombre"));
        ventasPorProducto.add(rs.getDouble("total"));
    }
    rs.close(); ps.close();

} catch (Exception e) {
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
}

// Preparar datos para JS — convierto listas a literales JS (evitar NPE)
StringBuilder sbDias = new StringBuilder();
StringBuilder sbTotales = new StringBuilder();
for (int i = 0; i < dias.size(); i++) {
    sbDias.append("\"").append(dias.get(i)).append("\"");
    sbTotales.append(totales.get(i));
    if (i < dias.size() - 1) {
        sbDias.append(",");
        sbTotales.append(",");
    }
}

StringBuilder sbNombresProductos = new StringBuilder();
StringBuilder sbVentasPorProducto = new StringBuilder();
for (int i = 0; i < nombresProductos.size(); i++) {
    sbNombresProductos.append("\"").append(nombresProductos.get(i).replace("\"","\\\"")).append("\"");
    sbVentasPorProducto.append(ventasPorProducto.get(i));
    if (i < nombresProductos.size() - 1) {
        sbNombresProductos.append(",");
        sbVentasPorProducto.append(",");
    }
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrador Panadería USO</title>
    <link rel="stylesheet" href="../css/dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<aside class="sidebar">
    <div class="sidebar-header">
        <img src="../img/logo.png" alt="Logo" class="logo">
        <h2>PANADERIA USO</h2>
    </div>
    <ul class="sidebar-menu">
        <li><a href="dashboard.jsp" class="active"><i class="fas fa-chart-line"></i> Dashboard</a></li>
        <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
        <li><a href="reportes.jsp"><i class="fas fa-file-alt"></i> Reportes</a></li>
    </ul>
    <div class="logout">
        <a href="../login.jsp"><i class="fas fa-sign-out-alt"></i> Salir</a>
    </div>
</aside>

<main class="main-content">
    <header class="main-header">
        <h1>Bienvenido, <%= user.getNombre() %></h1>
    </header>

    <section class="dashboard-grid">
        <div class="left-column">

            <div class="chart-card gradient-purple">
                <div class="chart-header">
                    <h2><i class="fas fa-chart-line"></i> Ventas Diarias (últimos 7 días)</h2>
                </div>
                <div class="chart-content">
                    <canvas id="salesChart"></canvas>
                </div>
            </div>

            <div class="chart-card gradient-blue">
                <div class="chart-header">
                    <h2><i class="fas fa-chart-pie"></i> Ventas por Producto (Año actual)</h2>
                </div>
                <div class="chart-content">
                    <canvas id="productosChart"></canvas>
                </div>
            </div>
        </div>

        <div class="cards-side">
            <div class="card productos-disponibles gradient-purple">
                <i class="fas fa-bread-slice icon"></i>
                <h3>Productos Disponibles</h3>
                <div class="products-card-content">
                    <table class="products-table">
                        <thead>
                            <tr>
                                <th>Nombre</th>
                                <th>Disponibles</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(Map<String, Object> p : productos) { %>
                                <tr>
                                    <td><%= p.get("nombre") %></td>
                                    <td><%= p.get("stock") %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card ventas-totales gradient-green">
                <i class="fas fa-shopping-cart icon"></i>
                <h3>Ventas Totales (Año)</h3>
                <p class="count">$<%= String.format("%.2f", ventasTotales) %></p>
            </div>
            
            <div class="card usuarios-registrados">
                <i class="fas fa-users icon"></i>
                <h3>Usuarios Registrados</h3>
                <p class="count"><%= totalUsuarios %></p>
            </div>
        </div>
    </section>
</main>

<script>
const labels = [<%= sbDias.toString() %>];
const dataValues = [<%= sbTotales.toString() %>];
const ctx = document.getElementById('salesChart').getContext('2d');

const gradient = ctx.createLinearGradient(0, 0, 0, 400);
gradient.addColorStop(0, 'rgba(124, 58, 237, 0.5)');
gradient.addColorStop(1, 'rgba(16, 185, 129, 0.1)');

new Chart(ctx, {
    type: 'line',
    data: {
        labels,
        datasets: [{
            label: 'Ventas ($)',
            data: dataValues,
            fill: true,
            backgroundColor: gradient,
            borderColor: '#7c3aed',
            borderWidth: 3,
            tension: 0.4,
            pointBackgroundColor: '#fff',
            pointBorderColor: '#7c3aed',
            pointRadius: 5,
            pointHoverRadius: 7,
            pointHoverBackgroundColor: '#10b981'
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
            x: { ticks: { color: '#d1d5db' }, grid: { color: 'rgba(255,255,255,0.1)' } },
            y: { ticks: { color: '#d1d5db' }, grid: { color: 'rgba(255,255,255,0.1)' } }
        }
    }
});

const prodLabels = [<%= sbNombresProductos.toString() %>];
const prodData = [<%= sbVentasPorProducto.toString() %>];
const ctxProd = document.getElementById('productosChart').getContext('2d');

new Chart(ctxProd, {
    type: 'doughnut',
    data: {
        labels: prodLabels,
        datasets: [{
            data: prodData,
            backgroundColor: [
                '#7c3aed', '#2563eb', '#10b981', '#f59e0b', '#ef4444', '#14b8a6', '#8b5cf6'
            ],
            borderWidth: 2,
            borderColor: '#fff'
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                display: true,
                labels: { color: '#e5e7eb', font: { size: 13 } }
            },
            tooltip: {
                callbacks: {
                    label: function(context) {
                        let label = context.label || '';
                        let value = context.formattedValue || '0';
                        return label + ': $' + value;
                    }
                }
            }
        },
        cutout: '65%'
    }
});
</script>

</body>
</html>
