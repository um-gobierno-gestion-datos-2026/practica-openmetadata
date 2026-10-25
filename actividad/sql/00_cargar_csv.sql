-- Ejecutar con psql -v ON_ERROR_STOP=1 dentro de postgres-lab.
-- Reemplaza SOLO las filas del caso. Conserva tablas, permisos y nombres.
-- Los CSV son la fuente. HEADER MATCH valida nombres y orden del cabezal.
-- Error intencional del resumen: excluye velocidades ausentes del conteo.
BEGIN;
CREATE TEMP TABLE carga_tramos
(LIKE movilidad_g01.tramos INCLUDING ALL) ON COMMIT DROP;
CREATE TEMP TABLE carga_reportes
(LIKE movilidad_g01.reportes_crudos INCLUDING ALL) ON COMMIT DROP;
COPY carga_tramos FROM '/datos/tramos.csv'
WITH (FORMAT CSV, HEADER MATCH, ENCODING 'UTF8', NULL '');
COPY carga_reportes FROM '/datos/reportes_crudos.csv'
WITH (FORMAT CSV, HEADER MATCH, ENCODING 'UTF8', NULL '');
-- Las dos lecturas deben finalizar antes de reemplazar datos.
DELETE FROM movilidad_g01.resumen_diario;
DELETE FROM movilidad_g01.reportes_validos;
DELETE FROM movilidad_g01.reportes_crudos;
DELETE FROM movilidad_g01.tramos;
INSERT INTO movilidad_g01.tramos SELECT * FROM carga_tramos;
INSERT INTO movilidad_g01.reportes_crudos SELECT * FROM carga_reportes;
-- La muestra contiene duplicados identicos, no versiones contradictorias.
INSERT INTO movilidad_g01.reportes_validos
SELECT DISTINCT r.reporte_id, r.fecha_evento, r.tramo_id, r.velocidad_kmh
FROM movilidad_g01.reportes_crudos r
JOIN movilidad_g01.tramos t ON r.tramo_id = t.tramo_id
WHERE r.reporte_id IS NOT NULL AND r.fecha_evento IS NOT NULL;
INSERT INTO movilidad_g01.resumen_diario
    (fecha, tramo_id, n_reportes, n_velocidades, velocidad_media_kmh)
SELECT fecha_evento, tramo_id, COUNT(*), COUNT(velocidad_kmh), AVG(velocidad_kmh)
FROM movilidad_g01.reportes_validos
WHERE velocidad_kmh IS NOT NULL
GROUP BY fecha_evento, tramo_id;
COMMIT;
