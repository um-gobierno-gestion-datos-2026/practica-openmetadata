# Accesos por defecto del laboratorio

| Servicio / cuenta | Usuario | Contraseña | Base / puerto |
|---|---|---|---|
| OpenMetadata | `admin@open-metadata.org` | `admin` | UI: `8585` |
| Airflow (ejecutor) | `admin` | `admin` | UI: `8080` |
| PostgreSQL (administrar el caso) | `estudiante` | `estudiante_lab` | `movilidad`, `5432` |
| PostgreSQL (lector para OpenMetadata) | `catalogo_lector` | `lector_lab` | `movilidad`, `5432` |

La imagen PostgreSQL es `postgres:16.10-bookworm` y se inicia automáticamente junto
con OpenMetadata. La base `movilidad` y las tablas del caso se crean en su primer
arranque. `POSTGRES_USER=estudiante` crea una cuenta administradora de la instancia
PostgreSQL de laboratorio; no existe un login llamado `postgres` en esta configuración.

Desde el conector de OpenMetadata: host `postgres-lab:5432`.
Desde la terminal del Codespace o VS Code: host `localhost`, puerto `5432`.
PostgreSQL no tiene una interfaz web en ese puerto: utilizar un cliente SQL o
`bash scripts/sql.sh` para la consola incluida.

En Codespaces mantener todos los puertos privados. Estas claves conocidas están
pensadas para los datos sintéticos de la práctica.
Las credenciales PostgreSQL se inicializan solo al crear el volumen: cambiar el
YAML no modifica las contraseñas de una instancia ya inicializada.
