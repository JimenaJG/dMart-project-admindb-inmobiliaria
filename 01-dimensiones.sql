USE DataMartAltosDelValle;
GO


-- DIMENSIÓN AGENTE
-- =====================================================
IF OBJECT_ID('dbo.Dim_Agente','U') IS NULL
CREATE TABLE dbo.Dim_Agente (
  IdAgenteDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT UNIQUE NOT NULL,
  NombreCompleto VARCHAR(150) NOT NULL,
  Telefono VARCHAR(30),
  Estado BIT
);
GO


--  DIMENSIÓN CLIENTE
-- =====================================================
IF OBJECT_ID('dbo.Dim_Cliente','U') IS NULL
CREATE TABLE dbo.Dim_Cliente (
  IdClienteDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT UNIQUE NOT NULL,
  NombreCompleto VARCHAR(150) NOT NULL,
  Telefono VARCHAR(30),
  Estado BIT NULL
);
GO


-- DIMENSIÓN ROL DEL CLIENTE
-- =====================================================
IF OBJECT_ID('dbo.Dim_Rol','U') IS NULL
CREATE TABLE dbo.Dim_Rol (
  IdRolDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT UNIQUE NOT NULL,
  NombreRol VARCHAR(50),
);
GO 

-- DIMENSIÓN TIPO DE INMUEBLE
-- =====================================================
IF OBJECT_ID('dbo.Dim_TipoInmueble','U') IS NULL
CREATE TABLE dbo.Dim_TipoInmueble (
  IdTipoInmuebleDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT UNIQUE NOT NULL,
  NombreTipo VARCHAR(80)
);
GO


--  DIMENSIÓN ESTADO DE LA PROPIEDAD
-- =====================================================
IF OBJECT_ID('dbo.Dim_EstadoPropiedad','U') IS NULL
CREATE TABLE dbo.Dim_EstadoPropiedad (
  IdEstadoPropiedadDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT UNIQUE NOT NULL,
  NombreEstado VARCHAR(80)
);
GO

-- DIMENSIÓN PROPIEDAD
-- =====================================================
IF OBJECT_ID('dbo.Dim_Propiedad','U') IS NULL
CREATE TABLE dbo.Dim_Propiedad (
  IdPropiedadDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT UNIQUE NOT NULL,  
  Ubicacion VARCHAR(180),
  Precio MONEY
);
GO


--  DIMENSIÓN TIPO DE CONTRATO
-- =====================================================
IF OBJECT_ID('dbo.Dim_TipoContrato','U') IS NULL
CREATE TABLE dbo.Dim_TipoContrato (
  IdTipoContratoDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT UNIQUE NOT NULL,
  Nombre VARCHAR(60)
);
GO


--  DIMENSIÓN ESTADO DEL CONTRATO
-- =====================================================
IF OBJECT_ID('dbo.Dim_EstadoContrato','U') IS NULL
CREATE TABLE dbo.Dim_EstadoContrato (
  IdEstadoContratoDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT NULL,  
  NombreEstado VARCHAR(50) NOT NULL
);
GO


-- DIMENSIÓN FACTURA
-- =====================================================
IF OBJECT_ID('dbo.Dim_Factura','U') IS NULL
CREATE TABLE dbo.Dim_Factura (
  IdFacturaDW INT IDENTITY(1,1) PRIMARY KEY,
  id_original INT NOT NULL,
  FechaEmision DATE,
  FechaPago DATE,
  Monto MONEY,
  EstadoPago VARCHAR(50),   
  IdClienteDW INT NULL      
);
GO


--  DIMENSIÓN TIEMPO
-- =====================================================
IF OBJECT_ID('dbo.Dim_Tiempo','U') IS NULL
CREATE TABLE dbo.Dim_Tiempo (
  IdTiempo INT PRIMARY KEY, -- formato AAAAMMDD
  Fecha DATE NOT NULL,
  Dia INT NOT NULL,
  Mes INT NOT NULL,
  NombreMes VARCHAR(15) NOT NULL,
  NombreDia VARCHAR(15) NOT NULL,
  Trimestre INT NOT NULL,
  Anio INT NOT NULL
);
GO

