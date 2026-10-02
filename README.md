# TurismoPeru_Seguridad_Julcamoro_Gutty

## Nombre del proyecto
TurismoPeru_Seguridad_Julcamoro_Gutty - Tercera evaluación de Base de Datos II (Grupo B), UNC.

## Descripción
Administración de la seguridad de la base de datos `TurismoPeru_ADJG` (esquema `ADJG`) en SQL Server:
usuarios, roles y permisos, importación con bcp, backup en .bacpac y un reporte en Power BI sobre
clientes, reservas y pagos.

## Tecnologías utilizadas
- SQL Server y SSMS
- bcp
- SqlPackage
- Power BI Desktop
- Git y GitHub

## Requisitos
- SQL Server con autenticación mixta.
- Base de datos `TurismoPeru_ADJG` con datos.
- Un login con permisos para crear logins y administrar la base.
- bcp y SqlPackage instalados.
- Power BI Desktop.

## Configuración
Las credenciales van en un archivo `.env` que no se sube al repositorio (está en el `.gitignore`).
Para configurarlo se copia la plantilla y se completan los valores:

```bash
cp .env.example .env
```

Las contraseñas de los logins no están escritas en los scripts, se pasan como variables SQLCMD
(`$(PWD_ADMIN)`, etc.) al momento de ejecutar. En las capturas se ocultan servidor y credenciales.

## Estructura del proyecto
```
TurismoPeru_Seguridad_Julcamoro_Gutty/
├── README.md
├── .gitignore
├── .env.example
├── 01_usuarios_roles/
├── 02_importacion_exportacion/
├── 03_backups/
├── 04_seguridad/
├── 05_reportes/
├── 06_powerbi/
└── evidencias/
```

## Scripts disponibles
| Script | Descripción |
|---|---|
| `01_usuarios_roles/01_logins.sql` | Logins `ADJG_admin`, `ADJG_vendedor`, `ADJG_analista` |
| `01_usuarios_roles/02_users.sql` | Usuarios en `TurismoPeru_ADJG` |
| `01_usuarios_roles/03_roles.sql` | Roles `rol_vendedor`, `rol_analista` y `rol_admin` |
| `01_usuarios_roles/04_permisos.sql` | Permisos de cada rol |
| `04_seguridad/pruebas_permisos.sql` | Pruebas de lo que cada perfil puede y no puede hacer |

Se usa el prefijo `ADJG` en los logins porque el servidor es compartido. `01_logins.sql` se ejecuta así:

```bash
set -a; source .env; set +a
export SQLCMDPASSWORD="$DB_PASSWORD"
sqlcmd -S "$DB_SERVER" -U "$DB_USER" -C -i 01_usuarios_roles/01_logins.sql \
  -v PWD_ADMIN="$PWD_ADMIN" PWD_VENDEDOR="$PWD_VENDEDOR" PWD_ANALISTA="$PWD_ANALISTA"
```

## Principio de mínimo privilegio

### Permisos por rol
| Rol | Puede | No puede |
|---|---|---|
| `rol_vendedor` | SELECT e INSERT en `cliente`, `reserva` y `persona`; SELECT en `alojamiento` y `habitacion` | DELETE en `cliente` y `reserva`, ver pagos, administrar usuarios, roles o backups |
| `rol_analista` | SELECT en `cliente`, `reserva`, `pago`, `alojamiento`, `habitacion`, `paquete`, `lugar_turistico`, `estado_reserva`, `medio_pago` y en los nombres de `persona` | INSERT, UPDATE y DELETE en el esquema `ADJG`, ver documento, teléfono o email, administrar usuarios, roles o backups |
| `rol_admin` | Miembro de `db_owner` solo en `TurismoPeru_ADJG` | Ningún rol a nivel de servidor |

Se agregaron algunos permisos que el enunciado no menciona:
- **Vendedor - `persona`:** `cliente.id_persona` depende de `persona`, sin INSERT ahí no se podría registrar un cliente.
- **Analista - `estado_reserva`, `medio_pago` y nombres de `persona`:** el reporte necesita mostrar estados,
  medios de pago y nombres de clientes. En `persona` el permiso es solo por columnas, así que el analista no ve
  datos personales como el documento o el email.

### ¿Por qué no asignar db_owner al vendedor o al analista?
`db_owner` puede hacer cualquier cosa dentro de la base: modificar o borrar tablas y datos, crear usuarios, cambiar
permisos y hacer backups. Si el vendedor o el analista lo tuvieran:
- Podrían borrar clientes, reservas o pagos, que es justo lo que no deben hacer.
- Podrían darse más permisos a sí mismos o a otros usuarios, y los permisos dejarían de tener sentido.
- Un error o una cuenta comprometida afectaría a toda la base y no solo a lo que ese perfil necesita.
- Cualquier DENY que se les aplique lo podrían quitar ellos mismos, porque `db_owner` administra los permisos.

Cada perfil debe tener solo lo necesario para su trabajo. Por eso los permisos se dan por rol y con DENY explícito
en lo que no deben hacer.

### Prueba
En `04_seguridad/pruebas_permisos.sql` se usa `EXECUTE AS USER` para probar cada perfil. Las pruebas que modifican
datos están dentro de una transacción con ROLLBACK, así que no alteran la base. Resultados:

| Perfil | Operación | Resultado |
|---|---|---|
| Analista | SELECT en `pago` y `reserva` | Permitido |
| Analista | `INSERT INTO ADJG.pago` | Rechazado (Msg 229) |
| Analista | UPDATE en `pago`, DELETE en `reserva` | Rechazado (Msg 229) |
| Analista | SELECT de `numero_documento` y `email` en `persona` | Rechazado (Msg 230) |
| Vendedor | SELECT en `cliente` y `alojamiento` | Permitido |
| Vendedor | INSERT de un cliente (`persona` + `cliente`) y de una reserva | Permitido |
| Vendedor | DELETE en `cliente` y `reserva` | Rechazado (Msg 229) |
| Vendedor | SELECT en `pago` | Rechazado (Msg 229) |
| Vendedor | Agregarse a `db_owner` o crear usuarios | Rechazado (Msg 15151 / 15247) |

```
Msg 229, Level 14, State 5
The INSERT permission was denied on the object 'pago', database 'TURISMOPERU_ADJG', schema 'ADJG'.
```

## Procedimiento de restauración
Pendiente.

## Configuración del reporte
Pendiente.

## Capturas de pantalla
Pendiente.

## Autor
Antony David Julcamoro Gutty - Ingeniería de Sistemas, Universidad Nacional de Cajamarca.
