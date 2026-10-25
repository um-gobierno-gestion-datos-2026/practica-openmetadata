# Laboratorio individual: OpenMetadata en GitHub Codespaces

Cada estudiante tendrá OpenMetadata, su ejecutor de ingestas y PostgreSQL con el
caso de movilidad. No necesita instalar aplicaciones en su computadora.

## Usuarios y contraseñas por defecto

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

## 1. Crear el repositorio (docente)

1. Crear en GitHub un repositorio vacío llamado `openmetadata-codespaces`.
2. Descomprimir el paquete y subir **el contenido** de esta carpeta a la raíz.
   Incluir `.devcontainer/`, `.github/` y `.gitignore`: pueden estar ocultos en el explorador.
   GitHub debe mostrar `.devcontainer/devcontainer.json` directamente en la raíz,
   sin una segunda carpeta `openmetadata-codespaces` intermedia.
3. Para subir con Git desde la carpeta descomprimida:

   ```bash
   git init -b main
   git add .
   git commit -m "Agregar laboratorio OpenMetadata para Codespaces"
   git remote add origin https://github.com/TU_USUARIO/openmetadata-codespaces.git
   git push -u origin main
   ```

4. Opcional: Settings > General > Template repository. Cada estudiante puede
   elegir Use this template > Create a new repository para conservar su trabajo.
5. Realizar la prueba piloto del apartado de verificación antes de distribuirlo.

## 2. Abrir el entorno (estudiante)

1. Crear tu repositorio desde el template, o hacer un fork si no está configurado.
2. Code > Codespaces > menú de opciones > New with options.
3. Seleccionar una máquina de **4 CPU y 16 GB RAM**, con al menos 32 GB de almacenamiento.
   La configuración solicita estos recursos; su disponibilidad depende de tu cuenta.
4. Crear el Codespace. Se prepara Docker y se ejecuta `scripts/start.sh` automáticamente.
   El primer arranque descarga varias imágenes y puede demorar varios minutos.
5. Cuando termine, abrir la pestaña **Ports** y el puerto **8585** en el navegador.
   Mantener la visibilidad **Private**. Si falta el puerto, agregarlo manualmente.
6. Entrar a OpenMetadata con `admin@open-metadata.org` / `admin`.
   Son credenciales del quickstart para un laboratorio privado con datos sintéticos.

Si el inicio falla, ejecutar `bash scripts/status.sh`. Para reintentar sin borrar datos:

```bash
bash scripts/start.sh
```

## 3. Conectar PostgreSQL desde OpenMetadata

En Settings > Services > Databases, agregar un servicio PostgreSQL:

| Campo | Valor |
|---|---|
| Nombre del servicio | `movilidad_postgres` |
| Host y puerto | `postgres-lab:5432` |
| Base / Database | `movilidad` |
| Usuario | `catalogo_lector` |
| Contraseña | `lector_lab` |
| SSL | desactivado / Disable para esta red privada de laboratorio |
| Filtro de esquemas (Include) | `^movilidad_g01$` |

Usar **Test Connection**. El host es el nombre del contenedor, porque el ejecutor
accede por la red Docker. No utilizar la dirección pública del Codespace ni localhost.

Crear y ejecutar Metadata Ingestion; desactivar Override Metadata para preservar
las descripciones escritas. Verificar las cuatro tablas: `tramos`, `reportes_crudos`,
`reportes_validos`, `resumen_diario`. La ingesta inicial se hace manualmente para
comprender la diferencia entre la base y su representación en el catálogo.

El puerto 8080 corresponde a Airflow (ejecutor), no a otro catálogo. Si hay que
revisar su UI, usar `admin` / `admin`. No es necesario crear DAGs para esta práctica.
El quickstart conserva `http://ingestion:8080` como endpoint del ejecutor y
`http://openmetadata-server:8585/api` para su comunicación con el catálogo.

## 4. Consultar los datos y realizar la actividad

Desde la terminal integrada del navegador:

```bash
bash scripts/sql.sh actividad/sql/02_explorar.sql
bash scripts/sql.sh actividad/sql/03_test_conservacion.sql
```

Para una consola SQL interactiva: `bash scripts/sql.sh`. Salir con `\q`.
El usuario `estudiante` puede modificar los datos; `catalogo_lector` solo los consulta.
No ejecutar nuevamente `01_preparar_caso.sql`: se cargó automáticamente al crear la base.

Secuencia sugerida de 120 minutos:

