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

    // Validar login - CORRECCIÓN: Se añadió 'foto_url' al SELECT y al objeto Usuario
    public Usuario validarLogin(String username, String password) throws SQLException {
        String sql = "SELECT id_usuario, nombre, apellido, username, rol, telefono, direccion, activo, password_hash, username_temporal, password_temporal, foto_url "
                   + "FROM Usuarios WHERE username = ?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password_hash");

                if (hashPassword(password).equals(storedHash) && rs.getBoolean("activo")) {
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
                    
                    // LÍNEA CRUCIAL AÑADIDA: Cargar la foto URL de la BD
                    u.setFotoUrl(rs.getString("foto_url")); 
                    
                    return u;
                }
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
        // Añadida foto_url a la consulta
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
                // Asignar foto_url al listar
                u.setFotoUrl(rs.getString("foto_url")); 
                usuarios.add(u);
            }
        }
        return usuarios;
    }

    // Hash password (sin cambios)
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
    
    // MÉTODO DE FOTO ACTUALIZADO - CORRECCIÓN: Sentencia SQL correcta y uso de try-with-resources
   // En UsuarioDAO.java
public void actualizarFoto(int idUsuario, String nuevaFotoUrl) throws SQLException {
    // Usamos 'Usuarios' y 'id_usuario' según tu esquema
    String sql = "UPDATE Usuarios SET foto_url = ? WHERE id_usuario = ?"; 

    try (Connection con = ConexionDB.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        if (con == null) {
             throw new SQLException("Error: La conexión a la base de datos es nula.");
        }
        
        ps.setString(1, nuevaFotoUrl);
        ps.setInt(2, idUsuario);
        
        int rows = ps.executeUpdate();
        if (rows == 0) {
            System.err.println("Advertencia: No se encontró el usuario ID " + idUsuario + " para actualizar la foto.");
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
        // LANZAR la excepción es vital para que el Servlet se entere.
        throw new SQLException("Fallo SQL al actualizar la foto: " + e.getMessage(), e);
    }
}
}