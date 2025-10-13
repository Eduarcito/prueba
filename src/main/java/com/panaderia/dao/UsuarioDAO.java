package com.panaderia.dao;

import com.panaderia.model.Usuario;
import com.panaderia.util.ConexionDB;
import com.panaderia.util.PasswordUtils;
import java.sql.*;

public class UsuarioDAO {

    public Usuario validarCredenciales(String username, String password) {
        Usuario user = null;
        String sql = "SELECT * FROM Usuarios WHERE username = ? AND activo = 1";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String hash = rs.getString("password_hash");
                if (PasswordUtils.checkPassword(password, hash)) {
                    user = new Usuario();
                    user.setId(rs.getInt("id_usuario"));
                    user.setNombre(rs.getString("nombre"));
                    user.setUsername(rs.getString("username"));
                    user.setRol(rs.getString("rol"));
                    user.setActivo(rs.getBoolean("activo"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }
}
