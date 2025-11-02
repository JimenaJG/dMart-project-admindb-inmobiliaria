USE master;
GO


IF DB_ID('DataMartAltosDelValle') IS NOT NULL
BEGIN
    ALTER DATABASE DataMartAltosDelValle SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataMartAltosDelValle;
END
GO


CREATE DATABASE DataMartAltosDelValle
ON 
PRIMARY (
    NAME = DataMartAltosDelValle_Data,
    FILENAME = 'C:\SqlData\DataMartAltosDelValle_Data.mdf',
    SIZE = 200MB,               
    MAXSIZE = 2048MB,            
    FILEGROWTH = 50MB            
)
LOG ON (
    NAME = DataMartAltosDelValle_Log,
    FILENAME = 'C:\SqlLog\DataMartAltosDelValle_Log.ldf',
    SIZE = 100MB,
    MAXSIZE = 512MB,
    FILEGROWTH = 20MB
);
GO


ALTER DATABASE DataMartAltosDelValle SET RECOVERY SIMPLE;
GO

USE DataMartAltosDelValle;
GO
