package com.panaderia.controller;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

@WebServlet("/admin/GenerarReporte")
public class GenerarReporte extends HttpServlet {
    private static final long serialVersionUID = 1L;
    String url = "jdbc:sqlserver://localhost:1433;databaseName=Panaderia;encrypt=false;";
    String usuarioDB = "sa";
    String claveDB = "TuContraseñaFuerte123";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo");
        String fecha = request.getParameter("fecha");
        if (tipo == null)
            tipo = "";
        if (fecha == null)
            fecha = "";

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=" + tipo + "_reporte.pdf");

        try (OutputStream out = response.getOutputStream();
                Connection con = DriverManager.getConnection(url, usuarioDB, claveDB)) {

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            Document document = new Document(PageSize.A4, 40, 40, 60, 40);
            PdfWriter writer = PdfWriter.getInstance(document, out);
            document.open();

            // === Encabezado (logo + título alineado) ===
            PdfPTable header = new PdfPTable(2);
            header.setWidthPercentage(100);
            header.setWidths(new float[] { 1, 3 });
            header.getDefaultCell().setBorder(Rectangle.NO_BORDER);

            // Logo pequeño
            try {
                Image logo = Image.getInstance(request.getServletContext().getRealPath("/img/logo.png"));
                logo.scaleToFit(60, 60);
                PdfPCell logoCell = new PdfPCell(logo);
                logoCell.setBorder(Rectangle.NO_BORDER);
                logoCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                header.addCell(logoCell);
            } catch (Exception e) {
                PdfPCell emptyCell = new PdfPCell(new Phrase(" "));
                emptyCell.setBorder(Rectangle.NO_BORDER);
                header.addCell(emptyCell);
            }

            // Título en mayúsculas
            Font tituloFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD, new BaseColor(60, 60, 60));
            String tituloTexto = "REPORTE DE " + tipo;
            if (!fecha.isEmpty())
                tituloTexto += " (" + fecha + ")";
            Paragraph titulo = new Paragraph(tituloTexto.toUpperCase(), tituloFont);
            titulo.setAlignment(Element.ALIGN_LEFT);

            PdfPCell tituloCell = new PdfPCell();
            tituloCell.addElement(titulo);
            tituloCell.setBorder(Rectangle.NO_BORDER);
            tituloCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            header.addCell(tituloCell);

            document.add(header);
            document.add(Chunk.NEWLINE);

            // Fecha en español
            Locale locale = new Locale("es", "ES");
            SimpleDateFormat sdf = new SimpleDateFormat("d 'de' MMMM 'de' yyyy", locale);
            String fechaActualStr = sdf.format(new Date());
            Font fechaFont = new Font(Font.FontFamily.HELVETICA, 10, Font.ITALIC, BaseColor.GRAY);
            Paragraph fechaP = new Paragraph("Generado el: " + fechaActualStr, fechaFont);
            fechaP.setAlignment(Element.ALIGN_RIGHT);
            fechaP.setSpacingAfter(10);
            document.add(fechaP);

