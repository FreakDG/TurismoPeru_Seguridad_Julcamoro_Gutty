/* 1. Exportación con bcp (CMD o Git Bash, desde la carpeta 02_importacion_exportacion)
   Se usa el login ADJG_admin. Al omitir -P, bcp pide la contraseña.

bcp "SELECT linea FROM (SELECT 0 AS o, 0 AS id, CAST('Documento,Nombres,ApellidoPaterno,ApellidoMaterno' AS varchar(max)) AS linea UNION ALL SELECT 1, p.id_persona, CONCAT(p.numero_documento, ',', p.nombres, ',', p.apaterno, ',', p.amaterno) FROM ADJG.cliente c JOIN ADJG.persona p ON p.id_persona = c.id_persona) t ORDER BY o, id" queryout clientes.csv -S <SERVIDOR> -d TurismoPeru_ADJG -U ADJG_admin -c -C 65001 -u

bcp "SELECT linea FROM (SELECT 0 AS o, 0 AS id, CAST('id_reserva,codigo_reserva,id_cliente,id_paquete,id_empleado,id_alojamiento,id_habitacion,fecha_reserva,fecha_inicio,fecha_fin,numero_personas,precio_total,adelanto,saldo_pendiente,id_estado_reserva,observaciones' AS varchar(max)) AS linea UNION ALL SELECT 1, id_reserva, CONCAT(id_reserva, ',', codigo_reserva, ',', id_cliente, ',', id_paquete, ',', id_empleado, ',', id_alojamiento, ',', id_habitacion, ',', CONVERT(varchar(19), fecha_reserva, 120), ',', fecha_inicio, ',', fecha_fin, ',', numero_personas, ',', precio_total, ',', adelanto, ',', saldo_pendiente, ',', id_estado_reserva, ',', CHAR(34), REPLACE(observaciones, CHAR(34), ''), CHAR(34)) FROM ADJG.reserva) t ORDER BY o, id" queryout reservas.csv -S <SERVIDOR> -d TurismoPeru_ADJG -U ADJG_admin -c -C 65001 -u

bcp "SELECT linea FROM (SELECT 0 AS o, 0 AS id, CAST('id_pago,id_reserva,id_medio_pago,monto,fecha_pago,numero_operacion,comprobante,estado' AS varchar(max)) AS linea UNION ALL SELECT 1, id_pago, CONCAT(id_pago, ',', id_reserva, ',', id_medio_pago, ',', monto, ',', CONVERT(varchar(19), fecha_pago, 120), ',', numero_operacion, ',', comprobante, ',', estado) FROM ADJG.pago) t ORDER BY o, id" queryout pago.csv -S <SERVIDOR> -d TurismoPeru_ADJG -U ADJG_admin -c -C 65001 -u

bcp "SELECT linea FROM (SELECT 0 AS o, 0 AS id, CAST('id_lugarturistico,nombre,descripcion,precio_entrada,horario_apertura,horario_cierre,calificacion,estado' AS varchar(max)) AS linea UNION ALL SELECT 1, id_lugarturistico, CONCAT(id_lugarturistico, ',', CHAR(34), nombre, CHAR(34), ',', CHAR(34), REPLACE(CAST(descripcion AS varchar(max)), CHAR(34), ''), CHAR(34), ',', precio_entrada, ',', CONVERT(varchar(8), horario_apertura, 108), ',', CONVERT(varchar(8), horario_cierre, 108), ',', calificacion, ',', estado) FROM ADJG.lugar_turistico) t ORDER BY o, id" queryout lugaresturisticos.csv -S <SERVIDOR> -d TurismoPeru_ADJG -U ADJG_admin -c -C 65001 -u
*/

USE TurismoPeru_ADJG;
GO

-- 2. Tabla de staging (ejecutar antes del bcp in)
IF OBJECT_ID('ADJG.cliente_importacion') IS NULL
    CREATE TABLE ADJG.cliente_importacion (
        Documento       VARCHAR(20)  NULL,
        Nombres         VARCHAR(100) NULL,
        ApellidoPaterno VARCHAR(100) NULL,
        ApellidoMaterno VARCHAR(100) NULL
    );
ELSE
    TRUNCATE TABLE ADJG.cliente_importacion;
GO

