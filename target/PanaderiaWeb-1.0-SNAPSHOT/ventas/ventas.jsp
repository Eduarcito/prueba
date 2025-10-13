<%
model.Usuario user = (model.Usuario) session.getAttribute("usuario");
if (user == null || !"Empleado".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}
%>
<h2>Sistema de Ventas</h2>
<p>Bienvenido, <%= user.getNombre() %></p>
