# Laboratorio: catalogación de archivos y carga a PostgreSQL

Cada estudiante tiene su propio OpenMetadata 1.12.6, ejecutor de ingestas,
MinIO compatible con S3 y PostgreSQL 16.10. Todos los datos son sintéticos.

## Qué se inicia y qué hace el estudiante

Al arrancar se prepara OpenMetadata, el bucket `movilidad` en MinIO con
`openmetadata.json` disponible, un usuario lector de almacenamiento y cuatro tablas
vacías en PostgreSQL nuevo. El manifiesto es parte de la preparación técnica del
laboratorio; el estudiante comienza publicando los CSV.
**No se publican los CSV ni se cargan filas automáticamente.**

La práctica tiene dos etapas independientes:

1. Publicar archivos en MinIO y catalogarlos en OpenMetadata como almacenamiento.
2. Ejecutar la carga de esos objetos a PostgreSQL y catalogar las tablas resultantes.

OpenMetadata guarda metadatos. MinIO conserva los CSV y PostgreSQL las filas de las tablas.
MinIO utiliza buckets y prefijos de objetos. Su interfaz muestra esos prefijos como
carpetas, pero no es un conector nativo al filesystem local de la computadora.

## Arranque local en Windows (recomendado)

Abrir Docker Desktop. Actualizar el contenido completo del proyecto desde este
paquete, sin eliminar volumenes. Desde CMD, en la carpeta que contiene compose.yaml:

```bat
iniciar.cmd
```

El lanzador inicia todos los servicios y espera OpenMetadata, Airflow, PostgreSQL,
MinIO y la preparacion del bucket. Si algo falla muestra el error, no borra datos.
Tambien se puede ejecutar desde PowerShell con `./iniciar.cmd`.

## Arranque local con Docker Compose

Descomprimir o clonar el repositorio. Desde su raíz, con Docker y Compose iniciados:

```bash
docker compose up -d
docker compose ps -a
```

MinIO y `minio-init` son servicios del arranque por defecto, sin activar perfiles.
Los perfiles se reservan para los comandos manuales de publicacion y carga.

El proceso `minio-init` crea el bucket y el lector, y publica el manifiesto si falta.
Conserva un manifiesto ya existente. Debe terminar con Exited (0), igual que la
migración del catálogo. Los CSV se publican manualmente durante la actividad.

### Si el puerto 8585 está ocupado

Identificar qué contenedor ya lo publica:

```bash
docker ps --filter "publish=8585"
```

Una instalación anterior puede seguir respondiendo en el navegador aunque el
servidor de este laboratorio no haya podido arrancar. Comprobar también la versión
de su imagen: el laboratorio utiliza servidor e ingestion de OpenMetadata 1.12.6.

Si la instalación anterior es `openmetadata_server` y se va a usar el laboratorio
nuevo, detener ese contenedor para liberar el puerto:

```bash
docker stop openmetadata_server
docker compose up -d
```

El contenedor anterior y sus datos se conservan. Los dos proyectos tienen catálogos
independientes: un servicio creado en la instalación anterior no aparece
automáticamente en el catálogo nuevo.

## Arranque en Codespaces

Subir todo el contenido del paquete a la raíz de un repositorio, incluyendo
`.devcontainer` y `.github`. Opcionalmente marcarlo como template para la clase.
Cada estudiante crea su copia y elige Code > Codespaces > New with options,
con 4 CPU y 16 GB RAM. El devcontainer inicia automáticamente los servicios.
Abrir los puertos 8585 y 9001 en Ports, conservando su visibilidad privada.
La cuota y el almacenamiento dependen de la cuenta GitHub.

## Accesos

| Servicio | Acceso local | Usuario | Contraseña |
|---|---|---|---|
| OpenMetadata | http://localhost:8585 | admin@open-metadata.org | admin |
| MinIO Console | http://localhost:9001 | minioadmin | minioadmin_lab |
| Airflow | http://localhost:8080 | admin | admin |
| PostgreSQL administrador | localhost:5432, base movilidad | estudiante | estudiante_lab |
| PostgreSQL lector del catálogo | postgres-lab:5432 desde Docker | catalogo_lector | lector_lab |
| S3 lector del catálogo | http://minio:9000 desde Docker | catalogo_storage | lector_storage_lab |

