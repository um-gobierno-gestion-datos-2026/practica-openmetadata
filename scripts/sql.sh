#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
if [[ $# -eq 0 ]]; then
  dc exec postgres-lab psql -U estudiante -d movilidad
elif [[ $# -eq 1 && -f "$1" ]]; then
  dc exec -T postgres-lab psql -v ON_ERROR_STOP=1 -U estudiante -d movilidad < "$1"
else
  echo 'Uso: bash scripts/sql.sh [archivo.sql]' >&2; exit 2
fi
