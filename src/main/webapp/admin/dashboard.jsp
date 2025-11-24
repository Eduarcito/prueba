<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

// Listas para grafica de productos
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

    // Total de usuarios
    ps = con.prepareStatement("SELECT COUNT(*) AS total FROM Usuarios");
    rs = ps.executeQuery();
    if (rs.next()) totalUsuarios = rs.getInt("total");
    rs.close(); 
    ps.close();

    // Ventas totales del año
    ps = con.prepareStatement("SELECT ISNULL(SUM(total), 0) AS total FROM Ventas WHERE YEAR(fecha_hora) = YEAR(GETDATE())");
    rs = ps.executeQuery();
    if (rs.next()) ventasTotales = rs.getDouble("total");
    rs.close(); 
    ps.close();

    // Ventas por dia (ultimos 7 dias)
    String queryDias =
        "WITH fechas AS ( " +
        "    SELECT CAST(DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) AS DATE) AS d " +
        "    UNION ALL " +
        "    SELECT DATEADD(DAY, 1, d) FROM fechas WHERE d < CAST(GETDATE() AS DATE) " +
        ") " +
        "SELECT CONVERT(VARCHAR(10), f.d, 103) AS dia, ISNULL(SUM(v.total), 0) AS total " +
        "FROM fechas f " +
        "LEFT JOIN Ventas v ON CAST(v.fecha_hora AS DATE) = f.d " +
        "GROUP BY f.d " +
        "ORDER BY f.d";

    ps = con.prepareStatement(queryDias);
    rs = ps.executeQuery();

    while (rs.next()) {
        dias.add(rs.getString("dia"));
        totales.add(rs.getDouble("total"));
    }
    rs.close();
    ps.close();

    // Productos disponibles (stock)
    ps = con.prepareStatement("SELECT nombre, stock_actual FROM Productos ORDER BY nombre");
    rs = ps.executeQuery();

    while (rs.next()) {
        Map<String, Object> p = new HashMap<>();
        p.put("nombre", rs.getString("nombre"));
        p.put("stock", rs.getInt("stock_actual"));
        productos.add(p);
    }
    rs.close();
    ps.close();

    // Ventas por producto del año
    String queryProductos =
        "SELECT p.nombre, ISNULL(SUM(d.cantidad * d.precio_unitario), 0) AS total " +
        "FROM Productos p " +
        "LEFT JOIN DetalleVenta d ON p.id_producto = d.id_producto " +
        "LEFT JOIN Ventas v ON d.id_venta = v.id_venta AND YEAR(v.fecha_hora) = YEAR(GETDATE()) " +
        "GROUP BY p.nombre " +
        "ORDER BY total DESC";

    ps = con.prepareStatement(queryProductos);
    rs = ps.executeQuery();

    while (rs.next()) {
        nombresProductos.add(rs.getString("nombre"));
        ventasPorProducto.add(rs.getDouble("total"));
    }
    rs.close();
    ps.close();

} catch (Exception e) {
    e.printStackTrace();
} finally {
    try {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    } catch (Exception e) {}
}

