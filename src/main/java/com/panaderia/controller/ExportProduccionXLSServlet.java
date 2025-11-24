package com.panaderia.controller;

import com.panaderia.dao.ProduccionDAO;
import com.panaderia.model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/ExportProduccionXLS")
public class ExportProduccionXLSServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fecha = request.getParameter("fecha");

        // Obtener usuario panadero desde sesión
        Usuario panadero = (Usuario) request.getSession().getAttribute("usuario");
        if (panadero == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=historial_produccion.csv");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {

            ProduccionDAO dao = new ProduccionDAO();
            List<Map<String, Object>> lista = dao.listarProduccionPorFecha(fecha, panadero.getId());

            // Encabezados CSV
            out.println("ID Produccion,Producto,Cantidad,Fecha");

            for (Map<String, Object> r : lista) {
                out.print(r.get("id_produccion") + ",");
                out.print("\"" + r.get("producto") + "\",");
                out.print(r.get("cantidad") + ",");
                out.println("\"" + r.get("fecha") + "\"");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
