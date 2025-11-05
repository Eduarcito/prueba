<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%
    Usuario user = (Usuario) session.getAttribute("usuario");
    if (user == null || !"Administrador".equals(user.getRol())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String nuevoUsuario = (String) session.getAttribute("nuevoUsuario");
    String nuevaClave = (String) session.getAttribute("nuevaClave");
    String error = (String) session.getAttribute("error");

    session.removeAttribute("nuevoUsuario");
    session.removeAttribute("nuevaClave");
    session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Agregar Usuario - Panel Administrador</title>
<link rel="stylesheet" href="../css/agregar.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<script>
function soloLetras(e){ if(!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]$/.test(e.key)) e.preventDefault(); }
function soloNumeros(e){ if(!/^[0-9]$/.test(e.key)) e.preventDefault(); }
function validarLetras(input,errorId){ input.value=input.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g,''); document.getElementById(errorId).style.display=input.value.length===0?'block':'none'; }
function validarNumeros(input,errorId){ input.value=input.value.replace(/[^0-9]/g,''); document.getElementById(errorId).style.display=input.value.length===0?'block':'none'; }
function validarFormulario(){
    let valid=true;
    const nombre=document.getElementById('nombre');
    const apellido=document.getElementById('apellido');
    const telefono=document.getElementById('telefono');
    if(nombre.value.trim()===''){ valid=false; document.getElementById('error-nombre').style.display='block'; }
    if(apellido.value.trim()===''){ valid=false; document.getElementById('error-apellido').style.display='block'; }
    if(telefono.value.trim()!=='' && !/^\d+$/.test(telefono.value)){ valid=false; document.getElementById('error-telefono').style.display='block'; }
    return valid;
}
</script>
</head>
<body>
<aside class="sidebar">
    <div class="sidebar-header">
        <img src="../img/logo.png" alt="Logo" class="logo">
        <h2>PANADERÍA USO</h2>
    </div>
    <ul class="sidebar-menu">
        <li><a href="dashboard.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
        <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
        <li><a href="agregar.jsp" class="active"><i class="fas fa-user-plus"></i> Agregar</a></li>
    </ul>
    <div class="logout">
        <a href="../login.jsp"><i class="fas fa-sign-out-alt"></i> Salir</a>
    </div>
</aside>

<main class="admin-content">
    <div class="admin-content-inner">
        <h2>Registrar nuevo usuario</h2>
        <form action="../RegistrarUsuarioServlet" method="post" class="form-admin" onsubmit="return validarFormulario()">

            <div class="input-icon">
                <i class="fas fa-user"></i>
                <input type="text" id="nombre" name="nombre" placeholder="Nombre" required onkeypress="soloLetras(event)" oninput="validarLetras(this,'error-nombre')">
            </div>
            <div id="error-nombre" class="input-error">❌ Solo se permiten letras en el nombre</div>

            <div class="input-icon">
                <i class="fas fa-user"></i>
                <input type="text" id="apellido" name="apellido" placeholder="Apellido" required onkeypress="soloLetras(event)" oninput="validarLetras(this,'error-apellido')">
            </div>
            <div id="error-apellido" class="input-error">❌ Solo se permiten letras en el apellido</div>

            <div class="input-icon">
                <i class="fas fa-phone"></i>
                <input type="text" id="telefono" name="telefono" placeholder="Teléfono" onkeypress="soloNumeros(event)" oninput="validarNumeros(this,'error-telefono')">
            </div>
            <div id="error-telefono" class="input-error">❌ Solo se permiten números en el teléfono</div>

            <div class="input-icon">
                <i class="fas fa-map-marker-alt"></i>
                <input type="text" name="direccion" placeholder="Dirección">
            </div>

            <div class="input-icon">
                <i class="fas fa-user-tag"></i>
                <select name="rol" required>
                    <option value="">Seleccionar rol</option>
                    <option value="Administrador">Administrador</option>
                    <option value="Panadero">Panadero</option>
                    <option value="Empleado">Empleado</option>
                </select>
            </div>

            <button type="submit">Registrar Usuario</button>
        </form>

        <% if (nuevoUsuario != null && nuevaClave != null) { %>
            <div class="mensaje-exito">
                <h3>✅ Usuario registrado correctamente:</h3>
                <p><strong>Usuario:</strong> <%= nuevoUsuario %></p>
                <p><strong>Contraseña temporal:</strong> <%= nuevaClave %></p>
            </div>
        <% } else if (error != null) { %>
            <div class="mensaje-error">
                <p>❌ <%= error %></p>
            </div>
        <% } %>
    </div>
</main>
</body>
</html>
