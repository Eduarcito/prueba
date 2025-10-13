<%
model.Usuario user = (model.Usuario) session.getAttribute("usuario");
if (user == null || !"Administrador".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}
%>
<h2>Bienvenido, <%= user.getNombre() %> (Administrador)</h2>
<ul>
  <li><a href="usuarios.jsp">Gestionar usuarios</a></li>
  <li><a href="reportes.jsp">Ver reportes</a></li>
</ul>
