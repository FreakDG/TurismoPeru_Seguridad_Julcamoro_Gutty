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

Se usa el prefijo `ADJG` en los logins porque el servidor es compartido. `01_logins.sql` se ejecuta así:

```bash
set -a; source .env; set +a
export SQLCMDPASSWORD="$DB_PASSWORD"
sqlcmd -S "$DB_SERVER" -U "$DB_USER" -C -i 01_usuarios_roles/01_logins.sql \
  -v PWD_ADMIN="$PWD_ADMIN" PWD_VENDEDOR="$PWD_VENDEDOR" PWD_ANALISTA="$PWD_ANALISTA"
```

## Principio de mínimo privilegio
Pendiente.

## Procedimiento de restauración
Pendiente.

## Configuración del reporte
Pendiente.

## Capturas de pantalla
Pendiente.

## Autor
Antony David Julcamoro Gutty - Ingeniería de Sistemas, Universidad Nacional de Cajamarca.
