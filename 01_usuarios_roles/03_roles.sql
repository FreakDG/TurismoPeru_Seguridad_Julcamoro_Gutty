USE TurismoPeru_ADJG;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_vendedor' AND type = 'R')
    CREATE ROLE rol_vendedor AUTHORIZATION dbo;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_analista' AND type = 'R')
    CREATE ROLE rol_analista AUTHORIZATION dbo;
GO

-- Rol adicional
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin' AND type = 'R')
    CREATE ROLE rol_admin AUTHORIZATION dbo;
GO

ALTER ROLE rol_vendedor ADD MEMBER ADJG_vendedor;
ALTER ROLE rol_analista ADD MEMBER ADJG_analista;
ALTER ROLE rol_admin    ADD MEMBER ADJG_admin;
GO

SELECT r.name AS rol, m.name AS miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name IN ('rol_admin', 'rol_vendedor', 'rol_analista');
GO