--  Trigger para insertar IdTiempo automáticamente
CREATE OR ALTER TRIGGER dbo.tr_dim_tiempo_insert
ON dbo.Dim_Tiempo
INSTEAD OF INSERT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.Dim_Tiempo (IdTiempo, Fecha, Dia, Mes, NombreMes, NombreDia, Trimestre, Anio)
  SELECT 
    CASE 
      WHEN i.Fecha = '1900-01-01' THEN 0
      ELSE CAST(CONCAT(YEAR(i.Fecha), RIGHT('00'+CAST(MONTH(i.Fecha) AS VARCHAR(2)),2), RIGHT('00'+CAST(DAY(i.Fecha) AS VARCHAR(2)),2)) AS INT)
    END,
    i.Fecha,
    i.Dia,
    i.Mes,
    i.NombreMes,
    i.NombreDia,
    i.Trimestre,
    i.Anio
  FROM inserted i;
END;
GO


USE DataMartAltosDelValle;
GO

;WITH N AS (
  SELECT 0 AS n
  UNION ALL SELECT 1
  UNION ALL SELECT 2
  UNION ALL SELECT 3
  UNION ALL SELECT 4
  UNION ALL SELECT 5
  UNION ALL SELECT 6
  UNION ALL SELECT 7
  UNION ALL SELECT 8
  UNION ALL SELECT 9
),
Tally AS (
  SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS d
  FROM N a CROSS JOIN N b CROSS JOIN N c CROSS JOIN N d  -- ~27 años de días
)
INSERT INTO dbo.Dim_Tiempo (Fecha, Dia, Mes, NombreMes, NombreDia, Trimestre, Anio)
SELECT
  DATEADD(DAY, d, '2000-01-01'),
  DAY(DATEADD(DAY, d, '2000-01-01')),
  MONTH(DATEADD(DAY, d, '2000-01-01')),
  FORMAT(DATEADD(DAY, d, '2000-01-01'), 'MMMM', 'es-ES'),
  FORMAT(DATEADD(DAY, d, '2000-01-01'), 'dddd', 'es-ES'),
  CASE 
    WHEN MONTH(DATEADD(DAY, d, '2000-01-01')) BETWEEN 1 AND 3 THEN 1
    WHEN MONTH(DATEADD(DAY, d, '2000-01-01')) BETWEEN 4 AND 6 THEN 2
    WHEN MONTH(DATEADD(DAY, d, '2000-01-01')) BETWEEN 7 AND 9 THEN 3
    ELSE 4 
  END,
  YEAR(DATEADD(DAY, d, '2000-01-01'))
FROM Tally
WHERE DATEADD(DAY, d, '2000-01-01') <= '2035-12-31'
  AND NOT EXISTS (
    SELECT 1 FROM dbo.Dim_Tiempo t WHERE t.Fecha = DATEADD(DAY, d, '2000-01-01')
  );
GO


-- ÍNDICES DE OPTIMIZACIÓN
-- =====================================================
CREATE INDEX IX_Dim_Agente_id_original ON dbo.Dim_Agente(id_original);
CREATE INDEX IX_Dim_Cliente_id_original ON dbo.Dim_Cliente(id_original);
CREATE INDEX IX_Dim_Rol_id_original ON dbo.Dim_Rol(id_original);
CREATE INDEX IX_Dim_TipoInmueble_id_original ON dbo.Dim_TipoInmueble(id_original);
CREATE INDEX IX_Dim_EstadoPropiedad_id_original ON dbo.Dim_EstadoPropiedad(id_original);
CREATE INDEX IX_Dim_Propiedad_id_original ON dbo.Dim_Propiedad(id_original);
CREATE INDEX IX_Dim_TipoContrato_id_original ON dbo.Dim_TipoContrato(id_original);
CREATE INDEX IX_Dim_EstadoContrato_id_original ON dbo.Dim_EstadoContrato(id_original);
CREATE INDEX IX_Dim_Factura_id_original ON dbo.Dim_Factura(id_original);
CREATE INDEX IX_Dim_Tiempo_Fecha ON dbo.Dim_Tiempo(Fecha);
GO
