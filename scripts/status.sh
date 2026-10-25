#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
dc ps -a
dc logs --tail=40 execute-migrate-all openmetadata-server ingestion postgres-lab minio minio-init