            // === TABLAS DE DATOS ===
            PdfPTable tabla = null;
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.WHITE);
            Font bodyFont = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL, BaseColor.BLACK);
            BaseColor headerColor = new BaseColor(41, 128, 185);

            switch (tipo) {
                case "productos":
                    tabla = new PdfPTable(2);
                    tabla.setWidthPercentage(100);
                    tabla.setSpacingBefore(15);
                    addHeaderCell(tabla, "Producto", headerFont, headerColor);
                    addHeaderCell(tabla, "Stock Actual", headerFont, headerColor);
                    try (Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery(
                                    "SELECT nombre, stock_actual FROM Productos ORDER BY id_producto DESC")) {
                        while (rs.next()) {
                            tabla.addCell(new PdfPCell(new Phrase(rs.getString("nombre"), bodyFont)));
                            tabla.addCell(
                                    new PdfPCell(new Phrase(String.valueOf(rs.getInt("stock_actual")), bodyFont)));
                        }
                    }
                    break;

                case "produccion":
                    tabla = new PdfPTable(3);
                    tabla.setWidthPercentage(100);
                    tabla.setSpacingBefore(15);
                    addHeaderCell(tabla, "ID Producción", headerFont, headerColor);
                    addHeaderCell(tabla, "Producto", headerFont, headerColor);
                    addHeaderCell(tabla, "Cantidad Producida", headerFont, headerColor);
                    String prodQuery = "SELECT p.id_produccion, pr.nombre AS producto, p.cantidad_producida " +
                            "FROM Produccion p INNER JOIN Productos pr ON p.id_producto = pr.id_producto ";
                    if (!fecha.isEmpty())
                        prodQuery += "WHERE CAST(p.fecha AS DATE) = '" + fecha + "' ";
                    prodQuery += "ORDER BY p.id_produccion DESC";

                    try (Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery(prodQuery)) {
                        while (rs.next()) {
                            tabla.addCell(
                                    new PdfPCell(new Phrase(String.valueOf(rs.getInt("id_produccion")), bodyFont)));
                            tabla.addCell(new PdfPCell(new Phrase(rs.getString("producto"), bodyFont)));
                            tabla.addCell(new PdfPCell(
                                    new Phrase(String.valueOf(rs.getInt("cantidad_producida")), bodyFont)));
                        }
                    }
                    break;

                case "ventas":
                    tabla = new PdfPTable(3);
                    tabla.setWidthPercentage(100);
                    tabla.setSpacingBefore(15);
                    addHeaderCell(tabla, "ID Venta", headerFont, headerColor);
                    addHeaderCell(tabla, "Fecha", headerFont, headerColor);
                    addHeaderCell(tabla, "Total", headerFont, headerColor);
                    String ventasQuery = "SELECT id_venta, fecha_hora, total FROM Ventas ";
                    if (!fecha.isEmpty())
                        ventasQuery += "WHERE CAST(fecha_hora AS DATE) = '" + fecha + "' ";
                    ventasQuery += "ORDER BY id_venta DESC";

                    try (Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery(ventasQuery)) {
                        while (rs.next()) {
                            tabla.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("id_venta")), bodyFont)));
                            tabla.addCell(
                                    new PdfPCell(new Phrase(String.valueOf(rs.getTimestamp("fecha_hora")), bodyFont)));
                            tabla.addCell(new PdfPCell(new Phrase("$" + rs.getDouble("total"), bodyFont)));
                        }
                    }
                    break;

                case "detalle_venta":
                    tabla = new PdfPTable(4);
                    tabla.setWidthPercentage(100);
                    tabla.setSpacingBefore(15);
                    addHeaderCell(tabla, "ID Detalle", headerFont, headerColor);
                    addHeaderCell(tabla, "Producto", headerFont, headerColor);
                    addHeaderCell(tabla, "Cantidad", headerFont, headerColor);
                    addHeaderCell(tabla, "Subtotal", headerFont, headerColor);
                    String detQuery = "SELECT dv.id_detalle, pr.nombre AS producto, dv.cantidad, dv.subtotal_linea " +
                            "FROM DetalleVenta dv INNER JOIN Productos pr ON dv.id_producto = pr.id_producto ";
                    if (!fecha.isEmpty())
                        detQuery += "WHERE dv.id_venta IN (SELECT id_venta FROM Ventas WHERE CAST(fecha_hora AS DATE) = '"
                                + fecha + "') ";
                    detQuery += "ORDER BY dv.id_detalle DESC";

                    try (Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery(detQuery)) {
                        while (rs.next()) {
                            tabla.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("id_detalle")), bodyFont)));
                            tabla.addCell(new PdfPCell(new Phrase(rs.getString("producto"), bodyFont)));
                            tabla.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("cantidad")), bodyFont)));
                            tabla.addCell(new PdfPCell(new Phrase("$" + rs.getDouble("subtotal_linea"), bodyFont)));
                        }
                    }
                    break;

                default:
                    document.add(new Paragraph("Tipo de reporte no reconocido."));
                    document.close();
                    return;
            }

            document.add(tabla);

            Paragraph footer = new Paragraph("Panadería USO © " + java.time.Year.now(), fechaFont);
            footer.setAlignment(Element.ALIGN_CENTER);
            footer.setSpacingBefore(20);
            document.add(footer);

            document.close();
            writer.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error al generar PDF: " + e.getMessage());
        }
    }

    private void addHeaderCell(PdfPTable table, String text, Font font, BaseColor bgColor) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(bgColor);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setPadding(6);
        table.addCell(cell);
    }
}
