package com.panaderia.controller;

import com.panaderia.dao.ProduccionDAO;
import com.panaderia.model.Usuario;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@WebServlet("/ExportProduccionPDF")
public class ExportProduccionPDFServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String fecha = req.getParameter("fecha");

        // Obtener usuario panadero desde sesión
        Usuario panadero = (Usuario) req.getSession().getAttribute("usuario");
        if (panadero == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        ProduccionDAO dao = new ProduccionDAO();

        try {
            List<Map<String, Object>> lista = dao.listarProduccionPorFecha(fecha, panadero.getId());

            resp.setContentType("application/pdf");
            String filename = "produccion_" + (fecha == null || fecha.isEmpty() ? "todas" : fecha) + ".pdf";
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            try (OutputStream out = resp.getOutputStream()) {
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
                    Image logo = Image.getInstance(req.getServletContext().getRealPath("/img/logo.png"));
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
                String tituloTexto = "HISTORIAL DE PRODUCCIÓN";
                if (fecha != null && !fecha.isEmpty())
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

                // Info del Panadero
                Font subtitleFont = new Font(Font.FontFamily.HELVETICA, 12, Font.NORMAL, BaseColor.BLACK);
                document.add(new Paragraph("Panadero: " + panadero.getNombre(), subtitleFont));
                document.add(new Paragraph("\n"));

                // === TABLA DE DATOS ===
                PdfPTable table = new PdfPTable(5);
                table.setWidthPercentage(100);
                table.setWidths(new float[] { 10, 25, 30, 15, 20 });
                table.setSpacingBefore(15);

                Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.WHITE);
                Font bodyFont = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL, BaseColor.BLACK);
                BaseColor headerColor = new BaseColor(41, 128, 185);

                addHeaderCell(table, "ID", headerFont, headerColor);
                addHeaderCell(table, "Panadero", headerFont, headerColor);
                addHeaderCell(table, "Producto", headerFont, headerColor);
                addHeaderCell(table, "Cant.", headerFont, headerColor);
                addHeaderCell(table, "Fecha", headerFont, headerColor);

                int totalCantidad = 0;

                for (Map<String, Object> r : lista) {
                    table.addCell(new PdfPCell(new Phrase(String.valueOf(r.get("id_produccion")), bodyFont)));
                    table.addCell(new PdfPCell(new Phrase(String.valueOf(r.get("panadero")), bodyFont)));
                    table.addCell(new PdfPCell(new Phrase(String.valueOf(r.get("producto")), bodyFont)));
                    table.addCell(new PdfPCell(new Phrase(String.valueOf(r.get("cantidad")), bodyFont)));
                    table.addCell(new PdfPCell(new Phrase(String.valueOf(r.get("fecha")), bodyFont)));

                    totalCantidad += ((Number) r.get("cantidad")).intValue();
                }

                document.add(table);

                Font boldFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.BLACK);
                Paragraph totalP = new Paragraph("\nTotal producido: " + totalCantidad + " unidades", boldFont);
                totalP.setAlignment(Element.ALIGN_RIGHT);
                document.add(totalP);

                // Footer
                Paragraph footer = new Paragraph("Panadería USO © " + java.time.Year.now(), fechaFont);
                footer.setAlignment(Element.ALIGN_CENTER);
                footer.setSpacingBefore(20);
                document.add(footer);

                document.close();
                writer.close();
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.setContentType("text/plain");
            resp.getWriter().println("Error: " + e.getMessage());
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
