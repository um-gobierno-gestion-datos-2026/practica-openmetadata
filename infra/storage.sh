#!/bin/sh
set -eu
mc alias set lab "$MINIO_ENDPOINT" "$MINIO_USER" "$MINIO_PASSWORD" >/dev/null
case "${1:-listar}" in
 iniciar)
   mc mb --ignore-existing lab/movilidad
   if ! mc admin user info lab catalogo_storage >/dev/null 2>&1; then
     mc admin user add lab catalogo_storage lector_storage_lab
   fi
   if ! mc admin policy attach lab readonly --user catalogo_storage; then
     mc admin user info lab catalogo_storage | grep -q readonly
   fi
   echo 'Bucket listo. Los archivos se publican manualmente durante la practica.'
   ;;
 archivo) mc cp /fuentes/individual/tramos.csv lab/movilidad/individual/tramos.csv ;;
 carpeta) mc cp --recursive /fuentes/reportes/ lab/movilidad/reportes/ ;;
 manifiesto) mc cp /manifiestos/openmetadata.json lab/movilidad/openmetadata.json ;;
 listar) mc ls --recursive lab/movilidad ;;
 *) echo 'Acciones: iniciar, archivo, carpeta, manifiesto, listar' >&2; exit 2 ;;
esac
