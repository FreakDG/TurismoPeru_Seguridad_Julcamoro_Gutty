USE TurismoPeru_ADJG;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ADJG_admin')
    CREATE USER ADJG_admin FOR LOGIN ADJG_admin WITH DEFAULT_SCHEMA = ADJG;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ADJG_vendedor')
    CREATE USER ADJG_vendedor FOR LOGIN ADJG_vendedor WITH DEFAULT_SCHEMA = ADJG;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ADJG_analista')
    CREATE USER ADJG_analista FOR LOGIN ADJG_analista WITH DEFAULT_SCHEMA = ADJG;
GO

-- Usuario - login
SELECT dp.name AS usuario, sp.name AS login, dp.default_schema_name
FROM sys.database_principals dp
JOIN sys.server_principals sp ON sp.sid = dp.sid
WHERE dp.name IN ('ADJG_admin', 'ADJG_vendedor', 'ADJG_analista');
GO
