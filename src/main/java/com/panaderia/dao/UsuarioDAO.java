package com.panaderia.dao;

import com.panaderia.model.Usuario;
import com.panaderia.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    // Registrar un usuario (por defecto como temporal)
    public int registrarUsuario(Usuario usuario, String contrasena, boolean temporal) throws SQLException {
        String sql = "INSERT INTO Usuarios (nombre, apellido, username, password_hash, telefono, direccion, rol, activo, username_temporal, password_temporal) "
                   + "OUTPUT INSERTED.id_usuario VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getApellido());
            ps.setString(3, usuario.getUsername());
            ps.setString(4, hashPassword(contrasena));
            ps.setString(5, usuario.getTelefono());
            ps.setString(6, usuario.getDireccion());
            ps.setString(7, usuario.getRol());
            ps.setBoolean(8, usuario.isActivo());
            ps.setBoolean(9, temporal);
            ps.setBoolean(10, temporal);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return -1;
    }

    // Validar login
    public Usuario validarLogin(String username, String password) throws SQLException {
    String sql = "SELECT id_usuario, nombre, apellido, username, rol, telefono, direccion, activo, username_temporal, password_temporal, foto_url "
               + "FROM Usuarios WHERE username = ? AND password_hash = ? AND activo = 1";

    try (Connection con = ConexionDB.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, username);
        ps.setString(2, hashPassword(password));

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            Usuario u = new Usuario();
            u.setId(rs.getInt("id_usuario"));
            u.setNombre(rs.getString("nombre"));
            u.setApellido(rs.getString("apellido"));
            u.setUsername(rs.getString("username"));
            u.setRol(rs.getString("rol"));
            u.setTelefono(rs.getString("telefono"));
            u.setDireccion(rs.getString("direccion"));
            u.setActivo(true);
            u.setUsernameTemporal(rs.getBoolean("username_temporal"));
            u.setPasswordTemporal(rs.getBoolean("password_temporal"));
            u.setFotoUrl(rs.getString("foto_url")); // Puede ser null

            return u;
        }
    }
    return null;
}


    // Cambiar username y/o contraseña
    public boolean actualizarCredenciales(int idUsuario, String nuevoUsername, String nuevaContrasena) throws SQLException {
        String sql = "UPDATE Usuarios SET username = ?, password_hash = ?, username_temporal = 0, password_temporal = 0 WHERE id_usuario = ?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nuevoUsername);
            ps.setString(2, hashPassword(nuevaContrasena));
            ps.setInt(3, idUsuario);

            return ps.executeUpdate() > 0;
        }
    }

    // Actualizar usuario (nombre, apellido, teléfono, rol)
    public boolean editarUsuario(int idUsuario, String nombre, String apellido, String telefono, String rol) throws SQLException {
        String sql = "UPDATE Usuarios SET nombre=?, apellido=?, telefono=?, rol=? WHERE id_usuario=?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, telefono);
            ps.setString(4, rol);
            ps.setInt(5, idUsuario);

            return ps.executeUpdate() > 0;
        }
    }

    // Actualizar contraseña
    public void actualizarContrasena(int id, String nuevaClave) throws SQLException {
        String sql = "UPDATE Usuarios SET password_hash=? WHERE id_usuario=?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, hashPassword(nuevaClave));
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    // Listar todos los usuarios
    public List<Usuario> listarUsuarios() throws SQLException {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT id_usuario, nombre, apellido, username, rol, telefono, direccion, activo, foto_url FROM Usuarios";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while(rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id_usuario"));
                u.setNombre(rs.getString("nombre"));
                u.setApellido(rs.getString("apellido"));
                u.setUsername(rs.getString("username"));
                u.setRol(rs.getString("rol"));
                u.setTelefono(rs.getString("telefono"));
                u.setDireccion(rs.getString("direccion"));
                u.setActivo(rs.getBoolean("activo"));

                // Asignar foto URL
                //u.setFotoUrl(rs.getString("foto_url"));
                usuarios.add(u);
            }
        }
        return usuarios;
    }

    // Hash password
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public boolean eliminarUsuario(int idUsuario) throws SQLException {
    String sql = "DELETE FROM Usuarios WHERE id_usuario = ?";
    
    try (Connection con = ConexionDB.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        System.out.println("DEBUG: Intentando eliminar usuario con ID = " + idUsuario);
        ps.setInt(1, idUsuario);

        int filasAfectadas = ps.executeUpdate();
        System.out.println("DEBUG: Filas afectadas por DELETE = " + filasAfectadas);

        return filasAfectadas > 0;
    } catch (SQLException e) {
        System.err.println("ERROR SQL en eliminarUsuario: " + e.getMessage());
        throw e;
    }
}

public void actualizarContrasenaTemporal(int id, String nuevaClave) throws SQLException {
    String sql = "UPDATE Usuarios SET password_hash=?, password_temporal=1 WHERE id_usuario=?";
    try (Connection con = ConexionDB.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, hashPassword(nuevaClave));
        ps.setInt(2, id);
        ps.executeUpdate();
    }
}

public boolean actualizarFotoUrl(int idUsuario, String nuevaFotoUrl) throws SQLException {
    String sql = "UPDATE Usuarios SET foto_url=? WHERE id_usuario=?";

    try (Connection con = ConexionDB.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        if (con == null) {
            throw new SQLException("No se pudo establecer conexión a la base de datos.");
        }

        ps.setString(1, nuevaFotoUrl);
        ps.setInt(2, idUsuario);

        int rows = ps.executeUpdate();
        return rows > 0;

    } catch (SQLException e) {
        e.printStackTrace();
        throw new SQLException("Error al actualizar la foto del usuario en la base de datos. "
                               + e.getMessage(), e);
    }
}





}