/* 3. Importación con bcp (-F 2 salta el encabezado)

bcp ADJG.cliente_importacion in clientes.csv -S <SERVIDOR> -d TurismoPeru_ADJG -U ADJG_admin -c -C 65001 -t "," -F 2 -u
*/

SELECT COUNT(*) AS registros_importados FROM ADJG.cliente_importacion;
GO

-- 4. Validación
IF OBJECT_ID('tempdb..#validacion') IS NOT NULL DROP TABLE #validacion;

SELECT ci.Documento,
       ci.Nombres,
       ci.ApellidoPaterno,
       ci.ApellidoMaterno,
       COUNT(*) OVER (PARTITION BY ci.Documento) AS veces_en_archivo,
       CASE WHEN EXISTS (SELECT 1 FROM ADJG.persona p WHERE p.numero_documento = ci.Documento)
            THEN 1 ELSE 0 END AS existe_en_bd,
       CAST(NULL AS VARCHAR(40)) AS resultado
INTO #validacion
FROM ADJG.cliente_importacion ci;

UPDATE #validacion
SET resultado = CASE
        WHEN ISNULL(LTRIM(RTRIM(Documento)), '') = ''                    THEN 'Inválido: sin documento'
        WHEN Documento LIKE '%[^A-Za-z0-9-]%' OR LEN(Documento) < 8     THEN 'Inválido: formato de documento'
        WHEN ISNULL(LTRIM(RTRIM(Nombres)), '') = ''
          OR ISNULL(LTRIM(RTRIM(ApellidoPaterno)), '') = ''              THEN 'Inválido: faltan nombres'
        WHEN veces_en_archivo > 1                                        THEN 'Duplicado en el archivo'
        WHEN existe_en_bd = 1                                            THEN 'Duplicado: ya existe en la BD'
        -- Sin tipo de documento en el archivo, solo se registra automáticamente un DNI
        WHEN Documento NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' THEN 'Revisar: no es DNI'
        ELSE 'Válido'
    END;

SELECT resultado, COUNT(*) AS cantidad
FROM #validacion
GROUP BY resultado;

-- 5. Duplicados
SELECT Documento, Nombres, ApellidoPaterno, ApellidoMaterno, veces_en_archivo, existe_en_bd, resultado
FROM #validacion
WHERE resultado LIKE 'Duplicado%'
ORDER BY veces_en_archivo DESC, Documento;

-- 6. Inserción de registros válidos
DECLARE @dni INT = (SELECT id_tipo_documento FROM ADJG.tipo_documento WHERE nombredoc = 'Documento Nacional de Identidad');
DECLARE @peru INT = (SELECT id_nacionalidad FROM ADJG.nacionalidad WHERE nombrenacionalidad = 'Peruano/a');
DECLARE @nuevos TABLE (id_persona INT);

SET XACT_ABORT ON;
BEGIN TRAN;

INSERT INTO ADJG.persona (tipo_persona, nombres, apaterno, amaterno, razon_social,
                          id_tipo_documento, numero_documento, id_nacionalidad)
OUTPUT inserted.id_persona INTO @nuevos
SELECT 'N', Nombres, ApellidoPaterno, ApellidoMaterno,
       CONCAT_WS(' ', Nombres, ApellidoPaterno, ApellidoMaterno),
       @dni, Documento, @peru
FROM #validacion
WHERE resultado = 'Válido';

INSERT INTO ADJG.cliente (id_persona)
SELECT id_persona FROM @nuevos;

COMMIT;

SELECT COUNT(*) AS clientes_insertados FROM @nuevos;
GO

-- 7. Resumen
SELECT (SELECT COUNT(*) FROM ADJG.cliente_importacion)                     AS registros_archivo,
       (SELECT COUNT(DISTINCT Documento) FROM ADJG.cliente_importacion)    AS documentos_distintos,
       (SELECT COUNT(*) FROM #validacion WHERE resultado LIKE 'Duplicado%') AS duplicados,
       (SELECT COUNT(*) FROM #validacion WHERE resultado LIKE 'Inválido%')  AS invalidos,
       (SELECT COUNT(*) FROM #validacion WHERE resultado = 'Válido')        AS validos_insertados,
       (SELECT COUNT(*) FROM ADJG.cliente)                                  AS total_clientes;
GO
