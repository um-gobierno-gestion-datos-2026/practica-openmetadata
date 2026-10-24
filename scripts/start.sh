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
# No se vuelve a cargar SQL: PostgreSQL inicializa los datos una sola vez.
for attempt in $(seq 1 180); do
  if dc exec -T openmetadata-server wget -q --spider http://localhost:8586/healthcheck 2>/dev/null \
     && dc exec -T postgres-lab psql -U estudiante -d movilidad -tAc "SELECT count(*)=4 FROM information_schema.tables WHERE table_schema='movilidad_g01'" | grep -qx t \
     && dc exec -T ingestion curl -fsS http://localhost:8080/health >/dev/null 2>&1; then
    echo 'Servicios disponibles. Abrí el puerto 8585 en la pestaña Ports.'
    echo 'Seguí README.md para conectar PostgreSQL e ingerir las cuatro tablas.'
    exit 0
  fi
  sleep 5
done
echo 'El arranque no finalizó dentro del plazo. Ejecutá bash scripts/status.sh.'
dc ps -a
exit 1
