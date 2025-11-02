USE AltosDelValle;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


CREATE OR ALTER TRIGGER trg_dm_actualizar_contrato
ON dbo.Contrato
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    EXEC DataMartAltosDelValle.dbo.Ejecutar_ETL_DM_Contratos_Final;
END;
GO

CREATE OR ALTER TRIGGER trg_dm_actualizar_cliente
ON dbo.Cliente
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    EXEC DataMartAltosDelValle.dbo.Ejecutar_ETL_DM_Contratos_Final;
END;
GO

CREATE OR ALTER TRIGGER trg_dm_actualizar_agente
ON dbo.Agente
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    EXEC DataMartAltosDelValle.dbo.Ejecutar_ETL_DM_Contratos_Final;
END;
GO

CREATE OR ALTER TRIGGER trg_dm_actualizar_propiedad
ON dbo.Propiedad
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    EXEC DataMartAltosDelValle.dbo.Ejecutar_ETL_DM_Contratos_Final;
END;
GO

CREATE OR ALTER TRIGGER trg_dm_actualizar_clientecontrato
ON dbo.ClienteContrato
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    EXEC DataMartAltosDelValle.dbo.Ejecutar_ETL_DM_Contratos_Final;
END;
GO

CREATE OR ALTER TRIGGER trg_dm_actualizar_factura
ON dbo.Factura
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    EXEC DataMartAltosDelValle.dbo.Ejecutar_ETL_DM_Contratos_Final;
END;
GO
