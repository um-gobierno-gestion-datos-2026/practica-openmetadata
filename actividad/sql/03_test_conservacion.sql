-- OpenMetadata: Table Custom SQL Test / Custom SQL Query.
-- Estrategia ROWS, umbral 0; operador <= si esta disponible.
-- Cada fila devuelta es una discrepancia entre el contrato y el resumen.
-- PostgreSQL usa esquema.tabla dentro de la base conectada. No anteponer
-- el nombre de la base como si se tratara de una consulta entre bases.
WITH esperado AS (
    SELECT fecha_evento AS fecha, tramo_id, COUNT(*) AS n_reportes
    FROM movilidad_g01.reportes_validos
    GROUP BY fecha_evento, tramo_id
)
SELECT e.fecha, e.tramo_id, e.n_reportes AS esperado,
       r.n_reportes AS observado
FROM esperado e
LEFT JOIN movilidad_g01.resumen_diario r
  ON e.fecha = r.fecha AND e.tramo_id = r.tramo_id
WHERE r.fecha IS NULL OR r.n_reportes <> e.n_reportes
UNION ALL
SELECT r.fecha, r.tramo_id, CAST(NULL AS BIGINT) AS esperado,
       r.n_reportes AS observado
FROM movilidad_g01.resumen_diario r
LEFT JOIN esperado e
  ON e.fecha = r.fecha AND e.tramo_id = r.tramo_id
WHERE e.fecha IS NULL;
