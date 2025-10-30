-- ==========================================
-- CREAR BASE DE DATOS DEL DATAMART
-- ==========================================
USE master;
IF DB_ID('DataMartAltosdelValle') IS NOT NULL
BEGIN
    ALTER DATABASE DataMartAltosdelValle SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataMartAltosdelValle;
END
GO

USE master;
GO

CREATE DATABASE DataMartAltosdelValle;
GO

USE DataMartAltosdelValle;
GO




