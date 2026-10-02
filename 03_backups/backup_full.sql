/* Backup FULL en formato .bacpac con SqlPackage (CMD o Git Bash, desde la raíz del proyecto)
   Se ejecuta con ADJG_admin. Adaptar la ruta de /TargetFile al equipo.

sqlpackage /Action:Export /SourceServerName:<SERVIDOR> /SourceDatabaseName:TurismoPeru_ADJG /SourceUser:ADJG_admin /SourcePassword:<CONTRASEÑA> /SourceTrustServerCertificate:True /TargetFile:03_backups/TurismoPeru_ADJG_Full.bacpac

   El .bacpac guarda esquema y datos. Las contraseñas de los logins no se exportan,
   SqlPackage pone valores aleatorios.
*/

USE TurismoPeru_ADJG;
GO

-- Conteo antes del backup, para comparar después de restaurar
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
