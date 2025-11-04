USE master;
GO

CREATE LOGIN adminAltosDelValleDatamart
WITH PASSWORD = 'Frander123!',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
GO

USE DataMartAltosDelValle;
GO

CREATE USER adminAltosDelValleDatamart FOR LOGIN adminAltosDelValleDatamart;
GO

GRANT EXECUTE ON SCHEMA::dbo TO adminAltosDelValleDatamart;
GO

GRANT SELECT ON SCHEMA::dbo TO adminAltosDelValleDatamart;
GO

GRANT EXECUTE ON SCHEMA::dbo TO adminAltosDelValleDatamart;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO adminAltosDelValleDatamart;
GO
