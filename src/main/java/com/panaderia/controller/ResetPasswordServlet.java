package com.panaderia.controller;

import com.panaderia.dao.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Random;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private UsuarioDAO dao;

    @Override
    public void init() throws ServletException {
        super.init();
        dao = new UsuarioDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.getWriter().write("❌ ID de usuario no proporcionado.");
            return;
        }

        int idUsuario;
        try {
            idUsuario = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.getWriter().write("❌ ID de usuario inválido.");
            return;
        }

        String contrasenaTemporal = generarContrasenaTemporal(8);

        try {
            dao.actualizarContrasenaTemporal(idUsuario, contrasenaTemporal);
            response.getWriter().write("✅ Contraseña restablecida a: " + contrasenaTemporal
                + "\nEl usuario deberá cambiarla al iniciar sesión.");
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("❌ Error al restablecer contraseña: " + e.getMessage());
        }
    }

    private String generarContrasenaTemporal(int longitud) {
        String caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random rnd = new Random();
        StringBuilder sb = new StringBuilder(longitud);
        for (int i = 0; i < longitud; i++) {
            sb.append(caracteres.charAt(rnd.nextInt(caracteres.length())));
        }
        return sb.toString();
    }
}
