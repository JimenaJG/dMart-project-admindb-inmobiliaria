------ vw_dm_contratos_completos
CREATE OR ALTER VIEW vw_dm_contratos_completos AS
SELECT 
  f.IdContratoDW,
  f.IdContrato,
  f.MontoTotal,
  f.Deposito,
  f.DuracionMeses,
  f.Estado,
  f.PorcentajeComision,
  
  a.NombreCompleto AS NombreAgente,
  a.Telefono AS TelefonoAgente,
  
  p.Ubicacion,
  p.Precio AS PrecioPropiedad,
  p.TipoInmueble,
  p.EstadoPropiedad,

  tc.Nombre AS TipoContrato,

  tf.Fecha AS FechaFirma,
  ti.Fecha AS FechaInicio,
  tfin.Fecha AS FechaFin,
  tp.Fecha AS FechaPago

FROM DataMartAltosdelValle.dbo.Fact_Contrato f
INNER JOIN DataMartAltosdelValle.dbo.Dim_Agente a ON f.IdAgente = a.IdAgente
INNER JOIN DataMartAltosdelValle.dbo.Dim_Propiedad p ON f.IdPropiedad = p.IdPropiedad
INNER JOIN DataMartAltosdelValle.dbo.Dim_TipoContrato tc ON f.IdTipoContrato = tc.IdTipoContrato
LEFT JOIN DataMartAltosdelValle.dbo.Dim_Tiempo tf ON f.IdTiempoFirma = tf.IdTiempo
LEFT JOIN DataMartAltosdelValle.dbo.Dim_Tiempo ti ON f.IdTiempoInicio = ti.IdTiempo
LEFT JOIN DataMartAltosdelValle.dbo.Dim_Tiempo tfin ON f.IdTiempoFin = tfin.IdTiempo
LEFT JOIN DataMartAltosdelValle.dbo.Dim_Tiempo tp ON f.IdTiempoPago = tp.IdTiempo;
GO

----vw_estadisticas_agentes
CREATE OR ALTER VIEW vw_estadisticas_agentes AS
SELECT 
  a.IdAgente,
  a.NombreCompleto AS Agente,
  COUNT(f.IdContrato) AS TotalContratos,
  SUM(ISNULL(f.MontoTotal, 0)) AS TotalGestionado,
  SUM(ISNULL(f.MontoTotal, 0) * ISNULL(f.PorcentajeComision, 0) / 100) AS ComisionEstimada
FROM DataMartAltosdelValle.dbo.Fact_Contrato f
INNER JOIN DataMartAltosdelValle.dbo.Dim_Agente a ON f.IdAgente = a.IdAgente
GROUP BY a.IdAgente, a.NombreCompleto;
GO

