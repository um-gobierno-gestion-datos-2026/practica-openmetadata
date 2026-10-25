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
