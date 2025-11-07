<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.panaderia.model.Usuario" %>
<%@ page import="com.panaderia.dao.UsuarioDAO" %>

<%! 
    public static String escapeJS(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"");
    }
%>

<%
    Usuario user = (Usuario) session.getAttribute("usuario");
    if (user == null || !"Administrador".equals(user.getRol())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    UsuarioDAO dao = new UsuarioDAO();
    java.util.List<Usuario> listaUsuarios = new java.util.ArrayList<>();
    try {
        listaUsuarios = dao.listarUsuarios();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Usuarios - Panel Administrador</title>

<link rel="stylesheet" href="../css/usuarios.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
.acciones-header { display: flex; gap: 10px; }
.btn-eliminar {
    background: #ef4444; color: #fff; border: none; padding: 8px 14px;
    border-radius: 6px; font-size: 14px; cursor: pointer; transition: background 0.3s;
}
.btn-eliminar:hover { background: #dc2626; }
.delete-icon { display: none; cursor: pointer; color: #ff4d4d; margin-left: 10px; }
</style>
</head>
<body>

<aside class="sidebar">
    <div class="logo">
        <img src="../img/logo.png" alt="Logo Panadería USO" style="filter: brightness(0) invert(1);">
    </div>

    <nav class="menu">
        <a href="dashboard.jsp"><i class="fas fa-chart-line"></i> Panel</a>
        <a class="active" href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a>
        <a href="reportes.jsp"><i class="fas fa-file-alt"></i> Reportes</a>
    </nav>

    <div class="logout">
        <a href="../login.jsp"><i class="fas fa-sign-out-alt"></i> Salir</a>
    </div>
</aside>

<main class="admin-content">
    <div class="main-header">
        <span class="usuarios"><i class="fas fa-users"></i> Usuarios registrados</span>
        <div class="acciones-header">
            <a href="../admin/agregar.jsp" class="btn-agregar"><i class="fas fa-plus"></i> Agregar</a>
            <button class="btn-eliminar" onclick="activarModoEliminar()"><i class="fas fa-trash"></i> Eliminar</button>
        </div>
    </div>

    <section class="table-container">
        <table class="vision-table">
            <thead>
                <tr>
                    <th>Usuario</th>
                    <th>Rol</th>
                    <th>Estado</th>
                    <th>Registrado</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Usuario u : listaUsuarios) {
                %>
                <tr>
                    <td>
                        <div class="user-info">
                            <span class="user-name"><%= u.getNombre() %> <%= u.getApellido() %></span>
                            <span class="user-email"><%= u.getTelefono() %></span>
                        </div>
                    </td>
                    <td><%= u.getRol() %></td>
                    <td>
                        <span class="badge <%= u.isActivo() ? "online" : "offline" %>">
                            <%= u.isActivo() ? "En línea" : "Desconectado" %>
                        </span>
                    </td>
                    <td>2024</td>
                    <td>
                        <span class="action-link" onclick="abrirModal(
                            <%= u.getId() %>, 
                            '<%= escapeJS(u.getNombre()) %>', 
                            '<%= escapeJS(u.getApellido()) %>', 
                            '<%= escapeJS(u.getTelefono()) %>', 
                            '<%= escapeJS(u.getRol()) %>'
                        )">Editar</span>

                        <i class="fas fa-trash delete-icon" 
                           onclick="eliminarUsuario(<%= u.getId() %>, this)"></i>
                    </td>
                </tr>
                <% } %>

                <% if (listaUsuarios.isEmpty()) { %>
                <tr>
                    <td colspan="5">No hay usuarios registrados.</td>
                </tr>
                <% } %>

            </tbody>
        </table>
    </section>
</main>

<!-- Modal Editar Usuario -->
<div id="modalEditar" class="modal">
    <div class="modal-content">
        <span class="close-modal" onclick="cerrarModal()">&times;</span>
        <h2>Editar Usuario</h2>
        <form action="<%= request.getContextPath() %>/EditarUsuarioServlet" method="post">
            <input type="hidden" id="usuarioId" name="id">
            <input type="text" id="editNombre" name="nombre" placeholder="Nombre" required onkeypress="return soloLetras(event)">
            <input type="text" id="editApellido" name="apellido" placeholder="Apellido" required onkeypress="return soloLetras(event)">
            <input type="text" id="editTelefono" name="telefono" placeholder="Teléfono" required onkeypress="return soloNumeros(event)">
            <select id="editRol" name="rol" required>
                <option value="">Seleccionar rol</option>
                <option value="Administrador">Administrador</option>
                <option value="Panadero">Panadero</option>
                <option value="Empleado">Empleado</option>
            </select>
            <button type="submit">Guardar Cambios</button>
            <button type="button" class="button-reset" onclick="restablecerContrasena()">Restablecer Contraseña</button>
        </form>
    </div>
</div>

<script>
// Modal
function abrirModal(id,nombre,apellido,telefono,rol){
    document.getElementById('modalEditar').style.display='block';
    document.getElementById('usuarioId').value=id;
    document.getElementById('editNombre').value=nombre;
    document.getElementById('editApellido').value=apellido;
    document.getElementById('editTelefono').value=telefono;
    document.getElementById('editRol').value=rol;
}
function cerrarModal(){ document.getElementById('modalEditar').style.display='none'; }
window.onclick = function(event){
    if(event.target == document.getElementById('modalEditar')){
        cerrarModal();
    }
}

// Validaciones
function soloLetras(e){
    let key = e.keyCode || e.which;
    let tecla = String.fromCharCode(key).toLowerCase();
    let letras = " áéíóúabcdefghijklmnñopqrstuvwxyz";
    let especiales = [8,37,39,46]; 
    if(letras.indexOf(tecla)===-1 && !especiales.includes(key)) return false;
}
function soloNumeros(e){
    let key = e.keyCode || e.which;
    if(key>=48 && key<=57 || [8,37,39,46].includes(key)) return true;
    return false;
}

// ✅ Restablecer contraseña
function restablecerContrasena() {
    const userId = document.getElementById('usuarioId').value;
    console.log("DEBUG: ID usuario para reset:", userId);

    if (!userId) {
        alert("❌ ID de usuario no válido.");
        return;
    }

    if (confirm("¿Desea restablecer la contraseña de este usuario?")) {
        fetch('<%= request.getContextPath() %>/ResetPasswordServlet?id=' + userId)
            .then(res => res.text())
            .then(msg => { 
                alert(msg); 
                cerrarModal(); 
            })
            .catch(err => {
                console.error(err);
                alert("❌ Error al restablecer contraseña.");
            });
    }
}

// === ELIMINAR USUARIOS ===
let modoEliminar = false;

function activarModoEliminar() {
    modoEliminar = !modoEliminar;
    const iconos = document.querySelectorAll('.delete-icon');
    iconos.forEach(icon => { icon.style.display = modoEliminar ? 'inline' : 'none'; });
    
    const boton = document.querySelector('.btn-eliminar');
    if (modoEliminar) {
        boton.style.background = '#b91c1c';
        boton.innerHTML = '<i class="fas fa-times"></i> Cancelar';
    } else {
        boton.style.background = '#ef4444';
        boton.innerHTML = '<i class="fas fa-trash"></i> Eliminar';
    }
}

function eliminarUsuario(id, element) {
    const idNum = parseInt(id, 10);
    if (isNaN(idNum)) {
        alert("❌ ID inválido.");
        return;
    }

    console.log("DEBUG: ID a eliminar:", idNum);

    if(confirm("¿Deseas eliminar este usuario?")){
        const data = new URLSearchParams();
        data.append('id', idNum);

        fetch('<%= request.getContextPath() %>/EliminarUsuarioServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: data.toString()
        })
        .then(res => res.text())
        .then(msg => {
            alert(msg);
            const row = element.closest('tr');
            if(row) row.remove();
        })
        .catch(err => {
            console.error(err);
            alert("Error al eliminar usuario.");
        });
    }
}
</script>

</body>
</html>
