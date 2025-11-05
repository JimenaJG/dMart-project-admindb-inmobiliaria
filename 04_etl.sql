USE DataMartAltosDelValle;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- PROCEDIMIENTOS DE NORMALIZACIÓN
-- =============================================

-- Normalizar nombres de agentes
IF OBJECT_ID('NormalizarNombresAgentes', 'P') IS NOT NULL
    DROP PROCEDURE NormalizarNombresAgentes;
GO
CREATE PROCEDURE NormalizarNombresAgentes
AS
BEGIN
    UPDATE Dim_Agente
    SET NombreCompleto = UPPER(LTRIM(RTRIM(NombreCompleto)));
END;
GO

-- Normalizar nombres de clientes
IF OBJECT_ID('NormalizarNombresClientes', 'P') IS NOT NULL
    DROP PROCEDURE NormalizarNombresClientes;
GO
CREATE PROCEDURE NormalizarNombresClientes
AS
BEGIN
    UPDATE Dim_Cliente
    SET NombreCompleto = UPPER(LTRIM(RTRIM(NombreCompleto)));
END;
GO

-- Normalizar ubicaciones de propiedades
IF OBJECT_ID('NormalizarUbicacionPropiedades', 'P') IS NOT NULL
    DROP PROCEDURE NormalizarUbicacionPropiedades;
GO
CREATE PROCEDURE NormalizarUbicacionPropiedades
AS
BEGIN
    UPDATE Dim_Propiedad
    SET Ubicacion = UPPER(LTRIM(RTRIM(Ubicacion)));
END;
GO

-- Normalizar nombres de estados de contrato
IF OBJECT_ID('NormalizarEstadosContrato', 'P') IS NOT NULL
    DROP PROCEDURE NormalizarEstadosContrato;
GO
CREATE PROCEDURE NormalizarEstadosContrato
AS
BEGIN
    UPDATE Dim_EstadoContrato
    SET NombreEstado = UPPER(LTRIM(RTRIM(NombreEstado)));
END;
GO

USE DataMartAltosDelValle;
GO

IF OBJECT_ID('dbo.Ejecutar_ETL_DM_Contratos_Final', 'P') IS NOT NULL
    DROP PROCEDURE dbo.Ejecutar_ETL_DM_Contratos_Final;
GO

