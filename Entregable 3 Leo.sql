-- ----------------------------------------------------------------------------
-- SCRIPT DE DESPLIEGUE: BASE DE DATOS TECHSTORE
-- Entorno: Microsoft SQL Server (T-SQL)
-- Descripción: Archivo SQL para la inicialización y carga de datos del modelo.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- PASO 1: LIMPIEZA DEL ESQUEMA (Reverse Order)
-- ----------------------------------------------------------------------------
-- Borrado de las entidades para evitar conflictos de Foreign Keys.
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
GO

-- ----------------------------------------------------------------------------
-- PASO 2: DEFINICIÓN DDL DE TABLAS Y RESTRICCIONES
-- ----------------------------------------------------------------------------

-- Dimensión Categorias
CREATE TABLE categorias (
    id_categoria INT NOT NULL,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200) NULL,
    CONSTRAINT pk_tbl_categorias PRIMARY KEY (id_categoria)
);
GO

-- Dimensión Clientes
CREATE TABLE clientes (
    id_cliente INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NULL,
    ciudad VARCHAR(50) NULL,
    fecha_registro DATE NOT NULL,
    CONSTRAINT pk_tbl_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT uq_email_cliente UNIQUE (email)
);
GO

-- Dimensión Productos
CREATE TABLE productos (
    id_producto INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL CONSTRAINT def_stock_cero DEFAULT 0,
    activo BIT NOT NULL CONSTRAINT def_prod_activo DEFAULT 1,
    CONSTRAINT pk_tbl_productos PRIMARY KEY (id_producto),
    CONSTRAINT fk_prod_ref_categoria FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);
GO

-- Hechos: Ventas transaccionales
CREATE TABLE ventas (
    id_venta INT NOT NULL,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,
    CONSTRAINT pk_tbl_ventas PRIMARY KEY (id_venta),
    CONSTRAINT fk_venta_ref_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_venta_ref_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
GO

-- ----------------------------------------------------------------------------
-- PASO 3: POBLACIÓN DE DATOS (INSERTS)
-- ----------------------------------------------------------------------------

-- Insertar jerarquías de productos
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) 
VALUES
    (1, 'Computación', 'Laptops, PCs y monitores'),
    (2, 'Accesorios', 'Periféricos y complementos'),
    (3, 'Audio', 'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');
GO

-- Insertar base de clientes
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) 
VALUES
    (1, 'María López', 'maria@mail.com', 'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz', 'carlos@mail.com', 'Córdoba', '2024-01-10'),
    (3, 'Ana Gómez', 'ana@mail.com', 'Rosario', '2024-02-01'),
    (4, 'Pedro Sanz', 'pedro@mail.com', 'Mendoza', '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com', 'Tucumán', '2024-03-01');
GO

-- Insertar maestro de productos
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) 
VALUES
    (1, 'Laptop Pro 15', 1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico', 2, 28.00, 80, 1),
    (3, 'Monitor 4K 27', 1, 450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3, 120.00, 35, 1),
    (5, 'SSD Externo 1TB', 4, 130.00, 18, 1),
    (6, 'Teclado Mecánico', 2, 95.00, 40, 1);
GO

-- Insertar registro de transacciones
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) 
VALUES
    (1, 1, 1, 2, 1200.00, '2024-03-05'),
    (2, 2, 2, 5, 28.00, '2024-03-06'),
    (3, 3, 3, 1, 450.00, '2024-03-07'),
    (4, 1, 4, 2, 120.00, '2024-03-08'),
    (5, 4, 5, 3, 130.00, '2024-03-10'),
    (6, 2, 6, 4, 95.00, '2024-03-11'),
    (7, 5, 1, 1, 1200.00, '2024-03-12'),
    (8, 3, 2, 8, 28.00, '2024-03-13'),
    (9, 4, 4, 1, 120.00, '2024-03-14'),
    (10, 5, 3, 2, 450.00, '2024-03-15');
GO

-- ----------------------------------------------------------------------------
-- PASO 4: COMPROBACIÓN FINAL
-- ----------------------------------------------------------------------------
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
GO