-- PostgreSQL. Ejecutar en una base de laboratorio dedicada.
-- Para otro grupo, sustituir movilidad_g01 por movilidad_g02 en TODOS los SQL.
-- Este archivo crea objetos nuevos; no elimina esquemas ni tablas existentes.
BEGIN;
CREATE SCHEMA IF NOT EXISTS movilidad_g01;
CREATE TABLE movilidad_g01.tramos (
    tramo_id VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL
);
CREATE TABLE movilidad_g01.reportes_crudos (
    reporte_id VARCHAR(10),
    fecha_evento DATE,
    tramo_id VARCHAR(10),
    velocidad_kmh NUMERIC(6,2),
    fecha_carga TIMESTAMP
);
CREATE TABLE movilidad_g01.reportes_validos (
    reporte_id VARCHAR(10), fecha_evento DATE, tramo_id VARCHAR(10),
    velocidad_kmh NUMERIC(6,2)
);
CREATE TABLE movilidad_g01.resumen_diario (
    fecha DATE, tramo_id VARCHAR(10), n_reportes BIGINT,
    n_velocidades BIGINT, velocidad_media_kmh NUMERIC
);
COMMIT;
-- Las tablas quedan vacias. La carga desde MinIO es una segunda etapa manual.
