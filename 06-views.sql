USE DataMartAltosDelValle;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- CONTRATOS COMPLETOS
CREATE OR ALTER VIEW dbo.vw_dm_contratos_completos AS
SELECT 
  f.IdContratoDW,
  f.id_original AS IdContrato_Original,
  ag.NombreCompleto AS Agente,
  tc.Nombre AS TipoContrato,
  ec.NombreEstado AS EstadoContrato,
  p.Ubicacion,
  f.MontoTotalContrato,
  f.MontoComision,
  f.DuracionMeses,
  f.ContratoFinalizado,
  f.IdTiempoInicio,
  ti.Fecha AS FechaInicio,
  ti.NombreMes AS MesInicio,
  ti.Anio AS AnioInicio
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_Agente ag ON ag.IdAgenteDW = f.IdAgenteDW
JOIN dbo.Dim_Propiedad p ON p.IdPropiedadDW = f.IdPropiedadDW
JOIN dbo.Dim_TipoContrato tc ON tc.IdTipoContratoDW = f.IdTipoContratoDW
JOIN dbo.Dim_EstadoContrato ec ON ec.IdEstadoContratoDW = f.IdEstadoContratoDW
LEFT JOIN dbo.Dim_Tiempo ti ON ti.IdTiempo = f.IdTiempoInicio;
GO

-- ESTADÍSTICAS POR AGENTE
CREATE OR ALTER VIEW dbo.vw_estadisticas_agentes AS
SELECT 
  ag.NombreCompleto AS Agente,
  COALESCE(COUNT(f.IdContratoDW), 0) AS TotalContratos,
  COALESCE(SUM(f.MontoComision), 0) AS TotalComisiones,
  COALESCE(AVG(f.MontoTotalContrato), 0) AS PromedioMontoContrato,
  COALESCE(SUM(CASE WHEN f.ContratoFinalizado = 1 THEN 1 ELSE 0 END), 0) AS ContratosFinalizados
FROM dbo.Dim_Agente ag
LEFT JOIN dbo.Fact_Contrato f ON f.IdAgenteDW = ag.IdAgenteDW
GROUP BY ag.NombreCompleto;
GO

-- CONTRATOS POR TIPO
CREATE OR ALTER VIEW dbo.vw_contratos_por_tipo AS
SELECT 
  tc.Nombre AS TipoContrato,
  COUNT(f.IdContratoDW) AS TotalContratos,
  SUM(f.MontoTotalContrato) AS MontoTotal
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_TipoContrato tc ON tc.IdTipoContratoDW = f.IdTipoContratoDW
GROUP BY tc.Nombre;
GO

-- CONTRATOS POR MES
CREATE OR ALTER VIEW dbo.vw_contratos_por_mes AS
SELECT 
  t.Anio,
  t.NombreMes,
  COUNT(f.IdContratoDW) AS TotalContratos,
  SUM(f.MontoTotalContrato) AS MontoTotal
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_Tiempo t ON t.IdTiempo = f.IdTiempoInicio
GROUP BY t.Anio, t.NombreMes;
GO

-- DURACIÓN PROMEDIO POR TIPO DE CONTRATO
CREATE OR ALTER VIEW dbo.vw_duracion_por_tipo_contrato AS
SELECT 
  tc.Nombre AS TipoContrato,
  AVG(f.DuracionMeses) AS PromedioDuracionMeses
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_TipoContrato tc ON f.IdTipoContratoDW = tc.IdTipoContratoDW
GROUP BY tc.Nombre;
GO

-- CONTRATOS POR ROL DE CLIENTE
CREATE OR ALTER VIEW dbo.vw_contratos_por_rol AS
SELECT 
  r.NombreRol,
  COUNT(f.IdContratoDW) AS TotalContratos
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_Rol r ON f.IdRolDW = r.IdRolDW
GROUP BY r.NombreRol;
GO

-- TOP 10 PROPIEDADES CONTRATADAS
CREATE OR ALTER VIEW dbo.vw_top_propiedades_contratadas AS
SELECT TOP 10
  p.Ubicacion,
  COUNT(f.IdContratoDW) AS TotalContratos,
  SUM(f.MontoTotalContrato) AS TotalMonto
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_Propiedad p ON p.IdPropiedadDW = f.IdPropiedadDW
GROUP BY p.Ubicacion
ORDER BY TotalContratos DESC;
GO

--  HISTORIAL DE CONTRATOS POR CLIENTE
CREATE OR ALTER VIEW dbo.vw_historial_contratos_cliente AS
SELECT 
  cl.NombreCompleto AS Cliente,
  r.NombreRol,
  tc.Nombre AS TipoContrato,
  p.Ubicacion AS Propiedad,
  a.NombreCompleto AS AgenteEncargado,
  f.MontoTotalContrato,
  f.DuracionMeses,
  ec.NombreEstado AS EstadoContrato,
  ti.Fecha AS FechaInicio
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_Cliente cl ON f.IdClienteDW = cl.IdClienteDW
JOIN dbo.Dim_Rol r ON f.IdRolDW = r.IdRolDW
JOIN dbo.Dim_Propiedad p ON f.IdPropiedadDW = p.IdPropiedadDW
JOIN dbo.Dim_TipoContrato tc ON f.IdTipoContratoDW = tc.IdTipoContratoDW
JOIN dbo.Dim_Agente a ON f.IdAgenteDW = a.IdAgenteDW
JOIN dbo.Dim_EstadoContrato ec ON f.IdEstadoContratoDW = ec.IdEstadoContratoDW
LEFT JOIN dbo.Dim_Tiempo ti ON f.IdTiempoInicio = ti.IdTiempo;
GO

