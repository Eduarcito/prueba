CREATE DATABASE panaderia;

use panaderia;

CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(150),
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('Administrador', 'Panadero', 'Empleado')),
    activo BIT DEFAULT 1
);
GO

CREATE TABLE Productos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50), 
    precio_unitario DECIMAL(10, 2) NOT NULL,
    stock_actual INT DEFAULT 0,
    categoria VARCHAR(50) DEFAULT 'Pan', 
    imagen_url VARCHAR(255)
);
GO

CREATE TABLE Produccion (
    id_produccion INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    cantidad_producida INT NOT NULL,

    id_panadero INT NOT NULL,
    id_producto INT NOT NULL,

    FOREIGN KEY (id_panadero) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);
GO

CREATE TABLE Ventas (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    total DECIMAL(10, 2) NOT NULL,
    tipo_pago VARCHAR(20),
    id_cajero INT NOT NULL,

    FOREIGN KEY (id_cajero) REFERENCES Usuarios(id_usuario)
);
GO

CREATE TABLE DetalleVenta (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal_linea DECIMAL(10, 2) NOT NULL,

    id_venta INT NOT NULL,
    id_producto INT NOT NULL,

    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);
GO
--actualizar el stock cuando se registre una nueva producción
CREATE TRIGGER trg_AumentarStock_Produccion
ON Produccion
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.stock_actual = p.stock_actual + i.cantidad_producida
    FROM Productos p
    INNER JOIN inserted i ON p.id_producto = i.id_producto;
END;
GO