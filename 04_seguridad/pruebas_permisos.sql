-- Se ejecuta con un usuario administrador. Cada prueba se hace dentro de una
-- transacción que se revierte, así los datos no cambian.
USE TurismoPeru_ADJG;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* ========== ANALISTA ========== */
EXECUTE AS USER = 'ADJG_analista';
SELECT USER_NAME() AS usuario_actual;
GO

-- Permitido
SELECT TOP 5 id_pago, id_reserva, monto, fecha_pago, estado FROM ADJG.pago;
SELECT TOP 5 id_reserva, codigo_reserva, precio_total FROM ADJG.reserva;
GO

-- Rechazado
BEGIN TRAN;
INSERT INTO ADJG.pago (id_reserva, id_medio_pago, monto, numero_operacion, estado)
VALUES (1, 1, 150.00, 'PRUEBA-ANALISTA', 'Pendiente');
ROLLBACK;
GO

BEGIN TRAN;
UPDATE ADJG.pago SET monto = 0 WHERE id_pago = 1;
ROLLBACK;
GO

BEGIN TRAN;
DELETE FROM ADJG.reserva WHERE id_reserva = 1;
ROLLBACK;
GO

-- Rechazado: columna no permitida
SELECT numero_documento, email FROM ADJG.persona;
GO

REVERT;
GO

/* ========== VENDEDOR ========== */
EXECUTE AS USER = 'ADJG_vendedor';
SELECT USER_NAME() AS usuario_actual;
GO

-- Permitido
SELECT TOP 5 id_persona, fecha_nacimiento FROM ADJG.cliente;
SELECT TOP 5 id_alojamiento, Nombre FROM ADJG.alojamiento;
GO

BEGIN TRAN;
DECLARE @id INT;
INSERT INTO ADJG.persona (tipo_persona, nombres, apaterno, amaterno, razon_social,
                          id_tipo_documento, numero_documento, id_nacionalidad)
VALUES ('N', 'Prueba', 'Vendedor', 'Permisos', 'Prueba Vendedor Permisos', 1, '99999901', 142);
SET @id = SCOPE_IDENTITY();
INSERT INTO ADJG.cliente (id_persona, fecha_nacimiento) VALUES (@id, '2000-01-01');
SELECT 'Cliente insertado' AS resultado, @id AS id_persona;
ROLLBACK;
GO

BEGIN TRAN;
INSERT INTO ADJG.reserva (codigo_reserva, id_cliente, id_paquete, id_empleado, id_alojamiento,
                          id_habitacion, fecha_inicio, fecha_fin, numero_personas,
                          precio_total, adelanto, saldo_pendiente, id_estado_reserva)
SELECT 'PRUEBA-VEND-01', id_cliente, id_paquete, id_empleado, id_alojamiento,
       id_habitacion, fecha_inicio, fecha_fin, numero_personas,
       precio_total, adelanto, saldo_pendiente, id_estado_reserva
FROM ADJG.reserva WHERE id_reserva = 1;
SELECT 'Reserva insertada' AS resultado;
ROLLBACK;
GO

-- Rechazado
BEGIN TRAN;
DELETE FROM ADJG.cliente WHERE id_persona = 1;
ROLLBACK;
GO

BEGIN TRAN;
DELETE FROM ADJG.reserva WHERE id_reserva = 1;
ROLLBACK;
GO

SELECT TOP 5 * FROM ADJG.pago;
GO

ALTER ROLE db_owner ADD MEMBER ADJG_vendedor;
GO

CREATE USER usuario_prueba WITHOUT LOGIN;
GO

REVERT;
GO

SELECT USER_NAME() AS usuario_actual;
GO