-- FACTURACIÓN POR CLIENTE
CREATE OR ALTER VIEW dbo.vw_facturacion_por_cliente AS
SELECT 
  cl.NombreCompleto AS Cliente,
  r.NombreRol,
  COUNT(f.IdContratoDW) AS TotalContratos,
  SUM(f.MontoTotalContrato) AS MontoTotal,
  SUM(f.MontoComision) AS Comisiones
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_Cliente cl ON f.IdClienteDW = cl.IdClienteDW
JOIN dbo.Dim_Rol r ON f.IdRolDW = r.IdRolDW
GROUP BY cl.NombreCompleto, r.NombreRol;
GO

-- ESTADO DE LAS PROPIEDADES
CREATE OR ALTER VIEW vw_estado_propiedades AS
SELECT 
  ep.NombreEstado AS EstadoPropiedad,
  COUNT(DISTINCT fp.IdPropiedadDW) AS TotalPropiedades
FROM dbo.Dim_EstadoPropiedad ep
LEFT JOIN dbo.Fact_Propiedad fp 
  ON fp.IdEstadoPropiedadDW = ep.IdEstadoPropiedadDW
GROUP BY ep.NombreEstado;
GO

--  RESUMEN GENERAL DASHBOARD
CREATE OR ALTER VIEW dbo.vw_resumen_general_dashboard AS
SELECT 
  (SELECT COUNT(*) FROM dbo.Fact_Contrato) AS TotalContratos,
  (SELECT COUNT(*) FROM dbo.Dim_Agente) AS TotalAgentes,
  (SELECT SUM(MontoTotalContrato) FROM dbo.Fact_Contrato) AS MontoTotalContratos,
  (SELECT SUM(MontoComision) FROM dbo.Fact_Contrato) AS TotalComisiones,
  (SELECT COUNT(DISTINCT p.IdPropiedadDW)
   FROM dbo.Fact_Contrato f
   INNER JOIN dbo.Dim_Propiedad p ON f.IdPropiedadDW = p.IdPropiedadDW
   INNER JOIN dbo.Dim_EstadoPropiedad ep ON f.IdEstadoPropiedadDW = ep.IdEstadoPropiedadDW
   WHERE UPPER(ep.NombreEstado) = 'DISPONIBLE') AS PropiedadesDisponibles,
  (SELECT COUNT(*) 
   FROM dbo.Dim_Cliente c 
   WHERE c.Estado = 1) AS ClientesActivos;
GO

--  COMISIONES POR MES
CREATE OR ALTER VIEW dbo.vw_comisiones_por_mes AS
SELECT 
  t.Anio,
  t.NombreMes,
  SUM(f.MontoComision) AS TotalComisiones
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_Tiempo t ON f.IdTiempoInicio = t.IdTiempo
GROUP BY t.Anio, t.NombreMes;
GO

--  CONTRATOS ACTIVOS VS FINALIZADOS
CREATE OR ALTER VIEW dbo.vw_contratos_activos_vs_finalizados AS
SELECT 
  CASE 
    WHEN ContratoFinalizado = 1 THEN 'Finalizado'
    ELSE 'Activo'
  END AS EstadoContrato,
  COUNT(*) AS TotalContratos
FROM dbo.Fact_Contrato
GROUP BY ContratoFinalizado;
GO

--  DISTRIBUCIÓN POR TIPO DE INMUEBLE
CREATE OR ALTER VIEW dbo.vw_distribucion_por_tipo_inmueble AS
SELECT 
  ti.NombreTipo AS TipoInmueble,
  COUNT(f.IdContratoDW) AS TotalContratos
FROM dbo.Fact_Contrato f
JOIN dbo.Dim_TipoInmueble ti ON f.IdTipoInmuebleDW = ti.IdTipoInmuebleDW
GROUP BY ti.NombreTipo;
GO


SELECT TOP 5 * FROM vw_dm_contratos_completos;
SELECT * FROM vw_estadisticas_agentes;
SELECT * FROM vw_contratos_por_tipo;
SELECT * FROM vw_contratos_por_mes;
SELECT * FROM vw_duracion_por_tipo_contrato;
SELECT * FROM vw_contratos_por_rol;
SELECT * FROM vw_top_propiedades_contratadas;
SELECT * FROM vw_historial_contratos_cliente;
SELECT * FROM vw_facturacion_por_cliente;
SELECT * FROM vw_estado_propiedades;
SELECT * FROM vw_resumen_general_dashboard;
SELECT * FROM vw_comisiones_por_mes;
SELECT * FROM vw_contratos_activos_vs_finalizados;
SELECT * FROM vw_distribucion_por_tipo_inmueble;