En la conexión S3 el usuario lector actúa como Access Key ID y su contraseña
como Secret Access Key. Región: `us-east-1`. No requiere cuenta AWS.
`9000` es la API S3 y `9001` la consola. Dentro de Docker no usar localhost para
conectar desde OpenMetadata a otro servicio. Las credenciales son solo de laboratorio.

## Etapa 1. Publicar un archivo y una carpeta

### 1.1 Archivo individual

Abrir MinIO Console, entrar al bucket `movilidad` y crear/abrir el prefijo
`individual/`. Elegir Upload File y subir:

`actividad/fuentes/individual/tramos.csv`

Resultado esperado: `s3://movilidad/individual/tramos.csv`.

Alternativa por terminal, sin instalar un cliente S3 local:

```bash
docker compose run --rm archivos archivo
```

### 1.2 Carpeta de reportes

Subir la carpeta `actividad/fuentes/reportes` al bucket manteniendo el prefijo
`reportes/`, o crear ese prefijo y subir sus dos CSV. Verificar las claves:

- `reportes/reportes_2026-10-19.csv` (6 filas de datos).
- `reportes/reportes_2026-10-20.csv` (1 fila de datos).

La publicación recursiva desde la carpeta local se practica también con:

```bash
docker compose run --rm archivos carpeta
docker compose run --rm archivos listar
```

Esta operación copia archivos desde un filesystem local montado al almacén S3.
Los dos archivos de reportes comparten columnas y forman un conjunto lógico.
No confundir cantidad de archivos con cantidad de filas.

## Etapa 1.3. Catalogar las fuentes en OpenMetadata

Settings > Services > Storage > Add New Service, tipo **S3**:

| Campo | Valor |
|---|---|
| Nombre | `movilidad_archivos` |
| AWS Access Key ID | `catalogo_storage` |
| AWS Secret Access Key | `lector_storage_lab` |
| AWS Region | `us-east-1` |
| Endpoint URL (endPointURL) | `http://minio:9000` |
| Bucket Names | `movilidad` |

No configurar un rol IAM ni credenciales temporales. El endpoint es interno y
apunta a MinIO, no a Amazon. Probar conexión, guardar el servicio y crear una
Metadata Ingestion desde Ingestions/Agents, según la interfaz. Mantener Override
Metadata desactivado para conservar descripciones humanas. Desplegar y ejecutar.

En Explore > Containers, o los activos del servicio, buscar el bucket y las
entradas `individual/tramos.csv` y `reportes`. Inspeccionar columnas y procedencia.
El conector de almacenamiento usa entidades Container, distintas de las tablas
PostgreSQL. Si solo aparece el bucket, revisar manifiesto y permisos de lectura.

MinIO no implementa CloudWatch. El conector puede advertir que no recupera métricas
de tamaño y cantidad de objetos y mostrar 0. Comprobar esos valores en MinIO,
no interpretarlos como prueba de que el bucket está vacío.

### Consigna de gobernanza

- Describir qué representa cada conjunto y cada columna.
- Asignar responsables y una clasificación docente de datos sintéticos.
- Vincular términos del glosario: tramo, reporte y reporte válido.
- Explicar qué implica agregar un tercer CSV de reportes al mismo prefijo.
- Registrar evidencia de los activos y de la ejecución de ingesta.

## Etapa 2. Cargar los objetos a PostgreSQL

Después de publicar las fuentes y observarlas en el catálogo:

```bash
docker compose run --rm --build carga
```

La primera ejecución construye la imagen del pequeño cargador Python. Este lee
`individual/tramos.csv` y **todos los CSV bajo `reportes/` desde MinIO**, valida
cabezales y tipos, y reemplaza las filas del caso en una transacción. No usa los
CSV locales como atajo. Un cambio local debe publicarse antes para afectar la carga.
Si falla la lectura o la carga, conserva los datos previos de PostgreSQL.
Repetir la carga no acumula duplicados, pero restaura el error intencional del resumen.
No elimina tablas ni altera sus permisos. Respaldar los datos si ya fueron modificados.

