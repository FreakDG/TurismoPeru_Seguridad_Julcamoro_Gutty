# TurismoPeru_Seguridad_Julcamoro_Gutty

## Nombre del proyecto
**TurismoPeru_Seguridad_Julcamoro_Gutty** – Administración de la Seguridad de Base de Datos
(Tercera Evaluación – Base de Datos II, Grupo B – Universidad Nacional de Cajamarca).

## Descripción
Implementación de un mecanismo básico de administración y seguridad para el sistema de
información turística de la empresa **TurismoPeru**, sobre la base de datos
`TurismoPeru_ADJG` (esquema `ADJG`) en SQL Server. El proyecto comprende:

- Administración de logins, usuarios, roles y permisos bajo el principio de mínimo privilegio.
- Estrategia de importación/exportación de datos con `bcp` y tabla de *staging*.
- Respaldo completo de la base de datos en formato `.bacpac`.
- Reporte analítico de clientes, reservas y pagos en Power BI.
- Versionamiento de todos los scripts en GitHub.

## Tecnologías utilizadas
| Tecnología | Uso |
|---|---|
| SQL Server / T-SQL | Base de datos, seguridad, importación y respaldo |
| SQL Server Management Studio (SSMS) | Ejecución de scripts |
| bcp (Bulk Copy Program) | Exportación e importación de archivos CSV |
| SqlPackage / SSMS Data-tier Application | Generación del backup `.bacpac` |
| Power BI Desktop | Modelo, medidas DAX y dashboard |
| Git / GitHub | Control de versiones |

## Requisitos
- SQL Server con autenticación mixta (SQL Server y Windows) habilitada.
- Base de datos `TurismoPeru_ADJG` (esquema `ADJG`) creada y con datos.
- Un login con permisos para crear logins (`securityadmin` o `sysadmin`) y para administrar la base (`db_owner`).
- SQL Server Management Studio (SSMS) con **modo SQLCMD** disponible.
- Utilidad `bcp` (incluida en las *SQL Server Command Line Utilities*).
- SqlPackage o SSMS (*Export Data-tier Application*) para el `.bacpac`.
- Power BI Desktop.
- Git.

## Configuración

### Manejo seguro de credenciales
Ningún script del repositorio contiene servidores, usuarios ni contraseñas reales.

| Archivo | ¿Se publica? | Contenido |
|---|---|---|
| `.env.example` | Sí | Plantilla con las variables necesarias, **sin valores** |
| `.env` | **No** (está en `.gitignore`) | Valores reales, solo en el equipo local |

1. Copiar la plantilla y completar los valores:
   ```bash
   cp .env.example .env
   ```
2. Los scripts que requieren contraseñas (por ejemplo `01_logins.sql`) usan **variables SQLCMD**
   en lugar de valores escritos:
   ```sql
   CREATE LOGIN ... WITH PASSWORD = '$(PWD_ADMIN)';
   ```
   Los valores se proporcionan al ejecutar, ya sea con `sqlcmd -v PWD_ADMIN="..."` o con
   `:setvar` en SSMS (menú *Query → SQLCMD Mode*), sin guardarlos en el repositorio.
3. Los comandos `bcp` se documentan con marcadores (`<SERVIDOR>`, `<USUARIO>`); si se omite `-P`,
   `bcp` solicita la contraseña de forma interactiva.
4. En las capturas de pantalla de `evidencias/` se ocultan servidor, usuario y contraseñas.

Verificación antes de cada commit:
```bash
git check-ignore -v .env   # debe indicar que .env está ignorado
git status                 # .env no debe aparecer en la lista
```

## Estructura del proyecto
```
TurismoPeru_Seguridad_Julcamoro_Gutty/
├── README.md
├── .gitignore
├── .env.example                Plantilla de configuración (sin credenciales)
├── 01_usuarios_roles/          Logins, usuarios, roles y permisos
├── 02_importacion_exportacion/ Exportación (bcp) e importación con staging
├── 03_backups/                 Backup FULL (.bacpac)
├── 04_seguridad/               Pruebas de permisos (mínimo privilegio)
├── 05_reportes/                Consultas base del reporte e interpretación
├── 06_powerbi/                 Documentación del reporte Power BI
└── evidencias/                 Capturas de pantalla
```

## Scripts disponibles
_(En construcción)_

## Principio de mínimo privilegio
_(En construcción)_

## Procedimiento de restauración
_(En construcción)_

## Configuración del reporte
_(En construcción)_

## Capturas de pantalla
_(En construcción)_

## Autor
**Antony David Julcamoro Gutty**
Escuela Profesional de Ingeniería de Sistemas – Universidad Nacional de Cajamarca
Curso: Base de Datos II – Grupo B