CREATE PROCEDURE dbo.Ejecutar_ETL_DM_Contratos_Final
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        PRINT'Iniciando proceso ETL de Contratos...';
        BEGIN TRANSACTION;

        ------------------------------------------------------------------
        -- 1. Registro especial en Dim_Tiempo (Desconocido)
        ------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM dbo.Dim_Tiempo WHERE IdTiempo = 0)
        BEGIN
            INSERT INTO dbo.Dim_Tiempo (IdTiempo, Fecha, Dia, Mes, NombreMes, NombreDia, Trimestre, Anio)
            VALUES (0, '1900-01-01', 1, 1, 'Desconocido', 'Desconocido', 0, 1900);
            PRINT'Registro especial insertado en Dim_Tiempo.';
        END;

        ------------------------------------------------------------------
        -- 2. Carga de Dimensiones desde AltosDelValle.dbo
        ------------------------------------------------------------------
        PRINT'Cargando dimensiones...';

        -- Agente
        MERGE dbo.Dim_Agente AS T
        USING (SELECT * FROM AltosDelValle.dbo.Agente) AS S
        ON T.id_original = S.identificacion
        WHEN MATCHED THEN 
            UPDATE SET T.NombreCompleto = LTRIM(RTRIM(S.nombre + ' ' + S.apellido1 + ISNULL(' ' + S.apellido2, ''))),
                        T.Telefono = S.telefono
        WHEN NOT MATCHED THEN
            INSERT (id_original, NombreCompleto, Telefono)
            VALUES (S.identificacion, LTRIM(RTRIM(S.nombre + ' ' + S.apellido1 + ISNULL(' ' + S.apellido2, ''))), S.telefono);
        PRINT'Dim_Agente cargada.';

        -- Cliente
        MERGE dbo.Dim_Cliente AS T
        USING (SELECT * FROM AltosDelValle.dbo.Cliente) AS S
        ON T.id_original = S.identificacion
        WHEN MATCHED THEN 
            UPDATE SET 
                T.NombreCompleto = LTRIM(RTRIM(S.nombre + ' ' + S.apellido1 + ISNULL(' ' + S.apellido2, ''))),
                T.Telefono = S.telefono,
                T.Estado = S.estado
        WHEN NOT MATCHED THEN
            INSERT (id_original, NombreCompleto, Telefono, Estado)
            VALUES (
                S.identificacion,
                LTRIM(RTRIM(S.nombre + ' ' + S.apellido1 + ISNULL(' ' + S.apellido2, ''))),
                S.telefono,
                S.estado
            );
        PRINT'Dim_Cliente cargada.';

        -- Rol
        MERGE dbo.Dim_Rol AS T
        USING (SELECT * FROM AltosDelValle.dbo.TipoRol) AS S
        ON T.id_original = S.idRol
        WHEN MATCHED THEN UPDATE SET T.NombreRol = S.nombre
        WHEN NOT MATCHED THEN INSERT (id_original, NombreRol) VALUES (S.idRol, S.nombre);
        PRINT'Dim_Rol cargada.';

        -- Tipo Inmueble
        MERGE dbo.Dim_TipoInmueble AS T
        USING (SELECT * FROM AltosDelValle.dbo.TipoInmueble) AS S
        ON T.id_original = S.idTipoInmueble
        WHEN MATCHED THEN UPDATE SET T.NombreTipo = S.nombre
        WHEN NOT MATCHED THEN INSERT (id_original, NombreTipo) VALUES (S.idTipoInmueble, S.nombre);
        PRINT'Dim_TipoInmueble cargada.';

        -- Estado Propiedad
        MERGE dbo.Dim_EstadoPropiedad AS T
        USING (SELECT * FROM AltosDelValle.dbo.EstadoPropiedad) AS S
        ON T.id_original = S.idEstadoPropiedad
        WHEN MATCHED THEN UPDATE SET T.NombreEstado = S.nombre
        WHEN NOT MATCHED THEN INSERT (id_original, NombreEstado) VALUES (S.idEstadoPropiedad, S.nombre);
        PRINT'Dim_EstadoPropiedad cargada.';

        -- Propiedad
        MERGE dbo.Dim_Propiedad AS T
        USING (SELECT * FROM AltosDelValle.dbo.Propiedad) AS S
        ON T.id_original = S.idPropiedad
        WHEN MATCHED THEN UPDATE SET T.Ubicacion = S.ubicacion, T.Precio = S.precio
        WHEN NOT MATCHED THEN INSERT (id_original, Ubicacion, Precio) VALUES (S.idPropiedad, S.ubicacion, S.precio);
        PRINT'Dim_Propiedad cargada.';

        -- Tipo Contrato
        MERGE dbo.Dim_TipoContrato AS T
        USING (SELECT * FROM AltosDelValle.dbo.TipoContrato) AS S
        ON T.id_original = S.idTipoContrato
        WHEN MATCHED THEN UPDATE SET T.Nombre = S.nombre
        WHEN NOT MATCHED THEN INSERT (id_original, Nombre) VALUES (S.idTipoContrato, S.nombre);
        PRINT'Dim_TipoContrato cargada.';

        -- Estado Contrato
        MERGE dbo.Dim_EstadoContrato AS T
        USING (
            SELECT DISTINCT estado AS NombreEstado
            FROM AltosDelValle.dbo.Contrato
            WHERE estado IS NOT NULL
        ) AS S
        ON T.NombreEstado = S.NombreEstado
        WHEN NOT MATCHED THEN INSERT (NombreEstado) VALUES (S.NombreEstado);
        PRINT'Dim_EstadoContrato cargada.';

        ------------------------------------------------------------------
        -- 3. Dim_Tiempo
        ------------------------------------------------------------------
        PRINT'Insertando fechas en Dim_Tiempo...';

        DECLARE @fechas TABLE (Fecha DATE);
        INSERT INTO @fechas(Fecha)
        SELECT fechaInicio FROM AltosDelValle.dbo.Contrato WHERE fechaInicio IS NOT NULL
        UNION SELECT fechaFin FROM AltosDelValle.dbo.Contrato WHERE fechaFin IS NOT NULL
        UNION SELECT fechaFirma FROM AltosDelValle.dbo.Contrato WHERE fechaFirma IS NOT NULL
        UNION SELECT fechaPago FROM AltosDelValle.dbo.Contrato WHERE fechaPago IS NOT NULL;

        INSERT INTO dbo.Dim_Tiempo (Fecha, Dia, Mes, NombreMes, NombreDia, Trimestre, Anio)
        SELECT 
            f.Fecha,
            DAY(f.Fecha),
            MONTH(f.Fecha),
            DATENAME(MONTH, f.Fecha),
            DATENAME(WEEKDAY, f.Fecha),
            CASE 
            WHEN MONTH(f.Fecha) BETWEEN 1 AND 3 THEN 1
            WHEN MONTH(f.Fecha) BETWEEN 4 AND 6 THEN 2
            WHEN MONTH(f.Fecha) BETWEEN 7 AND 9 THEN 3
                ELSE 4 END,
            YEAR(f.Fecha)
        FROM @fechas f
        WHERE NOT EXISTS (SELECT 1 FROM dbo.Dim_Tiempo t WHERE t.Fecha = f.Fecha);
        PRINT'Dim_Tiempo actualizada.';

        ------------------------------------------------------------------
        -- 4. Normalización
        ------------------------------------------------------------------
        PRINT'Normalizando datos...';
        EXEC NormalizarNombresAgentes;
        EXEC NormalizarNombresClientes;
        EXEC NormalizarUbicacionPropiedades;
        EXEC NormalizarEstadosContrato;
        PRINT'Datos normalizados.';

        ------------------------------------------------------------------
        -- 5. Carga de Hechos (Fact_Contrato)
        ------------------------------------------------------------------
        PRINT'Cargando hechos (Fact_Contrato)...';

        IF OBJECT_ID('tempdb..#DatosContratos') IS NOT NULL DROP TABLE #DatosContratos;

        SELECT DISTINCT
            c.idContrato AS id_original,
            a.IdAgenteDW,
            clienteRol.IdClienteDW,
            clienteRol.IdRolDW,
            p.IdPropiedadDW,
            ti.IdTipoInmuebleDW,
            ep.IdEstadoPropiedadDW,
            tc.IdTipoContratoDW,
            ec.IdEstadoContratoDW,
            COALESCE(tf.IdTiempo, 0) AS IdTiempoFirma,
            COALESCE(tiempoI.IdTiempo, tf.IdTiempo, tp.IdTiempo, 0) AS IdTiempoInicio,
            COALESCE(tiempoF.IdTiempo, tf.IdTiempo, tp.IdTiempo, 0) AS IdTiempoFin,
            COALESCE(tp.IdTiempo, tf.IdTiempo, 0) AS IdTiempoPago,
            c.montoTotal,
            ISNULL(c.deposito, 0) AS DepositoPorAlquiler,
            CASE 
                WHEN c.porcentajeComision < 0 THEN 0
                WHEN c.porcentajeComision > 20 THEN 20
                ELSE CAST(c.porcentajeComision AS FLOAT)
            END AS PorcentajeComisionProm,
            ROUND(c.montoTotal * 
                    CASE 
                        WHEN c.porcentajeComision < 0 THEN 0
                        WHEN c.porcentajeComision > 20 THEN 20
                        ELSE ISNULL(c.porcentajeComision, 0)
                    END / 100.0, 2) AS MontoComision,
            CASE WHEN UPPER(LTRIM(RTRIM(c.estado))) = 'FINALIZADO' THEN 1 ELSE 0 END AS ContratoFinalizado,
            DATEDIFF(DAY, c.fechaInicio, c.fechaFin) AS DuracionDias,
            DATEDIFF(MONTH, c.fechaInicio, c.fechaFin) AS DuracionMeses,
            DATEDIFF(MONTH, c.fechaInicio, c.fechaFin) / 4 AS DuracionCuatrimestres,
            DATEDIFF(YEAR, c.fechaInicio, c.fechaFin) AS DuracionAnios
        INTO #DatosContratos
        FROM AltosDelValle.dbo.Contrato c
        JOIN dbo.Dim_Agente a ON a.id_original = c.idAgente
        JOIN dbo.Dim_Propiedad p ON p.id_original = c.idPropiedad
        JOIN AltosDelValle.dbo.Propiedad pr ON pr.idPropiedad = c.idPropiedad
        JOIN dbo.Dim_TipoInmueble ti ON ti.id_original = pr.idTipoInmueble
        JOIN dbo.Dim_EstadoPropiedad ep ON ep.id_original = pr.idEstado
        JOIN dbo.Dim_TipoContrato tc ON tc.id_original = c.idTipoContrato
        JOIN dbo.Dim_EstadoContrato ec ON ec.NombreEstado = c.estado
        OUTER APPLY (
            SELECT TOP 1 
                cli.IdClienteDW,
                r.IdRolDW
            FROM AltosDelValle.dbo.ClienteContrato cc
            LEFT JOIN dbo.Dim_Cliente cli ON cli.id_original = cc.identificacion
            LEFT JOIN dbo.Dim_Rol r ON r.id_original = cc.idRol
            WHERE cc.idContrato = c.idContrato
        ) AS clienteRol
        LEFT JOIN dbo.Dim_Tiempo tf ON tf.Fecha = c.fechaFirma
        LEFT JOIN dbo.Dim_Tiempo tiempoI ON tiempoI.Fecha = c.fechaInicio
        LEFT JOIN dbo.Dim_Tiempo tiempoF ON tiempoF.Fecha = c.fechaFin
        LEFT JOIN dbo.Dim_Tiempo tp ON tp.Fecha = c.fechaPago;

        PRINT'Porcentajes de comisión.';

        -- Actualiza existentes
        UPDATE T
        SET
            T.IdAgenteDW = S.IdAgenteDW,
            T.IdClienteDW = S.IdClienteDW,
            T.IdRolDW = S.IdRolDW,
            T.IdPropiedadDW = S.IdPropiedadDW,
            T.IdTipoInmuebleDW = S.IdTipoInmuebleDW,
            T.IdEstadoPropiedadDW = S.IdEstadoPropiedadDW,
            T.IdTipoContratoDW = S.IdTipoContratoDW,
            T.IdEstadoContratoDW = S.IdEstadoContratoDW,
            T.IdTiempoFirma = S.IdTiempoFirma,
            T.IdTiempoInicio = S.IdTiempoInicio,
            T.IdTiempoFin = S.IdTiempoFin,
            T.IdTiempoPago = S.IdTiempoPago,
            T.MontoTotalContrato = S.montoTotal,
            T.DepositoPorAlquiler = S.DepositoPorAlquiler,
            T.PorcentajeComision = S.PorcentajeComisionProm,
            T.MontoComision = S.MontoComision,
            T.ContratoFinalizado = S.ContratoFinalizado,
            T.DuracionDias = S.DuracionDias,
            T.DuracionMeses = S.DuracionMeses,
            T.DuracionCuatrimestres = S.DuracionCuatrimestres,
            T.DuracionAnios = S.DuracionAnios
        FROM dbo.Fact_Contrato T
        INNER JOIN #DatosContratos S ON T.id_original = S.id_original;

        -- Inserta nuevos
        INSERT INTO dbo.Fact_Contrato (
            id_original, IdAgenteDW, IdClienteDW, IdRolDW, IdPropiedadDW, IdTipoInmuebleDW, IdEstadoPropiedadDW,
            IdTipoContratoDW, IdEstadoContratoDW, IdTiempoFirma, IdTiempoInicio, IdTiempoFin, IdTiempoPago,
            MontoTotalContrato, DepositoPorAlquiler, PorcentajeComision, MontoComision, ContratoFinalizado,
            DuracionDias, DuracionMeses, DuracionCuatrimestres, DuracionAnios
        )
        SELECT
            S.id_original, S.IdAgenteDW, S.IdClienteDW, S.IdRolDW, S.IdPropiedadDW, S.IdTipoInmuebleDW, S.IdEstadoPropiedadDW,
            S.IdTipoContratoDW, S.IdEstadoContratoDW, S.IdTiempoFirma, S.IdTiempoInicio, S.IdTiempoFin, S.IdTiempoPago,
            S.montoTotal, S.DepositoPorAlquiler, S.PorcentajeComisionProm, S.MontoComision, S.ContratoFinalizado,
            S.DuracionDias, S.DuracionMeses, S.DuracionCuatrimestres, S.DuracionAnios
        FROM #DatosContratos S
        LEFT JOIN dbo.Fact_Contrato T ON T.id_original = S.id_original
        WHERE T.id_original IS NULL;

        PRINT'Fact_Contrato actualizada e insertada sin duplicados.';

        ----------------------------------------------------------
        -- 6. Cargar Fact_Propiedad 
        ----------------------------------------------------------
        PRINT 'Cargando hechos (Fact_Propiedad)...';

        DELETE FROM dbo.Fact_Propiedad;

        INSERT INTO dbo.Fact_Propiedad (IdPropiedadDW, IdEstadoPropiedadDW)
        SELECT
            dp.IdPropiedadDW,
            ep.IdEstadoPropiedadDW
        FROM AltosDelValle.dbo.Propiedad p
        JOIN dbo.Dim_Propiedad       dp ON dp.id_original = p.idPropiedad
        JOIN dbo.Dim_EstadoPropiedad ep ON ep.id_original = p.idEstado;

        PRINT 'Fact_Propiedad cargada correctamente.';


        ------------------------------------------------------------------
        -- 7. Fin del proceso
        ------------------------------------------------------------------
        COMMIT TRAN;
        PRINT'Proceso ETL ejecutado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT'Error durante el proceso ETL: ' + @Err;
        THROW;
    END CATCH
END;
GO


-- Ejecución del proceso
EXEC dbo.Ejecutar_ETL_DM_Contratos_Final;
GO
