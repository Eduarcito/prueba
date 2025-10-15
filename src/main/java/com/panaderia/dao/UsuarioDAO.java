package com.panaderia.dao;

import com.panaderia.model.Usuario;
import com.panaderia.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.security.MessageDigest;

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
            ps.setBoolean(9, temporal); // username temporal
            ps.setBoolean(10, temporal); // password temporal

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return -1;
    }

    // Validar login
    public Usuario validarLogin(String username, String password) throws SQLException {
        String sql = "SELECT id_usuario, nombre, apellido, username, rol, telefono, direccion, activo, password_hash, username_temporal, password_temporal "
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
                    return u;
                }
            }
        }
        return null;
    }

    // Cambiar username y/o contraseña de un usuario
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

    // Método para hashear contraseñas
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
}
