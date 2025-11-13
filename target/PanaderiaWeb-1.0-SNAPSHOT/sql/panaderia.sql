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
    activo BIT DEFAULT 1,
    username_temporal VARCHAR(50) NULL,
    password_temporal VARCHAR(255) NULL
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
CREATE TYPE DetalleVentaType AS TABLE
(
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    subtotal_linea DECIMAL(10,2)
);
GO
INSERT INTO Productos (nombre, tipo, precio_unitario, stock_actual, categoria, imagen_url)
VALUES
('Concha', 'pan Dulce', 0.25, 0, 'Panadería', NULL),
('Maria luisa', 'Pan Dulce', 0.30, 0, 'Panadería', NULL),
('Quesadilla', 'Pan Dulce', 0.35, 0, 'Panaderia', NULL),
('Roseta', 'Pan Dulce', 0.20, 0, 'Panaderia', NULL);

INSERT INTO Produccion (cantidad_producida, id_panadero, id_producto)
VALUES (200, 2, 1),
       (200, 2, 2),
       (200, 2, 3),
       (200, 2, 4);

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

CREATE PROCEDURE sp_RegistrarVenta
    @tipo_pago VARCHAR(20),
    @id_cajero INT,
    @detalleVenta DetalleVentaType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @idVenta INT;
        DECLARE @total DECIMAL(10,2);

        SELECT @total = ISNULL(SUM(subtotal_linea), 0) FROM @detalleVenta;

        INSERT INTO Ventas (fecha_hora, total, tipo_pago, id_cajero)
        VALUES (GETDATE(), @total, @tipo_pago, @id_cajero);

        SET @idVenta = SCOPE_IDENTITY();

        INSERT INTO DetalleVenta (cantidad, precio_unitario, subtotal_linea, id_venta, id_producto)
        SELECT cantidad, precio_unitario, subtotal_linea, @idVenta, id_producto
        FROM @detalleVenta;

        UPDATE p
        SET p.stock_actual = p.stock_actual - d.cantidad
        FROM Productos p
        INNER JOIN @detalleVenta d ON p.id_producto = d.id_producto;

        COMMIT TRANSACTION;

        SELECT @idVenta AS idVentaGenerado;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('sp_RegistrarVenta failed: %s', 16, 1, @msg);
    END CATCH
END;
GO

BEGIN TRANSACTION;
DECLARE @idVenta INT;

INSERT INTO Ventas (fecha_hora, total, tipo_pago, id_cajero)
VALUES (GETDATE(), 110.00, 'Efectivo', 3);

SET @idVenta = SCOPE_IDENTITY();

INSERT INTO DetalleVenta (cantidad, precio_unitario, subtotal_linea, id_venta, id_producto)
VALUES (100, 0.25, 25.00, @idVenta, 1),
       (100, 0.30, 30.00, @idVenta, 2),
       (100, 0.35, 35.00, @idVenta, 3),
       (100, 0.20, 20.00, @idVenta, 4);

UPDATE Productos SET stock_actual = stock_actual - 2 WHERE id_producto = 1;
UPDATE Productos SET stock_actual = stock_actual - 1 WHERE id_producto = 3;

COMMIT TRANSACTION;

SELECT*FROM Usuarios;
SELECT*FROM Productos;
SELECT*FROM Produccion;
SELECT*FROM Ventas;
SELECT*FROM DetalleVenta;