| Tabla en movilidad_g01 | Filas esperadas con los CSV suministrados |
|---|---:|
| tramos | 2 |
| reportes_crudos | 7 |
| reportes_validos | 5 |
| resumen_diario | 3 |

R02 aparece repetido. R03 carece de tramo y queda excluido de los válidos.
R04 carece de velocidad, pero debe contar como reporte. El resumen inicial
lo excluye intencionalmente. El conteo T02 del 19/10 es 1 y debería ser 2,
con velocidad media 26 km/h en ambos casos.

Para abrir una consola SQL:

```bash
docker compose exec postgres-lab psql -U estudiante -d movilidad
```

Después: `SELECT * FROM movilidad_g01.resumen_diario;`. Salir con `\q`.

## Etapa 2.1. Catalogar el destino y documentar el linaje

Crear servicio Database > PostgreSQL `movilidad_postgres`, host `postgres-lab:5432`,
base `movilidad`, usuario `catalogo_lector`, contraseña `lector_lab`.
Ejecutar Metadata Ingestion con Schema Includes `^movilidad_g01$`.

Relacionar procedencia de archivos, proceso de carga, tablas válidas y resumen.
Los procesos suministrados no publican linaje automáticamente. Intentar el enlace
manual Container a Table cuando la interfaz de la versión lo permita. Si la UI
no ofrece ese tipo de enlace, registrar la relación en las fichas con las FQN o
URLs de ambos activos y construir el linaje entre tablas. No presentar una nota
como una arista efectivamente creada. La integración automática del cargador con
la API de linaje queda fuera de esta versión.

Perfilado y pruebas de calidad son ejecuciones adicionales. Usar los SQL de
`actividad/sql/` y la solución de `actividad/docente/` después del diagnóstico.

## Adoptar esta versión con una instalación anterior

Actualizar los archivos y ejecutar `docker compose up -d`. No borrar volúmenes.
Para aplicar solo la preparación del manifiesto a una instancia que ya está
funcionando, actualizar los archivos del proyecto y ejecutar:

```bash
docker compose run --rm minio-init
docker compose run --rm archivos listar
```

No requiere reconstruir imágenes ni reiniciar OpenMetadata o PostgreSQL.
Comprobar que aparece `openmetadata.json` en la raíz de `movilidad`.
Los datos ya existentes en PostgreSQL permanecen. Para mostrar la primera etapa
no hace falta borrarlos: todavía se pueden publicar y catalogar las fuentes.
Cuando se ejecute `carga`, reemplazará las filas con los objetos del bucket.
Las descripciones existentes del servicio PostgreSQL se conservan si no se activa
Override Metadata. No ejecutar el SQL de creación sobre tablas existentes.
No usar `docker compose down -v` para actualizar.

### Corrección del chequeo de Airflow 3

La imagen ingestion 1.12.6 del laboratorio ejecuta Airflow 3. Su endpoint de salud
es `/api/v2/monitor/health`; la ruta anterior `/health` devuelve 404 y hacía que el
contenedor figurara como unhealthy aunque la API estuviera atendiendo solicitudes.

La comprobación actual ejecuta `infra/check_ingestion_health.py` dentro del
contenedor. Verifica la respuesta JSON de la base de metadatos y del scheduler,
y también el estado del procesador de DAGs y del triggerer cuando están informados.
Un HTTP 200 con componentes unhealthy se considera un fallo.

Para aplicar la corrección con MySQL y Elasticsearch ya disponibles y la migración
completada, actualizar los archivos del paquete, incluido el nuevo script de infra,
y ejecutar:

```bash
docker compose up -d --no-deps openmetadata-server ingestion
docker compose ps -a openmetadata-server ingestion
```

Compose recrea ingestion por el cambio de configuración, conservando sus volúmenes.
El puerto 8585 debe estar libre para que el servidor del laboratorio pueda arrancar.
Para ejecutar la comprobación y ver un error concreto:

```bash
docker compose exec ingestion python3 /lab/check_ingestion_health.py
```

Referencia: https://airflow.apache.org/docs/apache-airflow/stable/administration-and-deployment/logging-monitoring/check-health.html

## Preparación técnica del manifiesto (docente)