// Preparar datos para JS
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
    sbNombresProductos.append("\"")
        .append(nombresProductos.get(i).replace("\"", "\\\""))
        .append("\"");
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
    <title>Administrador Panaderia USO</title>

    <link rel="stylesheet" href="../css/dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>

    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="coin-surface">
                <img src="../img/logoBlanco.png" alt="Logo Panaderia" class="app-logo-coin">
            </div>
            <h2>PANADERIA USO</h2>
        </div>

        <ul class="sidebar-menu">
            <li>
                <a href="dashboard.jsp" class="active">
                    <i class="fas fa-chart-line"></i> Dashboard
                </a>
            </li>
            <li>
                <a href="usuarios.jsp">
                    <i class="fas fa-users"></i> Usuarios
                </a>
            </li>
            <li>
                <a href="reportes.jsp">
                    <i class="fas fa-file-alt"></i> Reportes
                </a>
            </li>
        </ul>

        <div class="logout">
            <a href="../login.jsp">
                <i class="fas fa-sign-out-alt"></i> Salir
            </a>
        </div>
    </aside>

    <main class="main-content">
        <header class="main-header">
            <h1>Bienvenido, <%= user.getNombre() %></h1>
        </header>

        <div class="dashboard-grid">
            <!-- COLUMNA IZQUIERDA: GRAFICAS -->
            <div class="left-column">
                <!-- GRÁFICA 1: VENTAS DIARIAS -->
                <div class="chart-card">
                    <div class="chart-header">
                        <i class="fas fa-chart-line"></i>
                        <h2>Ventas Diarias (últimos 7 días)</h2>
                    </div>
                    <div class="chart-content">
                        <canvas id="ventasChart"></canvas>
                    </div>
                </div>

                <!-- GRÁFICA 2: VENTAS POR PRODUCTO -->
                <div class="chart-card">
                    <div class="chart-header">
                        <i class="fas fa-chart-pie"></i>
                        <h2>Ventas por Producto (Año actual)</h2>
                    </div>
                    <div class="chart-content">
                        <canvas id="productosChart"></canvas>
                    </div>
                </div>

            </div> <!-- FIN LEFT-COLUMN -->


            <!-- COLUMNA DERECHA -->
            <div class="cards-side">

                <!-- TABLA DE PRODUCTOS -->
                <div class="card productos-disponibles">
                    <p>
                        <i class="fas fa-bread-slice"></i> Productos Disponibles
                    </p>

                    <div class="products-card-content">
                        <table class="products-table">
                            <thead>
                                <tr>
                                    <th>Nombre</th>
                                    <th>Disponibles</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> prod : productos) { %>
                                    <tr>
                                        <td><%= prod.get("nombre") %></td>
                                        <td><%= prod.get("stock") %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- VENTAS TOTALES -->
                <div class="card ventas-totales">
                    <i class="fas fa-shopping-cart" style="font-size: 2rem; margin-bottom: 10px;"></i>
                    <p>Ventas Totales (Año)</p>
                    <p class="count">
                        $<%= String.format("%.2f", ventasTotales) %>
                    </p>
                </div>

                <!-- USUARIOS REGISTRADOS -->
                <div class="card usuarios-registrados">
                    <i class="fas fa-users" style="font-size: 2rem; margin-bottom: 10px;"></i>
                    <p>Usuarios Registrados</p>
                    <p class="count"><%= totalUsuarios %></p>
                </div>

            </div> <!-- FIN cards-side -->

        </div> <!-- FIN dashboard-grid -->
    </main>
<script>
    // GRÁFICA DE VENTAS DIARIAS (LINE)
    const ctx = document.getElementById('ventasChart').getContext('2d');

    const gradient = ctx.createLinearGradient(0, 0, 0, 400);
    gradient.addColorStop(0, 'rgba(124, 58, 237, 0.5)');
    gradient.addColorStop(1, 'rgba(124, 58, 237, 0)');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: [<%= sbDias.toString() %>],
            datasets: [{
                label: 'Ventas ($)',
                data: [<%= sbTotales.toString() %>],
                borderColor: '#8b5cf6',
                backgroundColor: gradient,
                borderWidth: 2,
                pointBackgroundColor: '#fff',
                pointBorderColor: '#8b5cf6',
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: 'rgba(17, 24, 39, 0.9)',
                    titleColor: '#fff',
                    bodyColor: '#fff',
                    padding: 10,
                    cornerRadius: 8,
                    displayColors: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: 'rgba(255,255,255,0.1)' },
                    ticks: { color: '#9ca3af' }
                },
                x: {
                    grid: { display: false },
                    ticks: { color: '#9ca3af' }
                }
            }
        }
    });

    // GRÁFICA DE PRODUCTOS (DOUGHNUT)
    const ctx2 = document.getElementById('productosChart').getContext('2d');

    new Chart(ctx2, {
        type: 'doughnut',
        data: {
            labels: [<%= sbNombresProductos.toString() %>],
            datasets: [{
                data: [<%= sbVentasPorProducto.toString() %>],
                backgroundColor: [
                    '#8b5cf6', // Violeta
                    '#3b82f6', // Azul
                    '#10b981', // Verde
                    '#f59e0b', // Amarillo
                    '#ef4444'  // Rojo
                ],
                borderWidth: 0,
                hoverOffset: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                    labels: { 
                        color: '#fff',
                        usePointStyle: true 
                    }
                }
            },
            cutout: '60%'
        }
    });
</script>

</body>
</html>
