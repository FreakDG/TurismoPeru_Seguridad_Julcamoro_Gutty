-- Contraseñas desde el .env (variables SQLCMD)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ADJG_admin')
    CREATE LOGIN ADJG_admin
        WITH PASSWORD = '$(PWD_ADMIN)',
             DEFAULT_DATABASE = TurismoPeru_ADJG,
             CHECK_POLICY = ON,
             CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ADJG_vendedor')
    CREATE LOGIN ADJG_vendedor
        WITH PASSWORD = '$(PWD_VENDEDOR)',
             DEFAULT_DATABASE = TurismoPeru_ADJG,
             CHECK_POLICY = ON,
             CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ADJG_analista')
    CREATE LOGIN ADJG_analista
        WITH PASSWORD = '$(PWD_ANALISTA)',
             DEFAULT_DATABASE = TurismoPeru_ADJG,
             CHECK_POLICY = ON,
             CHECK_EXPIRATION = OFF;
GO

SELECT name, default_database_name, is_policy_checked, is_disabled, create_date
FROM sys.sql_logins
WHERE name IN ('ADJG_admin', 'ADJG_vendedor', 'ADJG_analista');
GO

-- Sin roles de servidor
SELECT m.name AS login, r.name AS rol_servidor
FROM sys.server_role_members srm
JOIN sys.server_principals r ON r.principal_id = srm.role_principal_id
JOIN sys.server_principals m ON m.principal_id = srm.member_principal_id
WHERE m.name IN ('ADJG_admin', 'ADJG_vendedor', 'ADJG_analista');
GO
