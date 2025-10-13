package com.panaderia.model;

/**
 * Representa la tabla Usuarios en la base de datos.
 */
public class Usuario {
    
    private int idUsuario;
    private String nombre;
    private String username;
    // La contraseña aquí puede ser el hash o la contraseña ingresada
    private String passwordHash; 
    private String rol;
    private boolean activo;
    
    // Constructor vacío
    public Usuario() {}

    // Constructor completo
    public Usuario(int idUsuario, String nombre, String username, String passwordHash, String rol, boolean activo) {
        this.idUsuario = idUsuario;
        this.nombre = nombre;
        this.username = username;
        this.passwordHash = passwordHash;
        this.rol = rol;
        this.activo = activo;
    }

    // --- Getters y Setters ---
    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }
}