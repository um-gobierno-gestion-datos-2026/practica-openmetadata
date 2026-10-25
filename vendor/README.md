# Fuente de la configuración

`docker-compose.openmetadata.yml` es el quickstart oficial sin modificar:
https://github.com/open-metadata/OpenMetadata/releases/download/1.12.6-release/docker-compose.yml

SHA-256: `d19f9c1877368621452b626ae24e01722010d6fdcb0dc43b2b36bfc871f13f38`

Licencia del archivo original: Apache-2.0; se conserva su encabezado.
`compose.yaml` deriva de ese archivo: conserva versiones y variables del servidor,
MySQL, Elasticsearch e ingestion; agrega PostgreSQL 16.10, elimina puertos internos de OpenMetadata y publica PostgreSQL en 5432,
usa volumen nombrado para MySQL, desactiva autorregistro y deja que Docker elija la subred.
Los componentes de OpenMetadata permanecen todos en 1.12.6.
No actualizar imágenes de manera independiente. Las etiquetas no son digests inmutables.

La versión de almacenamiento agrega MinIO y su cliente mc, con imágenes fijadas de ghcr.io/teableio. El bucket empieza vacío. Las fuentes locales se montan solo en el cliente de publicación; PostgreSQL no las lee directamente. El cargador manual usa boto3 y psycopg para leer los objetos publicados y transformar los datos.

Corrección de distribución: servidor `ghcr.io/teableio/minio:RELEASE.2025-04-22T22-12-26Z`
y cliente `ghcr.io/teableio/minio-mc:RELEASE.2025-04-16T18-13-26Z`. Son mirrors de
terceros documentados por Teable como los mismos builds originales.
https://github.com/teableio/teable-deployment/blob/main/VERSIONS.md

Se fijan también los digests de ambos manifiestos, consultados correctamente en GHCR. El lanzador Windows iniciar.cmd/iniciar.ps1 espera los servicios y la tarea minio-init. No se ejecutó Docker en el entorno de preparación.
