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
| `02_importacion_exportacion/importacion.sql` | Exportación con bcp, staging, validación e importación de clientes |
| `03_backups/backup_full.sql` | Comando de exportación a .bacpac y conteo previo |
| `03_backups/restauracion.sql` | Comando de importación, contraseñas de logins y verificación |
| `03_backups/TurismoPeru_ADJG_Full.bacpac` | Backup completo (esquema y datos) |
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
| `rol_admin` | Miembro de `db_owner` solo en `TurismoPeru_ADJG`. El login `ADJG_admin` tiene además VIEW DEFINITION sobre los logins del vendedor y el analista | Ningún rol a nivel de servidor |

Se agregaron algunos permisos que el enunciado no menciona:
- **Vendedor - `persona`:** `cliente.id_persona` depende de `persona`, sin INSERT ahí no se podría registrar un cliente.
- **Analista - `estado_reserva`, `medio_pago` y nombres de `persona`:** el reporte necesita mostrar estados,
  medios de pago y nombres de clientes. En `persona` el permiso es solo por columnas, así que el analista no ve
  datos personales como el documento o el email.
- **Admin - VIEW DEFINITION en los logins:** sin esto, SqlPackage no puede resolver a qué login pertenece cada
  usuario y el export falla (`SQL71501`). Solo permite ver esos dos logins, no modificarlos.

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

## Importación y exportación
Todo se hace con el login `ADJG_admin`.

1. **Exportación:** con `bcp queryout` se generaron `clientes.csv`, `reservas.csv`, `pago.csv` y
   `lugaresturisticos.csv` en UTF-8 (`-C 65001`), con encabezado. Los textos que tienen comas van entre comillas.
2. **Staging:** se crea `ADJG.cliente_importacion` (Documento, Nombres, ApellidoPaterno, ApellidoMaterno),
   sin restricciones para que la carga no falle por datos malos.
3. **Importación:** `bcp ADJG.cliente_importacion in clientes.csv ... -F 2` (se salta el encabezado).
4. **Validación:** cada registro se clasifica como sin documento, formato inválido, faltan nombres,
   duplicado en el archivo, ya existe en la BD, no es DNI o válido.
5. **Inserción:** solo los válidos pasan a `persona` y `cliente`, dentro de una transacción. Como el archivo no
   trae tipo de documento, solo se registra automáticamente un DNI (8 dígitos).

Resultado:

| Registros | Documentos distintos | Duplicados en archivo | Ya existían | Inválidos | Insertados |
|---|---|---|---|---|---|
| 53 | 50 | 5 | 48 | 0 | 0 |

El archivo salió de la misma base, así que todos los clientes ya existían y no se insertó nada. Esto confirma que
la validación evita duplicados. En el archivo se repiten `12345678` (3 veces) y `87654321` (2 veces) porque en la
base son documentos de distinto tipo con el mismo número.

## Procedimiento de restauración
El backup es `03_backups/TurismoPeru_ADJG_Full.bacpac`, generado con SqlPackage usando `ADJG_admin`.
Un .bacpac siempre es completo, por eso no hay backup diferencial.

1. Instalar SqlPackage: `dotnet tool install -g microsoft.sqlpackage`
2. Importar en un servidor que no tenga una base con ese nombre:
   ```bash
   sqlpackage /Action:Import /SourceFile:03_backups/TurismoPeru_ADJG_Full.bacpac \
     /TargetServerName:localhost /TargetDatabaseName:TurismoPeru_ADJG /TargetTrustServerCertificate:True
   ```
3. El .bacpac no guarda las contraseñas reales de los logins. Si se crean en la importación, quedan con una
   contraseña aleatoria, así que se ejecuta `restauracion.sql` para asignarlas:
   ```bash
   set -a; source .env; set +a
   sqlcmd -S localhost -E -C -i 03_backups/restauracion.sql \
     -v PWD_ADMIN="$PWD_ADMIN" PWD_VENDEDOR="$PWD_VENDEDOR" PWD_ANALISTA="$PWD_ANALISTA"
   ```
4. Comparar los conteos con los de `backup_full.sql`.

Se probó restaurando en una instancia local de SQL Server 2025:

| | Original | Restaurada |
|---|---|---|
| Tablas / filas | 39 / 4445 | 39 / 4445 |
| persona / cliente / reserva / pago | 106 / 53 / 102 / 116 | 106 / 53 / 102 / 116 |
| Suma de pagos | 353575.50 | 353575.50 |

Los usuarios quedaron enlazados a sus logins, los roles con sus miembros y los permisos se mantienen
(`ADJG_vendedor` puede leer `cliente` pero no borrar).

## Configuración del reporte
Pendiente.

## Capturas de pantalla
Pendiente.

## Autor
Antony David Julcamoro Gutty - Ingeniería de Sistemas, Universidad Nacional de Cajamarca.