| Trabajo | Minutos |
|---|---:|
| Comprender el criterio y explorar el catálogo | 25 |
| Documentar columnas, granularidad, glosario y clasificación | 20 |
| Asignar responsables y registrar la incidencia | 15 |
| Dibujar y justificar linaje manual entre las cuatro tablas | 20 |
| Perfilar, crear y ejecutar pruebas, contrastar resultados | 25 |
| Analizar impacto de un cambio y guardar evidencias | 15 |

Completar `actividad/plantillas/`. Conservar evidencia de responsables, términos,
etiquetas, grafo de linaje y resultados de pruebas. El linaje se construye manualmente;
las tablas de este caso no permiten inferirlo automáticamente a partir de vistas.

Para el perfilado, configurar 100% de la muestra y comprobar que la ejecución
termina. Para la prueba de conservación, configurar Table Custom SQL Query con el
contenido de `03_test_conservacion.sql`, estrategia ROWS y umbral 0. Crear la definición
no la ejecuta: correr la pipeline de calidad y revisar el estado.

El resumen tiene un error intencional. Después del diagnóstico y cuando la docente
lo indique, consultar `actividad/docente/`. Allí están la solución y el SQL para
corregir el resumen sin eliminar su tabla. Repetir pruebas y perfilado después.

## 5. Guardar y terminar

```bash
bash scripts/backup.sh
bash scripts/stop.sh
```

Guardar plantillas y evidencias en tu repositorio, sin contraseñas ni tokens.
Descargar también la copia SQL de `evidencias/` (se excluye de Git por defecto).
El backup cubre PostgreSQL; para los metadatos del catálogo conservar capturas y
las definiciones relevantes en las plantillas. No es un backup completo de OpenMetadata.
Los volúmenes conservan el estado mientras se mantenga el Codespace; eliminarlo
borra su almacenamiento. Reconstruir el contenedor no sustituye una copia externa.

**Detener el Codespace desde GitHub al terminar.** Detener Docker o cerrar el
navegador no finaliza el cómputo de una máquina que sigue activa. Revisar cuotas
y almacenamiento en la cuenta antes de la clase. No se requiere GitHub Education.

## Diagnóstico

| Síntoma | Acción |
|---|---|
| Docker no disponible | Revisar creation log y reconstruir el dev container con su configuración |
| Proceso terminado por memoria / exit 137 | Confirmar 4 CPU y 16 GB; detener y cambiar tipo de máquina |
| Puerto 8585 aún no responde | `bash scripts/status.sh`; comprobar migración y servidor |
| Catálogo abre pero falla ingesta | Revisar `ingestion`, Test Connection y logs; no cambiar endpoints internos a URLs públicas |
| Error de conexión PostgreSQL | Host `postgres-lab:5432`, base `movilidad`, lector y contraseña de la tabla anterior |
| Pocas tablas encontradas | Filtro `^movilidad_g01$` y revisar estado de Metadata Ingestion |
| Prueba creada sin resultado | Ejecutar la pipeline; si falla infraestructura, marcar el SQL externo como evidencia externa |
| Credenciales de BD distintas tras editar configuración | Las variables de inicialización no cambian usuarios en un volumen ya creado |

No usar `docker compose down -v` como diagnóstico: elimina los volúmenes del laboratorio.
No hay un reinicio destructivo automático.

## Verificación y alcance

Base: quickstart oficial OpenMetadata **1.12.6**, PostgreSQL **16.10**.
Ver `vendor/README.md` para origen y cambios. La configuración no está orientada a producción.

En este entorno de preparación se revisaron la configuración, la sintaxis de scripts
y el caso SQL. **No se ejecutó Docker ni un Codespace aquí.** El workflow incluido
valida Compose y prueba el caso con PostgreSQL real cuando se ejecuta en GitHub Actions.
No sustituye la prueba piloto completa de ingesta, perfilado y calidad en Codespaces.

Antes de clase: crear un Codespace limpio, esperar todos los servicios, iniciar sesión,
conectar la base con el lector, ingerir cuatro tablas, ejecutar perfilado y la prueba,
corregir el resumen y repetirla. T02 debe pasar de uno a dos reportes y conservar
una velocidad informada y media de 26 km/h. Detener y reabrir para revisar persistencia.

## Referencias

- https://docs.open-metadata.org/v1.12.x/quick-start/local-docker-deployment
- https://docs.open-metadata.org/v1.12.x/connectors/database/postgres
- https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers
