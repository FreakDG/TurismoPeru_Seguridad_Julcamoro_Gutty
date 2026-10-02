-- Consultas del reporte. Power BI se conecta con ADJG_analista (solo lectura).
USE TurismoPeru_ADJG;
GO

/* ===== Consultas que carga Power BI ===== */

-- Cliente
SELECT c.id_persona AS id_cliente,
       CONCAT_WS(' ', p.nombres, p.apaterno, p.amaterno) AS cliente
FROM ADJG.cliente c
JOIN ADJG.persona p ON p.id_persona = c.id_persona;

-- Reserva
SELECT id_reserva, codigo_reserva, id_cliente, id_paquete, id_alojamiento,
       CAST(fecha_reserva AS DATE) AS fecha_reserva, fecha_inicio, fecha_fin,
       numero_personas, precio_total, id_estado_reserva
FROM ADJG.reserva;

-- Pago
SELECT id_pago, id_reserva, id_medio_pago, monto,
       CAST(fecha_pago AS DATE) AS fecha_pago, estado
FROM ADJG.pago;

-- Estado de reserva
SELECT id_estado_reserva, nombre AS estado_reserva FROM ADJG.estado_reserva;

-- Medio de pago
SELECT id_medio_pago, nombre AS medio_pago, tipo FROM ADJG.medio_pago;

-- Paquete
SELECT id_paquete, nombre AS paquete, duracion_dias, precio_base FROM ADJG.paquete;

-- Alojamiento
SELECT id_alojamiento, Nombre AS alojamiento, Categoria_Estrellas FROM ADJG.alojamiento;
GO

/* ===== Validación de los resultados del dashboard ===== */

-- KPI (ingresos = solo pagos confirmados)
SELECT (SELECT COUNT(*) FROM ADJG.cliente) AS total_clientes,
       (SELECT COUNT(*) FROM ADJG.reserva) AS total_reservas,
       (SELECT SUM(monto) FROM ADJG.pago WHERE estado = 'Confirmado') AS total_ingresos,
       CAST((SELECT SUM(monto) FROM ADJG.pago WHERE estado = 'Confirmado')
            / (SELECT COUNT(*) FROM ADJG.reserva) AS DECIMAL(12, 2)) AS ticket_promedio;

-- Reservas por estado
SELECT e.nombre AS estado, COUNT(*) AS reservas,
       CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5, 1)) AS porcentaje
FROM ADJG.reserva r
JOIN ADJG.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
GROUP BY e.nombre
ORDER BY reservas DESC;

-- Ingresos por medio de pago
SELECT m.nombre AS medio_pago, COUNT(*) AS pagos, SUM(p.monto) AS ingresos,
       CAST(100.0 * SUM(p.monto) / SUM(SUM(p.monto)) OVER () AS DECIMAL(5, 1)) AS porcentaje
FROM ADJG.pago p
JOIN ADJG.medio_pago m ON m.id_medio_pago = p.id_medio_pago
WHERE p.estado = 'Confirmado'
GROUP BY m.nombre
ORDER BY ingresos DESC;

-- Pagos por estado
SELECT estado, COUNT(*) AS pagos, SUM(monto) AS monto
FROM ADJG.pago
GROUP BY estado
ORDER BY monto DESC;

-- Reservas por mes
SELECT FORMAT(fecha_reserva, 'yyyy-MM') AS mes, COUNT(*) AS reservas, SUM(precio_total) AS monto_reservado
FROM ADJG.reserva
GROUP BY FORMAT(fecha_reserva, 'yyyy-MM')
ORDER BY mes;

-- Top 10 clientes por cantidad de reservas
SELECT TOP 10 WITH TIES
       CONCAT_WS(' ', p.nombres, p.apaterno, p.amaterno) AS cliente,
       COUNT(*) AS reservas
FROM ADJG.reserva r
JOIN ADJG.persona p ON p.id_persona = r.id_cliente
GROUP BY p.nombres, p.apaterno, p.amaterno
ORDER BY reservas DESC;

-- Ingresos por cliente
SELECT CONCAT_WS(' ', pe.nombres, pe.apaterno, pe.amaterno) AS cliente,
       SUM(pg.monto) AS ingresos
FROM ADJG.pago pg
JOIN ADJG.reserva r  ON r.id_reserva = pg.id_reserva
JOIN ADJG.persona pe ON pe.id_persona = r.id_cliente
WHERE pg.estado = 'Confirmado'
GROUP BY pe.nombres, pe.apaterno, pe.amaterno
ORDER BY ingresos DESC;

-- Concentración: participación de los 10 clientes con más ingresos
WITH ing AS (
    SELECT r.id_cliente, SUM(pg.monto) AS ingresos
    FROM ADJG.pago pg
    JOIN ADJG.reserva r ON r.id_reserva = pg.id_reserva
    WHERE pg.estado = 'Confirmado'
    GROUP BY r.id_cliente
    HAVING SUM(pg.monto) > 0
)
SELECT COUNT(*) AS clientes_con_ingresos,
       SUM(CASE WHEN rk <= 10 THEN ingresos END) AS ingresos_top10,
       CAST(100.0 * SUM(CASE WHEN rk <= 10 THEN ingresos END) / SUM(ingresos) AS DECIMAL(5, 1)) AS porcentaje_top10
FROM (SELECT ingresos, ROW_NUMBER() OVER (ORDER BY ingresos DESC) AS rk FROM ing) t;
GO
