-- Ejecutar desde PostgreSQL, por el docente o el responsable autorizado.
-- Mantiene la tabla y sus columnas para no perder su identidad en el catalogo.
BEGIN;
DELETE FROM movilidad_g01.resumen_diario;
INSERT INTO movilidad_g01.resumen_diario
    (fecha, tramo_id, n_reportes, n_velocidades, velocidad_media_kmh)
SELECT fecha_evento AS fecha, tramo_id, COUNT(*) AS n_reportes,
       COUNT(velocidad_kmh) AS n_velocidades,
       AVG(velocidad_kmh) AS velocidad_media_kmh
FROM movilidad_g01.reportes_validos
GROUP BY fecha_evento, tramo_id;
COMMIT;
