#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
if [[ "${1:-}" != "--restaurar-caso" || $# -ne 1 ]]; then
 echo 'Uso: bash scripts/reload-csv.sh --restaurar-caso'
 echo 'Reemplaza las filas desde los objetos publicados en MinIO. Respaldar cambios antes.'
 exit 2
fi
dc run --rm carga
