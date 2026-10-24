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
INSERT INTO movilidad_g01.tramos VALUES
    ('T01','Avenida Norte'), ('T02','Avenida Sur');
INSERT INTO movilidad_g01.reportes_crudos VALUES
    ('R01','2026-10-19','T01',35,'2026-10-20 06:00:00'),
    ('R02','2026-10-19','T01',25,'2026-10-20 06:00:00'),
    ('R02','2026-10-19','T01',25,'2026-10-20 06:00:00'),
    ('R03','2026-10-19',NULL,15,'2026-10-20 06:00:00'),
    ('R04','2026-10-19','T02',NULL,'2026-10-20 06:00:00'),
    ('R05','2026-10-19','T02',26,'2026-10-20 06:00:00'),
    ('R06','2026-10-20','T01',22,'2026-10-21 06:00:00');
-- En esta muestra las repeticiones son identicas en los campos seleccionados.
-- DISTINCT no resuelve versiones contradictorias del mismo reporte_id.
CREATE TABLE movilidad_g01.reportes_validos AS
SELECT DISTINCT r.reporte_id, r.fecha_evento, r.tramo_id, r.velocidad_kmh
FROM movilidad_g01.reportes_crudos r
JOIN movilidad_g01.tramos t ON r.tramo_id = t.tramo_id
WHERE r.reporte_id IS NOT NULL AND r.fecha_evento IS NOT NULL;
-- Error intencional: el filtro elimina reportes validos sin velocidad.
CREATE TABLE movilidad_g01.resumen_diario AS
SELECT fecha_evento AS fecha, tramo_id, COUNT(*) AS n_reportes,
       COUNT(velocidad_kmh) AS n_velocidades,
       AVG(velocidad_kmh) AS velocidad_media_kmh
FROM movilidad_g01.reportes_validos
WHERE velocidad_kmh IS NOT NULL
GROUP BY fecha_evento, tramo_id;
COMMIT;
