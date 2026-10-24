#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
dc() { docker compose --project-directory "$ROOT" -f "$ROOT/compose.yaml" "$@"; }
