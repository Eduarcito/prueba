package com.panaderia.model;

public class Usuario {
    private int id;
    private String nombre;
    private String apellido;
    private String username;
    private String passwordHash;
    private String telefono;
    private String direccion;
    private String rol;
    private boolean activo;

    // Nuevos campos para credenciales temporales
    private boolean usernameTemporal;
    private boolean passwordTemporal;

    // Getters
    public int getId() { return id; }
    public String getNombre() { return nombre; }
    public String getApellido() { return apellido; }
    public String getUsername() { return username; }
    public String getPasswordHash() { return passwordHash; }
    public String getTelefono() { return telefono; }
    public String getDireccion() { return direccion; }
    public String getRol() { return rol; }
    public boolean isActivo() { return activo; }
    public boolean isUsernameTemporal() { return usernameTemporal; }
    public boolean isPasswordTemporal() { return passwordTemporal; }

    // Setters
    public void setId(int id) { this.id = id; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public void setApellido(String apellido) { this.apellido = apellido; }
    public void setUsername(String username) { this.username = username; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    public void setDireccion(String direccion) { this.direccion = direccion; }
    public void setRol(String rol) { this.rol = rol; }
    public void setActivo(boolean activo) { this.activo = activo; }
    public void setUsernameTemporal(boolean usernameTemporal) { this.usernameTemporal = usernameTemporal; }
    public void setPasswordTemporal(boolean passwordTemporal) { this.passwordTemporal = passwordTemporal; }
}
