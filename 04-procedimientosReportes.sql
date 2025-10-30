------------------------------------------------------------
-- Contratos por tipo 

CREATE OR ALTER PROCEDURE sp_dm_contratos_por_tipo
AS
BEGIN
    SELECT 
        tc.Nombre AS TipoContrato, 
        COUNT(*) AS Cantidad
    FROM Fact_Contrato f
    INNER JOIN Dim_TipoContrato tc ON f.IdTipoContrato = tc.IdTipoContrato
    GROUP BY tc.Nombre;
END;
GO

------------------------------------------------------------
--  Contratos firmados por mes 

CREATE OR ALTER PROCEDURE sp_dm_contratos_por_mes
AS
BEGIN
    SELECT 
        t.Anio, 
        t.NombreMes, 
        COUNT(*) AS Cantidad
    FROM Fact_Contrato f
    INNER JOIN Dim_Tiempo t ON f.IdTiempoFirma = t.IdTiempo
    GROUP BY t.Anio, t.NombreMes, t.Mes
    ORDER BY t.Anio, MIN(t.Mes);
END;
GO

------------------------------------------------------------
--  Duración promedio por tipo de contrato

CREATE OR ALTER PROCEDURE sp_dm_duracion_promedio_por_tipo
AS
BEGIN
    SELECT 
        tc.Nombre AS TipoContrato,
        AVG(CAST(f.DuracionMeses AS DECIMAL(10,2))) AS DuracionPromedio
    FROM Fact_Contrato f
    INNER JOIN Dim_TipoContrato tc ON f.IdTipoContrato = tc.IdTipoContrato
    GROUP BY tc.Nombre;
END;
GO

------------------------------------------------------------
--  Contratos por rol de cliente 

CREATE OR ALTER PROCEDURE sp_dm_contratos_por_rol
AS
BEGIN
    SELECT 
        r.NombreRol, 
        COUNT(*) AS Cantidad
    FROM Fact_ClienteContrato fcc
    INNER JOIN Dim_Rol r ON fcc.IdRol = r.IdRol
    GROUP BY r.NombreRol;
END;
GO

------------------------------------------------------------
--- Top 10 propiedades más contratadas 

CREATE OR ALTER PROCEDURE sp_dm_top_propiedades
AS
BEGIN
    SELECT TOP 10 
        p.Ubicacion, 
        COUNT(*) AS TotalContratos
    FROM Fact_Contrato f
    INNER JOIN Dim_Propiedad p ON f.IdPropiedad = p.IdPropiedad
    GROUP BY p.Ubicacion
    ORDER BY TotalContratos DESC;
END;
GO

------------------------------------------------------------
--  Contratos por agente 

CREATE OR ALTER PROCEDURE sp_dm_contratos_por_agente
AS
BEGIN
    SELECT 
        a.NombreCompleto AS Agente,
        COUNT(f.IdContrato) AS CantidadContratos,
        SUM(ISNULL(f.MontoTotal, 0)) AS MontoTotalGestionado,
        AVG(ISNULL(f.DuracionMeses, 0)) AS DuracionPromedioMeses
    FROM Fact_Contrato f
    INNER JOIN Dim_Agente a ON f.IdAgente = a.IdAgente
    GROUP BY a.NombreCompleto
    ORDER BY CantidadContratos DESC;
END;
GO

------------------------------------------------------------
-- Historial de clientes y contratos

