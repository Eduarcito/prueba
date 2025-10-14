<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%
Usuario user = (Usuario) session.getAttribute("usuario");
if (user == null || !"Panadero".equals(user.getRol())) {
    response.sendRedirect("../login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Producción - Panadería USO</title>
    
    <!-- Enlaza tu CSS aquí -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/estilos.css">
</head>
<body>

    <div class="panadero-form-container">
        <h2>Registro de producción</h2>
        <form action="registrarProduccion" method="post">
            <label>Tipo de pan:</label>
            <input type="text" name="pan" required>

            <label>Cantidad producida:</label>
            <input type="number" name="cantidad" required>

            <button type="submit">Registrar</button>
        </form>
    </div>

</body>
</html>
