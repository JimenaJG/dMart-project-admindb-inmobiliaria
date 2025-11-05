USE DataMartAltosDelValle;
GO


--  HECHO CONTRATO
-- =====================================================
IF OBJECT_ID('dbo.Fact_Contrato','U') IS NOT NULL
    DROP TABLE dbo.Fact_Contrato;
GO

CREATE TABLE dbo.Fact_Contrato (
    IdContratoDW INT IDENTITY(1,1) PRIMARY KEY,
    id_original INT NOT NULL,
    IdAgenteDW INT NOT NULL,
    IdClienteDW INT NULL,
    IdRolDW INT NULL,
    IdPropiedadDW INT NOT NULL,
    IdTipoInmuebleDW INT NOT NULL,
    IdEstadoPropiedadDW INT NOT NULL,
    IdTipoContratoDW INT NOT NULL,
    IdEstadoContratoDW INT NOT NULL,
    IdTiempoFirma INT NULL,
    IdTiempoInicio INT NOT NULL,
    IdTiempoFin INT NOT NULL,
    IdTiempoPago INT NULL,
    MontoTotalContrato MONEY,
    DepositoPorAlquiler MONEY,
    PorcentajeComision FLOAT,
    MontoComision MONEY,
    ContratoFinalizado BIT DEFAULT(0),
    DuracionDias INT,
    DuracionMeses INT,
    DuracionCuatrimestres INT,
    DuracionAnios INT,


    FOREIGN KEY (IdAgenteDW) REFERENCES dbo.Dim_Agente(IdAgenteDW),
    FOREIGN KEY (IdClienteDW) REFERENCES dbo.Dim_Cliente(IdClienteDW),
    FOREIGN KEY (IdRolDW) REFERENCES dbo.Dim_Rol(IdRolDW),
    FOREIGN KEY (IdPropiedadDW) REFERENCES dbo.Dim_Propiedad(IdPropiedadDW),
    FOREIGN KEY (IdTipoInmuebleDW) REFERENCES dbo.Dim_TipoInmueble(IdTipoInmuebleDW),
    FOREIGN KEY (IdEstadoPropiedadDW) REFERENCES dbo.Dim_EstadoPropiedad(IdEstadoPropiedadDW),
    FOREIGN KEY (IdTipoContratoDW) REFERENCES dbo.Dim_TipoContrato(IdTipoContratoDW),
    FOREIGN KEY (IdEstadoContratoDW) REFERENCES dbo.Dim_EstadoContrato(IdEstadoContratoDW),
    FOREIGN KEY (IdTiempoFirma) REFERENCES dbo.Dim_Tiempo(IdTiempo),
    FOREIGN KEY (IdTiempoInicio) REFERENCES dbo.Dim_Tiempo(IdTiempo),
    FOREIGN KEY (IdTiempoFin) REFERENCES dbo.Dim_Tiempo(IdTiempo),
    FOREIGN KEY (IdTiempoPago) REFERENCES dbo.Dim_Tiempo(IdTiempo)
);
GO

--  HECHO PROPIEDAD
-- =====================================================
IF OBJECT_ID('dbo.Fact_Propiedad', 'U') IS NOT NULL
    DROP TABLE dbo.Fact_Propiedad;
GO

  CREATE TABLE dbo.Fact_Propiedad (
    IdPropiedadDW INT PRIMARY KEY,
    IdEstadoPropiedadDW INT NOT NULL,
    FOREIGN KEY (IdPropiedadDW) REFERENCES dbo.Dim_Propiedad(IdPropiedadDW),
    FOREIGN KEY (IdEstadoPropiedadDW) REFERENCES dbo.Dim_EstadoPropiedad(IdEstadoPropiedadDW)
  );
GO



USE DataMartAltosDelValle;
GO

-- ÍNDICES DE OPTIMIZACIÓN 
-- =====================================================
CREATE INDEX IX_Fact_Contrato_id_original ON dbo.Fact_Contrato(id_original);
CREATE INDEX IX_Fact_Contrato_Agente ON dbo.Fact_Contrato(IdAgenteDW);
CREATE INDEX IX_Fact_Contrato_TiempoInicio ON dbo.Fact_Contrato(IdTiempoInicio);
CREATE INDEX IX_Fact_Contrato_TiempoFin ON dbo.Fact_Contrato(IdTiempoFin);
CREATE INDEX IX_Fact_Contrato_EstadoTipo ON dbo.Fact_Contrato(IdEstadoContratoDW, IdTipoContratoDW);
CREATE INDEX IX_Fact_Contrato_PropiedadCliente ON dbo.Fact_Contrato(IdPropiedadDW, IdClienteDW);
GO

