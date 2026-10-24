#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
dc stop
echo 'Servicios detenidos. Detené también el Codespace desde GitHub para finalizar el cómputo.'
