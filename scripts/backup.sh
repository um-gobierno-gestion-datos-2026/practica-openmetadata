#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
mkdir -p evidencias
file="evidencias/movilidad-$(date +%Y%m%d-%H%M%S).sql"
dc exec -T postgres-lab pg_dump -U estudiante -d movilidad --no-owner --no-privileges > "$file"
echo "Copia PostgreSQL: $file. Descargala antes de eliminar el Codespace. No incluye metadatos del catálogo."
