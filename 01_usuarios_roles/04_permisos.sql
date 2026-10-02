USE TurismoPeru_ADJG;
GO

-- rol_vendedor
GRANT SELECT, INSERT ON ADJG.cliente TO rol_vendedor;
GRANT SELECT, INSERT ON ADJG.reserva TO rol_vendedor;
GRANT SELECT ON ADJG.alojamiento TO rol_vendedor;
GRANT SELECT ON ADJG.habitacion  TO rol_vendedor;

-- Necesario para registrar un cliente (cliente.id_persona -> persona)
GRANT SELECT, INSERT ON ADJG.persona TO rol_vendedor;

DENY DELETE ON ADJG.cliente TO rol_vendedor;
DENY DELETE ON ADJG.reserva TO rol_vendedor;
GO

-- rol_analista
GRANT SELECT ON ADJG.cliente         TO rol_analista;
GRANT SELECT ON ADJG.reserva         TO rol_analista;
GRANT SELECT ON ADJG.pago            TO rol_analista;
GRANT SELECT ON ADJG.alojamiento     TO rol_analista;
GRANT SELECT ON ADJG.habitacion      TO rol_analista;
GRANT SELECT ON ADJG.paquete         TO rol_analista;
GRANT SELECT ON ADJG.lugar_turistico TO rol_analista;

-- Catálogos y nombres para el reporte (sin documento, teléfono ni email)
GRANT SELECT ON ADJG.estado_reserva TO rol_analista;
GRANT SELECT ON ADJG.medio_pago     TO rol_analista;
GRANT SELECT ON ADJG.persona (id_persona, nombres, apaterno, amaterno) TO rol_analista;

DENY INSERT, UPDATE, DELETE ON SCHEMA::ADJG TO rol_analista;
GO

-- Ni vendedor ni analista administran usuarios, roles ni backups
DENY ALTER ANY USER, ALTER ANY ROLE, BACKUP DATABASE, BACKUP LOG TO rol_vendedor;
DENY ALTER ANY USER, ALTER ANY ROLE, BACKUP DATABASE, BACKUP LOG TO rol_analista;
GO

-- rol_admin
ALTER ROLE db_owner ADD MEMBER rol_admin;
GO

-- El admin necesita ver los otros logins para exportar el .bacpac
USE master;
GRANT VIEW DEFINITION ON LOGIN::ADJG_vendedor TO ADJG_admin;
GRANT VIEW DEFINITION ON LOGIN::ADJG_analista TO ADJG_admin;
GO

USE TurismoPeru_ADJG;
GO

SELECT pr.name AS rol,
       pe.state_desc AS estado,
       pe.permission_name AS permiso,
       CASE pe.class_desc
            WHEN 'SCHEMA' THEN 'SCHEMA::' + SCHEMA_NAME(pe.major_id)
            WHEN 'OBJECT_OR_COLUMN' THEN OBJECT_SCHEMA_NAME(pe.major_id) + '.' + OBJECT_NAME(pe.major_id)
            ELSE pe.class_desc
       END AS objeto,
       COL_NAME(pe.major_id, pe.minor_id) AS columna
FROM sys.database_permissions pe
JOIN sys.database_principals pr ON pr.principal_id = pe.grantee_principal_id
WHERE pr.name IN ('rol_vendedor', 'rol_analista')
ORDER BY rol, estado, objeto, permiso;
GO

SELECT r.name AS rol_bd, m.name AS miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE m.name = 'rol_admin';
GO
