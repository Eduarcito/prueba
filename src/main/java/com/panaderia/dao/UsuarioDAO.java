package com.panaderia.dao;

import com.panaderia.model.Usuario;
import com.panaderia.util.ConexionDB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.mindrot.jbcrypt.BCrypt; // Importa la librería de seguridad

public class UsuarioDAO {

    private static final String SELECT_USUARIO_BY_USERNAME = 
        "SELECT id_usuario, nombre, username, password_hash, rol, activo FROM Usuarios WHERE username = ?";

    /**
     * Verifica las credenciales del usuario con la contraseña hasheada (BCrypt).
     * @param username El nombre de usuario ingresado.
     * @param password La contraseña en texto plano ingresada.
     * @return Objeto Usuario si las credenciales son válidas, o null si fallan.
     */
    public Usuario validarUsuario(String username, String password) {
        Usuario usuario = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = ConexionDB.conectar();
            stmt = conn.prepareStatement(SELECT_USUARIO_BY_USERNAME);
            stmt.setString(1, username);
            rs = stmt.executeQuery();

            if (rs.next()) {
                // 1. Obtener el hash almacenado en la base de datos
                String storedHash = rs.getString("password_hash");

                // 2. Usar BCrypt para comparar la contraseña ingresada con el hash
                if (BCrypt.checkpw(password, storedHash)) {
                    // La contraseña coincide, crear el objeto Usuario
                    usuario = new Usuario(
                        rs.getInt("id_usuario"),
                        rs.getString("nombre"),
                        rs.getString("username"),
                        storedHash, // Ya tenemos el hash, aunque para el resto de la app solo necesitamos los otros datos
                        rs.getString("rol"),
                        rs.getBoolean("activo")
                    );
                    
                    // Opcional: Verificar que la cuenta esté activa
                    if (!usuario.isActivo()) {
                        usuario = null; // Usuario inactivo
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al validar el usuario: " + e.getMessage());
        } finally {
            // Cerrar recursos en orden inverso
            try { if (rs != null) rs.close(); } catch (SQLException e) { /* Ignorar */ }
            try { if (stmt != null) stmt.close(); } catch (SQLException e) { /* Ignorar */ }
            ConexionDB.cerrar(conn);
        }
        return usuario;
    }
}