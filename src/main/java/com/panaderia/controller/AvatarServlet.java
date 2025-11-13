package com.panaderia.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

@WebServlet("/avatars/*")
public class AvatarServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Obtener baseDir desde variable de entorno o web.xml o fallback al home (igual que UploadAvatarServlet)
        String envDir = System.getenv("AVATAR_UPLOAD_DIR");
        String baseDir = null;
        if (envDir != null && !envDir.trim().isEmpty()) {
            baseDir = envDir;
        } else {
            String ctxParam = getServletContext().getInitParameter("avatar.upload.dir");
            if (ctxParam != null && !ctxParam.trim().isEmpty()) baseDir = ctxParam;
            else baseDir = Paths.get(System.getProperty("user.home"), "panaderia_uploads", "avatars").toString();
        }

        String requested = req.getPathInfo(); // ej: /Emp__Rene_Murcia_avatar_1762.jpg
        if (requested == null || "/".equals(requested)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Evitar path traversal
        Path filePath = Paths.get(baseDir).resolve(requested.substring(1)).normalize();
        if (!filePath.startsWith(Paths.get(baseDir).toAbsolutePath())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File file = filePath.toFile();
        if (!file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = getServletContext().getMimeType(file.getName());
        if (mime == null) mime = "application/octet-stream";
        resp.setContentType(mime);
        resp.setContentLengthLong(file.length());
        // Cabeceras de cache (opcional)
        resp.setHeader("Cache-Control", "public, max-age=86400");

        try (InputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) out.write(buf, 0, len);
        }
    }
}
