<%
model.Usuario user = (model.Usuario) session.getAttribute("usuario");
if (user == null || !"Panadero".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}
%>
<h2>Registro de producción</h2>
<form action="registrarProduccion" method="post">
  <label>Tipo de pan:</label><input type="text" name="pan" required><br>
  <label>Cantidad producida:</label><input type="number" name="cantidad" required><br>
  <button type="submit">Registrar</button>
</form>