CREATE OR ALTER PROCEDURE sp_dm_historial_contratos_cliente
AS
BEGIN
    SELECT 
        cl.IdCliente,
        cl.NombreCompleto AS NombreCliente,
        rol.NombreRol,
        fcc.IdContrato,
        tc.Nombre AS TipoContrato,
        p.Ubicacion AS Propiedad,
        p.Precio AS PrecioPropiedad,
        a.NombreCompleto AS AgenteEncargado,
        f.MontoTotal,
        f.Deposito,
        f.DuracionMeses,
        f.Estado
    FROM Fact_ClienteContrato fcc
    INNER JOIN Dim_Cliente cl ON fcc.IdCliente = cl.IdCliente
    INNER JOIN Dim_Rol rol ON fcc.IdRol = rol.IdRol
    INNER JOIN Fact_Contrato f ON fcc.IdContrato = f.IdContrato
    INNER JOIN Dim_Propiedad p ON f.IdPropiedad = p.IdPropiedad
    INNER JOIN Dim_TipoContrato tc ON f.IdTipoContrato = tc.IdTipoContrato
    INNER JOIN Dim_Agente a ON f.IdAgente = a.IdAgente
    ORDER BY cl.IdCliente, fcc.IdContrato;
END;
GO

------------------------------------------------------------
--  Estado actual de propiedades

CREATE OR ALTER PROCEDURE sp_dm_estado_propiedades
AS
BEGIN
    SELECT 
        p.IdPropiedad,
        p.Ubicacion,
        p.Precio,
        p.TipoInmueble,
        p.EstadoPropiedad
    FROM Dim_Propiedad p
    ORDER BY p.EstadoPropiedad, p.Ubicacion;
END;
GO

------------------------------------------------------------
-- Pagos y comisiones por agente

CREATE OR ALTER PROCEDURE sp_dm_pagos_comisiones
AS
BEGIN
    SELECT 
        a.NombreCompleto AS Agente,
        COUNT(f.IdContrato) AS CantidadContratos,
        SUM(ISNULL(f.MontoTotal, 0)) AS TotalGestionado,
        SUM(ISNULL(f.MontoTotal, 0) * ISNULL(f.PorcentajeComision, 0) / 100) AS ComisionEstimado
    FROM Fact_Contrato f
    INNER JOIN Dim_Agente a ON f.IdAgente = a.IdAgente
    GROUP BY a.NombreCompleto
    ORDER BY TotalGestionado DESC;
END;
GO

------------------------------------------------------------
--Facturación y pagos por cliente

CREATE OR ALTER PROCEDURE sp_dm_facturacion_por_cliente
AS
BEGIN
    SELECT 
        c.IdCliente,
        c.NombreCompleto AS Cliente,
        r.NombreRol,
        COUNT(f.IdContrato) AS TotalContratos,
        SUM(ISNULL(f.MontoTotal, 0)) AS TotalFacturado,
        SUM(ISNULL(f.Deposito, 0)) AS TotalDepositos,
        SUM(CASE WHEN f.Estado = 'Activo' THEN 1 ELSE 0 END) AS ContratosActivos,
        SUM(CASE WHEN f.Estado = 'Finalizado' THEN 1 ELSE 0 END) AS ContratosFinalizados
    FROM Fact_ClienteContrato fcc
    INNER JOIN Dim_Cliente c ON fcc.IdCliente = c.IdCliente
    INNER JOIN Dim_Rol r ON fcc.IdRol = r.IdRol
    INNER JOIN Fact_Contrato f ON fcc.IdContrato = f.IdContrato
    GROUP BY c.IdCliente, c.NombreCompleto, r.NombreRol
    ORDER BY TotalFacturado DESC;
END;
GO



USE DataMartAltosdelValle;

EXEC sp_dm_contratos_por_tipo;


EXEC sp_dm_contratos_por_mes;


EXEC sp_dm_duracion_promedio_por_tipo;


EXEC sp_dm_contratos_por_rol;


EXEC sp_dm_top_propiedades;


EXEC sp_dm_contratos_por_agente;


EXEC sp_dm_historial_contratos_cliente;


EXEC sp_dm_estado_propiedades;


EXEC sp_dm_pagos_comisiones;


EXEC sp_dm_facturacion_por_cliente;


SELECT * FROM vw_dm_contratos_completos;


SELECT * FROM vw_historial_clientes;


SELECT * FROM vw_estadisticas_agentes;





