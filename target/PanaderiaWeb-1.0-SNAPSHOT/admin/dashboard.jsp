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

List<String> meses = new ArrayList<>();
List<Double> totales = new ArrayList<>();
List<Map<String, Object>> productos = new ArrayList<>();

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

    // Ventas mensuales
    ps = con.prepareStatement(
        "SELECT DATENAME(MONTH, fecha_hora) AS mes, SUM(total) AS total " +
        "FROM Ventas GROUP BY DATENAME(MONTH, fecha_hora), MONTH(fecha_hora) " +
        "ORDER BY MONTH(fecha_hora)"
    );
    rs = ps.executeQuery();
    while (rs.next()) {
        meses.add(rs.getString("mes"));
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

} catch (Exception e) {
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
}

StringBuilder sbMeses = new StringBuilder();
StringBuilder sbTotales = new StringBuilder();
for (int i = 0; i < meses.size(); i++) {
    sbMeses.append("\"").append(meses.get(i)).append("\"");
    sbTotales.append(totales.get(i));
    if (i < meses.size() - 1) {
        sbMeses.append(",");
        sbTotales.append(",");
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
                    <h2><i class="fas fa-chart-line"></i> Ventas Mensuales</h2>
                </div>
                <div class="chart-content">
                    <canvas id="salesChart"></canvas>
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
            
            <div class="card gradient-blue">
                <i class="fas fa-users icon"></i>
                <h3>Usuarios Registrados</h3>
                <p class="count"><%= totalUsuarios %></p>
            </div>
        </div>
    </section>
</main>

<script>
const labels = [<%= sbMeses.toString() %>];
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
</script>

</body>
</html>