`minio-init` publica automáticamente `actividad/manifiestos/openmetadata.json` en la
raíz del bucket cuando falta. Tiene una entrada para el CSV de tramos y otra para
el conjunto `reportes/`. El estudiante no debe crearlo ni publicarlo como paso
separado de la actividad.

El conector lo usa para reconocer rutas y extraer estructura. Una entrada de
carpeta representa un conjunto, no necesariamente un activo separado por cada
archivo diario. Una muestra de un archivo no valida todos los archivos.

La preparación conserva un manifiesto existente. Si el docente cambia el archivo
local y quiere reemplazar explícitamente el del bucket, puede ejecutar:

```bash
docker compose run --rm archivos manifiesto
```

Esta acción actualiza solo el manifiesto. No publica CSV ni carga filas a PostgreSQL.

## Guardar y detener

`bash scripts/backup.sh` respalda PostgreSQL, no todo el catálogo ni el bucket.
Guardar las fichas, evidencia del catálogo y los archivos fuente fuera del Codespace.
No guardar claves o tokens reales en el repositorio.

```bash
docker compose stop
```

En Codespaces detener también la máquina desde GitHub. Eliminarla puede perder
volúmenes y archivos no respaldados. Para diagnóstico: `docker compose ps -a`
y `docker compose logs --tail=80 NOMBRE_DEL_SERVICIO`.

## Verificación y límites

Se verificaron localmente la configuración, los CSV, el manifiesto contra el esquema
oficial de OpenMetadata 1.12.6 y pruebas del lector de archivos. El chequeo de Airflow
tiene pruebas HTTP locales para componentes sanos, componentes en fallo, respuestas
incompletas y la ruta antigua con 404. El workflow de
GitHub Actions comprueba publicación S3 y carga PostgreSQL cuando se ejecuta.
En este entorno no hay Docker: sigue pendiente el ensayo completo de arranque,
conexión S3, ingesta y representación de activos en OpenMetadata antes de clase.
Las diapositivas anteriores describen la versión previa y deben adaptarse a esta secuencia.

## Referencias

- https://docs.open-metadata.org/v1.12.x/connectors/storage/s3/yaml
- https://github.com/open-metadata/OpenMetadata/blob/1.12.6-release/openmetadata-spec/src/main/resources/json/schema/metadataIngestion/storage/containerMetadataConfig.json
- https://github.com/open-metadata/OpenMetadata/blob/1.12.6-release/openmetadata-spec/src/main/resources/json/schema/entity/services/connections/storage/s3Connection.json
- https://github.com/minio/minio/releases/tag/RELEASE.2025-04-22T22-12-26Z

## Error 401 al descargar MinIO desde Quay

Esta versión usa mirrors publicados por Teable en GitHub Container Registry, con
las mismas etiquetas que las imágenes originales. No requieren una cuenta AWS ni
cambian los usuarios y claves del laboratorio. Sustituir el compose anterior y
ejecutar:

```bash
docker compose pull minio minio-init
docker compose up -d
```

La imagen cliente también se utiliza en el servicio `archivos`. No borrar
volúmenes ni ejecutar `down -v`. Este cambio afecta al origen de las imágenes,
no al almacenamiento existente. El mirror es de un tercero, no un registro
administrado por MinIO. Teable documenta que conserva los builds originales.
Fuente: https://github.com/teableio/teable-deployment/blob/main/VERSIONS.md

## Comprobacion del arranque completo

- `minio`, `postgres-lab`, `openmetadata-server` e `ingestion`: activos y healthy.
- `minio-init` y `execute-migrate-all`: Exited (0), trabajo completado.
- MinIO Console en 9001 acepta las credenciales del cuadro de accesos.
- El bucket `movilidad` contiene `openmetadata.json` en su raíz. En una instancia
  nueva todavía no hay CSV publicados ni filas en las tablas PostgreSQL del caso.

Las imagenes MinIO proceden de los mirrors documentados de Teable en GHCR. El
servidor y el cliente mantienen sus versiones fijadas. La preparacion del bucket
se puede repetir sin eliminar archivos ni restablecer los datos del ejercicio.
Los scripts .sh se guardan con saltos LF, incluso al clonar desde Windows.
