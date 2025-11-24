package com.panaderia.controller;

import com.panaderia.dao.VentaDAO;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.awt.Color; // <<<<<<<<<<<<<< AQUI ESTA EL IMPORT CORRECTO

@WebServlet("/ExportPDF")
public class ExportPDFServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String fecha = req.getParameter("fecha");

        VentaDAO dao = new VentaDAO();

        try {
            List<Map<String,Object>> lista = dao.listarVentasPorFecha(fecha);

            resp.setContentType("application/pdf");
            String filename = "ventas_" + (fecha == null || fecha.isEmpty() ? "todas" : fecha) + ".pdf";
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            Document document = new Document(PageSize.A4);
            PdfWriter.getInstance(document, resp.getOutputStream());
            document.open();

            Font titleFont = new Font(Font.HELVETICA, 18, Font.BOLD);
            Paragraph title = new Paragraph("Historial de Ventas", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(10);
            document.add(title);

            Font subtitleFont = new Font(Font.HELVETICA, 12);
            document.add(new Paragraph(
                "Fecha filtro: " + (fecha == null || fecha.isEmpty() ? "Todas" : fecha),
                subtitleFont
            ));

            document.add(new Paragraph("\n"));

            PdfPTable table = new PdfPTable(6);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{10, 10, 30, 10, 15, 15});

            addHeaderCell(table, "ID Venta");
            addHeaderCell(table, "Cajero(ID)");
            addHeaderCell(table, "Producto");
            addHeaderCell(table, "Cant.");
            addHeaderCell(table, "Total");
            addHeaderCell(table, "Fecha");

            double totalSum = 0;

            for (Map<String,Object> r : lista) {
                table.addCell(String.valueOf(r.get("idventas")));
                table.addCell(String.valueOf(r.get("cajero")));
                table.addCell(String.valueOf(r.get("producto")));
                table.addCell(String.valueOf(r.get("cantidad")));
                table.addCell(String.format("%.2f", ((Number) r.get("total")).doubleValue()));
                table.addCell(String.valueOf(r.get("fecha")));

                totalSum += ((Number) r.get("total")).doubleValue();
            }

            document.add(table);

            Font boldFont = new Font(Font.HELVETICA, 12, Font.BOLD);
            document.add(new Paragraph(
                "\nTotal vendido: $" + String.format("%.2f", totalSum),
                boldFont
            ));

            document.close();

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.setContentType("text/plain");
            resp.getWriter().println("Error: " + e.getMessage());
        }
    }

    private void addHeaderCell(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, new Font(Font.HELVETICA, 12, Font.BOLD)));
        cell.setBackgroundColor(new Color(220, 220, 220)); // << usa java.awt.Color
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.addCell(cell);
    }
}
