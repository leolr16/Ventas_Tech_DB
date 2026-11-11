-- ----------------------------------------------------------------------------
-- SCRIPT DE DESPLIEGUE: BASE DE DATOS TECHSTORE (CON CONSULTAS ANALÍTICAS)
-- Entorno: Microsoft SQL Server (T-SQL)
-- Descripción: Archivo SQL para inicialización, carga de datos y análisis de negocio.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- PASO 1: LIMPIEZA DEL ESQUEMA (Reverse Order)
-- ----------------------------------------------------------------------------
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

INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Computación', 'Laptops, PCs y monitores'),
    (2, 'Accesorios', 'Periféricos y complementos'),
    (3, 'Audio', 'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');
GO

INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, 'María López', 'maria@mail.com', 'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz', 'carlos@mail.com', 'Córdoba', '2024-01-10'),
    (3, 'Ana Gómez', 'ana@mail.com', 'Rosario', '2024-02-01'),
    (4, 'Pedro Sanz', 'pedro@mail.com', 'Mendoza', '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com', 'Tucumán', '2024-03-01');
GO

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, 'Laptop Pro 15', 1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico', 2, 28.00, 80, 1),
    (3, 'Monitor 4K 27', 1, 450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3, 120.00, 35, 1),
    (5, 'SSD Externo 1TB', 4, 130.00, 18, 1),
    (6, 'Teclado Mecánico', 2, 95.00, 40, 1);
GO

INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
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
-- PASO 4: CONSULTAS DE NEGOCIO (ANÁLISIS)
-- ----------------------------------------------------------------------------

-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- Mide facturación global, volumen de transacciones y ticket promedio por mes.
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);
GO

-- CONSULTA 2: RANKING DE PRODUCTOS (TOP 5)
-- Identifica los artículos líderes en facturación.
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO

-- CONSULTA 3: CLIENTES RECURRENTES
-- Identifica compradores con más de una transacción (fidelidad).
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO

-- CONSULTA 4: PRODUCTOS POR ENCIMA / POR DEBAJO DEL PROMEDIO
-- Rendimiento de catálogo mediante CTE comparando vs media.
WITH TotalesPorProducto AS (
    SELECT 
        id_producto,
        SUM(cantidad * precio_unitario) AS total_producto
    FROM ventas
    GROUP BY id_producto
)
SELECT 
    id_producto,
    total_producto,
    CASE 
        WHEN total_producto >= (SELECT AVG(total_producto) FROM TotalesPorProducto) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_vs_promedio
FROM TotalesPorProducto
ORDER BY total_producto DESC;
GO

-- ----------------------------------------------------------------------------
-- BLOQUE DE CIERRE: 3 HALLAZGOS ESTRATÉGICOS DE NEGOCIO
-- ----------------------------------------------------------------------------
/*
HALLAZGO 1 - Alta concentración de facturación en el Producto 1:
El id_producto 1 (Laptop Pro 15) es el líder absoluto de ingresos con $3,600.00
facturados (3 unidades vendidas a $1,200.00 cada una), representando el 63.8%
del total comercializado por la tienda en marzo ($5,640.00).

HALLAZGO 2 - Fidelidad y recurrencia de la base de clientes:
El 80% de los clientes analizados (4 de 5: IDs 1, 2, 3 y 4) son recurrentes
con exactamente 2 pedidos cada uno en el mes, concentrando el 83.2% del total
facturado ($4,690.00). El cliente 1 lidera el gasto con $2,640.00.

HALLAZGO 3 - Asimetría en el rendimiento del catálogo comercial:
El promedio de facturación por producto fue de $940.00. Solo 2 productos
(id_producto 1 con $3,600.00 e id_producto 3 con $1,350.00) se ubicaron 'Por encima'
del promedio, mientras que los 4 productos restantes quedaron 'Por debajo',
evidenciando una alta dependencia de las ventas de computadoras y monitores [cite: 7].
*/
