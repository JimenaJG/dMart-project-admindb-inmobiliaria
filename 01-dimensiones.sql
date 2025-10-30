
   --- DIMENSIONES

--  DIM_AGENTE
CREATE TABLE Dim_Agente (
  IdAgente INT PRIMARY KEY,
  NombreCompleto VARCHAR(100),
  Telefono VARCHAR(20),
  Estado BIT
);

--  DIM_CLIENTE
CREATE TABLE Dim_Cliente (
  IdCliente INT PRIMARY KEY,
  NombreCompleto VARCHAR(100),
  Telefono VARCHAR(20)
);

-- DIM_ROL (Comprador, Vendedor, Inquilino, Arrendatario)
CREATE TABLE Dim_Rol (
  IdRol INT PRIMARY KEY,
  NombreRol VARCHAR(30)
);

-- DIM_PROPIEDAD
CREATE TABLE Dim_Propiedad (
  IdPropiedad INT PRIMARY KEY,
  Ubicacion VARCHAR(100),
  Precio MONEY,
  TipoInmueble VARCHAR(30),
  EstadoPropiedad VARCHAR(30)
);

-- DIM_TIPOCONTRATO
CREATE TABLE Dim_TipoContrato (
  IdTipoContrato INT PRIMARY KEY,
  Nombre VARCHAR(30)
);

-- DIM_TIEMPO
CREATE TABLE Dim_Tiempo (
  IdTiempo INT IDENTITY(1,1) PRIMARY KEY,
  Fecha DATE NULL,
  Dia INT,
  Mes INT,
  NombreMes VARCHAR(15),
  Trimestre INT,
  Anio INT
);