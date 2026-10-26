# Inicia el proyecto y prepara el manifiesto. Conserva volumenes; los CSV y las filas se cargan manualmente.
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    & docker info 1>$null
    if ($LASTEXITCODE -ne 0) { throw "Docker no responde. Inicie Docker Desktop." }
    & docker compose config --quiet
    if ($LASTEXITCODE -ne 0) { throw "La configuracion Compose no es valida." }
    & docker compose up -d
    if ($LASTEXITCODE -ne 0) { throw "Fallo el arranque. Revise el error de descarga o configuracion mostrado arriba." }
    $deadline = (Get-Date).AddMinutes(15)
    $ready = $false
    while ((Get-Date) -lt $deadline) {
        $ready = $true
        foreach ($service in @("execute-migrate-all", "minio-init", "openmetadata-server", "postgres-lab", "minio", "ingestion")) {
            $id = & docker compose ps -a -q $service
            if (-not $id) { $ready = $false; continue }
            $rawState = & docker inspect --format '{{json .State}}' $id
            if ($LASTEXITCODE -ne 0) { throw "No se pudo consultar el servicio $service" }
            $state = $rawState | ConvertFrom-Json
            if ($service -in @("execute-migrate-all", "minio-init")) {
                if ($state.Status -eq "exited") {
                    if ($state.ExitCode -ne 0) {
                        & docker compose logs --tail=60 $service
                        throw "La preparacion de $service fallo. Los datos existentes se conservan."
                    }
                } else { $ready = $false }
            } else {
                if ($state.Status -ne "running" -or $state.Health.Status -ne "healthy") { $ready = $false }
            }
        }
        if ($ready) { break }
        Write-Host "Esperando servicios y preparacion del bucket..."
        Start-Sleep -Seconds 10
    }
    if (-not $ready) {
        & docker compose ps -a
        throw "Se alcanzo el plazo de arranque. Revise docker compose logs --tail=80 SERVICIO."
    }
    Write-Host "OpenMetadata: http://localhost:8585  (admin@open-metadata.org / admin)"
    Write-Host "MinIO:        http://localhost:9001  (minioadmin / minioadmin_lab)"
    Write-Host "Bucket movilidad, lector S3 y manifiesto preparados. Los CSV se publican durante la practica."
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
} finally { Pop-Location }
