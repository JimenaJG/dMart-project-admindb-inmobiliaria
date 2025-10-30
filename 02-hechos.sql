-- HECHOS

--  FACT_CONTRATO 
USE DataMartAltosdelValle;
GO

IF OBJECT_ID('dbo.Fact_Contrato', 'U') IS NOT NULL
    DROP TABLE dbo.Fact_Contrato;
GO

CREATE TABLE Fact_Contrato (
  IdContratoDW INT IDENTITY(1,1) PRIMARY KEY,
  IdContrato INT NOT NULL UNIQUE,
  MontoTotal MONEY,
  Deposito MONEY,
  DuracionMeses INT,
  Estado VARCHAR(30),
  PorcentajeComision DECIMAL(5,2),
  IdAgente INT,
  IdPropiedad INT,
  IdTipoContrato INT,
  IdTiempoFirma INT,
  IdTiempoInicio INT,
  IdTiempoFin INT,
  IdTiempoPago INT,
  FOREIGN KEY (IdAgente) REFERENCES Dim_Agente(IdAgente),
  FOREIGN KEY (IdPropiedad) REFERENCES Dim_Propiedad(IdPropiedad),
  FOREIGN KEY (IdTipoContrato) REFERENCES Dim_TipoContrato(IdTipoContrato),
  FOREIGN KEY (IdTiempoFirma) REFERENCES Dim_Tiempo(IdTiempo),
  FOREIGN KEY (IdTiempoInicio) REFERENCES Dim_Tiempo(IdTiempo),
  FOREIGN KEY (IdTiempoFin) REFERENCES Dim_Tiempo(IdTiempo),
  FOREIGN KEY (IdTiempoPago) REFERENCES Dim_Tiempo(IdTiempo)
);
GO


--- FACT_CLIENTECONTRATO
CREATE TABLE Fact_ClienteContrato (
  IdClienteContratoDW INT IDENTITY(1,1) PRIMARY KEY,
  IdContrato INT NOT NULL,
  IdCliente INT NOT NULL,
  IdRol INT NOT NULL,
  FOREIGN KEY (IdContrato) REFERENCES Fact_Contrato(IdContrato),
  FOREIGN KEY (IdCliente) REFERENCES Dim_Cliente(IdCliente),
  FOREIGN KEY (IdRol) REFERENCES Dim_Rol(IdRol)
);