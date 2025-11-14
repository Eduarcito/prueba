package com.panaderia.controller;

import com.panaderia.model.Usuario;
import com.panaderia.dao.UsuarioDAO;
import javax.imageio.ImageIO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.file.*;
import java.util.Arrays;

@WebServlet("/UploadAvatarServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class UploadAvatarServlet extends HttpServlet {

    private UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        Usuario user = (Usuario) request.getSession().getAttribute("usuario");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Sesión expirada.");
            return;
        }

        try {
            Part filePart = request.getPart("avatarFile");
            if (filePart == null || filePart.getSize() == 0) {
                throw new IllegalArgumentException("No se recibió archivo o el archivo está vacío.");
            }

            // Validación básica de tipo MIME
            String submittedContentType = filePart.getContentType();
            if (submittedContentType == null || !submittedContentType.startsWith("image/")) {
                response.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE, "Solo se permiten imágenes.");
                return;
            }

            // Leer todo el InputStream a bytes (necesario para validar con ImageIO y luego guardar)
            byte[] fileBytes;
            try (InputStream in = filePart.getInputStream();
                 ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
                byte[] buffer = new byte[8192];
                int r;
                while ((r = in.read(buffer)) != -1) baos.write(buffer, 0, r);
                fileBytes = baos.toByteArray();
            }

            // Validar que realmente sea una imagen (ImageIO devuelve null si no puede leer)
            try (ByteArrayInputStream bais = new ByteArrayInputStream(fileBytes)) {
                BufferedImage img = ImageIO.read(bais);
                if (img == null) {
                    response.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE, "El archivo no es una imagen válida.");
                    return;
                }
            }

            // Resolver directorio base (env -> web.xml -> user.home fallback)
            Path uploadDir = resolveAvatarBaseDir(request);

            // Preparar nombre de archivo seguro
            String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = "";
            int dot = originalName.lastIndexOf('.');
            if (dot > 0 && dot < originalName.length() - 1) {
                ext = originalName.substring(dot);
            }
            String safeUser = user.getUsername() != null ? user.getUsername().replaceAll("[^a-zA-Z0-9_\\-]", "_") : "user";
            String newFileName = safeUser + "_avatar_" + System.currentTimeMillis() + ext;
            Path targetPath = uploadDir.resolve(newFileName);

            // Guardar el nuevo archivo (bytes ya validados)
            Files.write(targetPath, fileBytes, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);

            // DEBUG
            System.out.println("DEBUG RUTA FÍSICA DE GUARDADO: " + uploadDir.toAbsolutePath().toString());
            System.out.println("DEBUG ARCHIVO DESTINO: " + targetPath.toAbsolutePath().toString());

            // Eliminar avatar antiguo si aplica (evitar borrar avatar por defecto)
            try {
                String oldPublicUrl = user.getFotoUrl(); // lo que hay en sesión/BD antes de actualizar
                if (oldPublicUrl != null && !oldPublicUrl.trim().isEmpty()) {
                    // Buscamos la porción '/avatars/' y extraemos el nombre de archivo
                    int idx = oldPublicUrl.lastIndexOf("/avatars/");
                    if (idx >= 0) {
                        String oldFileName = oldPublicUrl.substring(idx + "/avatars/".length());
                        if (oldFileName != null && !oldFileName.trim().isEmpty()) {
                            Path oldPath = uploadDir.resolve(oldFileName).normalize();
                            // Seguridad: sólo borrar si realmente está dentro de uploadDir
                            if (oldPath.startsWith(uploadDir) && Files.exists(oldPath) && Files.isRegularFile(oldPath)) {
                                // Evitar borrar si por alguna razón es el default avatar (por ejemplo default-avatar.png)
                                if (!oldFileName.equalsIgnoreCase("default-avatar.png")) {
                                    Files.deleteIfExists(oldPath);
                                    System.out.println("DEBUG: Avatar antiguo eliminado: " + oldPath.toString());
                                }
                            }
                        }
                    }
                }
            } catch (Exception ex) {
                // No bloquear el flujo si no se puede borrar; solo loguear
                System.err.println("WARN: no se pudo eliminar el avatar antiguo: " + ex.getMessage());
                ex.printStackTrace();
            }

            // Construir la URL pública que sirve el AvatarServlet en /avatars/*
            String contextPath = request.getContextPath();
            String publicUrl = contextPath + "/avatars/" + newFileName;

            // Actualizar BD y sesión
            usuarioDAO.actualizarFotoUrl(user.getId(), publicUrl);
            user.setFotoUrl(publicUrl);
            request.getSession().setAttribute("usuario", user);

            // Responder OK
            response.setContentType("text/plain");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("Foto actualizada con éxito.");
            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            System.err.println("ERROR FATAL en UploadAvatarServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error interno del servidor al procesar la imagen: " + e.getMessage());
        }
    }

    // Método auxiliar: resuelve y crea la carpeta base si es necesario
    private Path resolveAvatarBaseDir(HttpServletRequest request) throws IOException {
        // 1) Variable de entorno AVATAR_UPLOAD_DIR
        String envDir = System.getenv("AVATAR_UPLOAD_DIR");
        if (envDir != null && !envDir.trim().isEmpty()) {
            Path p = Paths.get(envDir).toAbsolutePath().normalize();
            if (!Files.exists(p)) Files.createDirectories(p);
            return p;
        }

        // 2) context-param avatar.upload.dir en web.xml
        String ctxParam = getServletContext().getInitParameter("avatar.upload.dir");
        if (ctxParam != null && !ctxParam.trim().isEmpty()) {
            Path p = Paths.get(ctxParam).toAbsolutePath().normalize();
            if (!Files.exists(p)) Files.createDirectories(p);
            return p;
        }

        // 3) Fallback: directorio en el HOME del usuario
        String userHome = System.getProperty("user.home");
        Path defaultDir = Paths.get(userHome, "panaderia_uploads", "avatars").toAbsolutePath().normalize();
        if (!Files.exists(defaultDir)) Files.createDirectories(defaultDir);
        return defaultDir;
    }
}