/* Restauración del .bacpac con SqlPackage (CMD o Git Bash, desde la raíz del proyecto)
   El servidor destino no debe tener una base con el mismo nombre.

sqlpackage /Action:Import /SourceFile:03_backups/TurismoPeru_ADJG_Full.bacpac /TargetServerName:localhost /TargetDatabaseName:TurismoPeru_ADJG /TargetTrustServerCertificate:True

   Si los logins no existen en el destino, se crean con contraseñas aleatorias.
   Luego se ejecuta este script (SQLCMD Mode o sqlcmd -v) para asignarles las reales.
*/

USE master;
GO

ALTER LOGIN ADJG_admin    WITH PASSWORD = '$(PWD_ADMIN)';
ALTER LOGIN ADJG_vendedor WITH PASSWORD = '$(PWD_VENDEDOR)';
ALTER LOGIN ADJG_analista WITH PASSWORD = '$(PWD_ANALISTA)';
GO

USE TurismoPeru_ADJG;
GO

-- Usuarios enlazados a su login (no deben quedar huérfanos)
SELECT dp.name AS usuario, sp.name AS login
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON sp.sid = dp.sid
WHERE dp.name IN ('ADJG_admin', 'ADJG_vendedor', 'ADJG_analista');

SELECT r.name AS rol, m.name AS miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name IN ('rol_admin', 'rol_vendedor', 'rol_analista');

-- Debe coincidir con el conteo de backup_full.sql
SELECT COUNT(*) AS tablas, SUM(p.rows) AS filas_totales
FROM sys.tables t
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
WHERE t.schema_id = SCHEMA_ID('ADJG');

SELECT (SELECT COUNT(*) FROM ADJG.persona)         AS persona,
       (SELECT COUNT(*) FROM ADJG.cliente)         AS cliente,
       (SELECT COUNT(*) FROM ADJG.reserva)         AS reserva,
       (SELECT COUNT(*) FROM ADJG.pago)            AS pago,
       (SELECT COUNT(*) FROM ADJG.lugar_turistico) AS lugar_turistico,
       (SELECT SUM(monto) FROM ADJG.pago)          AS suma_pagos;
GO
