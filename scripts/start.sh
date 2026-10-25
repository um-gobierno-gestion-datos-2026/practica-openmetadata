#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
for attempt in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then break; fi
  if [[ "$attempt" == 60 ]]; then echo 'Docker no está disponible. Revisa el registro de creación del Codespace.'; exit 1; fi
  sleep 2
done
cpus=$(docker info --format '{{.NCPU}}')
mem=$(docker info --format '{{.MemTotal}}')
if (( cpus < 4 || mem < 6442450944 )); then
  echo 'Recursos insuficientes: seleccionar al menos 4 CPU y 16 GB en Codespaces.'; exit 1
fi
# Elasticsearch requiere este valor en el host de Docker.
if ! sudo sysctl -w vm.max_map_count=262144 >/dev/null; then
  echo 'No se pudo ajustar vm.max_map_count; revise permisos antes de iniciar.'; exit 1
fi
dc config --quiet
dc up -d
# PostgreSQL prepara las tablas una sola vez. Publicacion y carga siguen siendo manuales.
for attempt in $(seq 1 180); do
  init_id=$(dc ps -a -q minio-init)
  init_state=""
  if [[ -n "$init_id" ]]; then
    init_state=$(docker inspect --format '{{.State.Status}} {{.State.ExitCode}}' "$init_id")
    if [[ "$init_state" == exited* && "$init_state" != "exited 0" ]]; then
      dc logs --tail=60 minio-init
      echo 'Fallo la preparacion de MinIO.'; exit 1
    fi
  fi
  if [[ "$init_state" == "exited 0" ]] \
     && dc exec -T openmetadata-server wget -q --spider http://localhost:8586/healthcheck 2>/dev/null \
     && dc exec -T postgres-lab psql -U estudiante -d movilidad -tAc "SELECT count(*)=4 FROM information_schema.tables WHERE table_schema='movilidad_g01'" | grep -qx t \
     && dc exec -T minio curl -fsS http://localhost:9000/minio/health/live >/dev/null 2>&1 \
     && dc exec -T ingestion curl -fsS http://localhost:8080/health >/dev/null 2>&1; then
    echo 'Servicios disponibles. Abrí el puerto 8585 en la pestaña Ports.'
    echo 'Abrí MinIO en el puerto 9001. Seguí README.md para publicar y catalogar archivos antes de cargar PostgreSQL.'
    exit 0
  fi
  sleep 5
done
echo 'El arranque no finalizó dentro del plazo. Ejecutá bash scripts/status.sh.'
dc ps -a
exit 1
