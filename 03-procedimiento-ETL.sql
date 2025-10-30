-- PROCEDIMIENTO: Ejecutar_ETL_DM_Contratos
-- Extrae y carga datos desde la BD AltosDelValle

CREATE OR ALTER PROCEDURE dbo.Ejecutar_ETL_DM_Contratos
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRAN;

  BEGIN TRY
    -- DIMENSIONES
    MERGE Dim_Agente AS T
    USING (
      SELECT a.identificacion AS IdAgente,
             TRIM(a.nombre + ' ' + a.apellido1 + ' ' + ISNULL(a.apellido2,'')) AS NombreCompleto,
             a.telefono, a.estado
      FROM AltosDelValle.dbo.Agente a
    ) AS S
    ON T.IdAgente = S.IdAgente
    WHEN MATCHED THEN UPDATE SET NombreCompleto = S.NombreCompleto, Telefono = S.Telefono, Estado = S.Estado
    WHEN NOT MATCHED THEN INSERT (IdAgente, NombreCompleto, Telefono, Estado)
      VALUES (S.IdAgente, S.NombreCompleto, S.Telefono, S.Estado);

    MERGE Dim_Cliente AS T
    USING (
      SELECT c.identificacion AS IdCliente,
             TRIM(c.nombre + ' ' + c.apellido1 + ' ' + ISNULL(c.apellido2,'')) AS NombreCompleto,
             c.telefono
      FROM AltosDelValle.dbo.Cliente c
    ) AS S
    ON T.IdCliente = S.IdCliente
    WHEN MATCHED THEN UPDATE SET NombreCompleto = S.NombreCompleto, Telefono = S.Telefono
    WHEN NOT MATCHED THEN INSERT (IdCliente, NombreCompleto, Telefono)
      VALUES (S.IdCliente, S.NombreCompleto, S.Telefono);

    MERGE Dim_Rol AS T
    USING (SELECT idRol, nombre FROM AltosDelValle.dbo.TipoRol) AS S
    ON T.IdRol = S.idRol
    WHEN MATCHED THEN UPDATE SET NombreRol = S.nombre
    WHEN NOT MATCHED THEN INSERT (IdRol, NombreRol) VALUES (S.idRol, S.nombre);

    MERGE Dim_Propiedad AS T
    USING (
      SELECT p.idPropiedad, p.ubicacion, p.precio, ti.nombre AS TipoInmueble, ep.nombre AS EstadoPropiedad
      FROM AltosDelValle.dbo.Propiedad p
      JOIN AltosDelValle.dbo.TipoInmueble ti ON ti.idTipoInmueble = p.idTipoInmueble
      JOIN AltosDelValle.dbo.EstadoPropiedad ep ON ep.idEstadoPropiedad = p.idEstado
    ) AS S
    ON T.IdPropiedad = S.idPropiedad
    WHEN MATCHED THEN UPDATE 
      SET Ubicacion = S.ubicacion, Precio = S.precio, TipoInmueble = S.TipoInmueble, EstadoPropiedad = S.EstadoPropiedad
    WHEN NOT MATCHED THEN INSERT (IdPropiedad, Ubicacion, Precio, TipoInmueble, EstadoPropiedad)
      VALUES (S.idPropiedad, S.ubicacion, S.precio, S.TipoInmueble, S.EstadoPropiedad);

    MERGE Dim_TipoContrato AS T
    USING (SELECT idTipoContrato, nombre FROM AltosDelValle.dbo.TipoContrato) AS S
    ON T.IdTipoContrato = S.idTipoContrato
    WHEN MATCHED THEN UPDATE SET Nombre = S.nombre
    WHEN NOT MATCHED THEN INSERT (IdTipoContrato, Nombre) VALUES (S.idTipoContrato, S.nombre);


    -- DIM_TIEMPO (para todas las fechas del contrato)

    INSERT INTO Dim_Tiempo (Fecha, Dia, Mes, NombreMes, Trimestre, Anio)
    SELECT DISTINCT 
      CAST(fechaInicio AS DATE),
      DAY(fechaInicio), MONTH(fechaInicio), DATENAME(MONTH, fechaInicio),
      CASE WHEN MONTH(fechaInicio) BETWEEN 1 AND 3 THEN 1
           WHEN MONTH(fechaInicio) BETWEEN 4 AND 6 THEN 2
           WHEN MONTH(fechaInicio) BETWEEN 7 AND 9 THEN 3 ELSE 4 END,
      YEAR(fechaInicio)
    FROM AltosDelValle.dbo.Contrato c
    WHERE NOT EXISTS (SELECT 1 FROM Dim_Tiempo t WHERE t.Fecha = CAST(c.fechaInicio AS DATE));

    INSERT INTO Dim_Tiempo (Fecha, Dia, Mes, NombreMes, Trimestre, Anio)
    SELECT DISTINCT 
      CAST(fechaFin AS DATE),
      DAY(fechaFin), MONTH(fechaFin), DATENAME(MONTH, fechaFin),
      CASE WHEN MONTH(fechaFin) BETWEEN 1 AND 3 THEN 1
           WHEN MONTH(fechaFin) BETWEEN 4 AND 6 THEN 2
           WHEN MONTH(fechaFin) BETWEEN 7 AND 9 THEN 3 ELSE 4 END,
      YEAR(fechaFin)
    FROM AltosDelValle.dbo.Contrato c
    WHERE NOT EXISTS (SELECT 1 FROM Dim_Tiempo t WHERE t.Fecha = CAST(c.fechaFin AS DATE));

    INSERT INTO Dim_Tiempo (Fecha, Dia, Mes, NombreMes, Trimestre, Anio)
    SELECT DISTINCT 
      CAST(fechaFirma AS DATE),
      DAY(fechaFirma), MONTH(fechaFirma), DATENAME(MONTH, fechaFirma),
      CASE WHEN MONTH(fechaFirma) BETWEEN 1 AND 3 THEN 1
           WHEN MONTH(fechaFirma) BETWEEN 4 AND 6 THEN 2
           WHEN MONTH(fechaFirma) BETWEEN 7 AND 9 THEN 3 ELSE 4 END,
      YEAR(fechaFirma)
    FROM AltosDelValle.dbo.Contrato c
    WHERE NOT EXISTS (SELECT 1 FROM Dim_Tiempo t WHERE t.Fecha = CAST(c.fechaFirma AS DATE));

    INSERT INTO Dim_Tiempo (Fecha, Dia, Mes, NombreMes, Trimestre, Anio)
    SELECT DISTINCT 
      CAST(fechaPago AS DATE),
      DAY(fechaPago), MONTH(fechaPago), DATENAME(MONTH, fechaPago),
      CASE WHEN MONTH(fechaPago) BETWEEN 1 AND 3 THEN 1
           WHEN MONTH(fechaPago) BETWEEN 4 AND 6 THEN 2
           WHEN MONTH(fechaPago) BETWEEN 7 AND 9 THEN 3 ELSE 4 END,
      YEAR(fechaPago)
    FROM AltosDelValle.dbo.Contrato c
    WHERE fechaPago IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM Dim_Tiempo t WHERE t.Fecha = CAST(c.fechaPago AS DATE));

    -- FACT_CONTRATO 
    INSERT INTO Fact_Contrato (
        IdContrato, MontoTotal, Deposito, DuracionMeses, Estado, PorcentajeComision,
        IdAgente, IdPropiedad, IdTipoContrato, 
        IdTiempoFirma, IdTiempoInicio, IdTiempoFin, IdTiempoPago
    )
    SELECT 
        c.idContrato, c.montoTotal, c.deposito,
        DATEDIFF(MONTH, c.fechaInicio, c.fechaFin),
        c.estado, c.porcentajeComision,
        c.idAgente, c.idPropiedad, c.idTipoContrato,
        (SELECT TOP 1 IdTiempo FROM Dim_Tiempo WHERE Fecha = CAST(c.fechaFirma AS DATE)),
        (SELECT TOP 1 IdTiempo FROM Dim_Tiempo WHERE Fecha = CAST(c.fechaInicio AS DATE)),
        (SELECT TOP 1 IdTiempo FROM Dim_Tiempo WHERE Fecha = CAST(c.fechaFin AS DATE)),
        (SELECT TOP 1 IdTiempo FROM Dim_Tiempo WHERE Fecha = CAST(c.fechaPago AS DATE))
    FROM AltosDelValle.dbo.Contrato c
    WHERE NOT EXISTS (SELECT 1 FROM Fact_Contrato f WHERE f.IdContrato = c.idContrato);


    -- FACT_CLIENTECONTRATO

    INSERT INTO Fact_ClienteContrato (IdContrato, IdCliente, IdRol)
    SELECT cc.idContrato, cc.identificacion, cc.idRol
    FROM AltosDelValle.dbo.ClienteContrato cc
    WHERE NOT EXISTS (
      SELECT 1 FROM Fact_ClienteContrato fcc
      WHERE fcc.IdContrato = cc.idContrato AND fcc.IdCliente = cc.identificacion
    );

    COMMIT TRAN;
    PRINT 'ETL ejecutado correctamente.';
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    PRINT ' Error en ETL: ' + ERROR_MESSAGE();
  END CATCH
END;
GO


-- Ejecuta el ETL para traer los datos de AltosdelValle
USE DataMartAltosdelValle;
EXEC Ejecutar_ETL_DM_Contratos
GO