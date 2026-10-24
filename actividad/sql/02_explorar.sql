-- Consultas para el docente o para ejecutar desde el cliente SQL.
-- OpenMetadata no se usa como editor que modifica estas tablas.
SELECT COUNT(*) AS filas_crudas,
       COUNT(DISTINCT reporte_id) AS identificadores_distintos,
       SUM(CASE WHEN tramo_id IS NULL THEN 1 ELSE 0 END) AS sin_tramo,
       SUM(CASE WHEN velocidad_kmh IS NULL THEN 1 ELSE 0 END) AS sin_velocidad
FROM movilidad_g01.reportes_crudos;
SELECT reporte_id, COUNT(*) AS ocurrencias
FROM movilidad_g01.reportes_crudos
GROUP BY reporte_id HAVING COUNT(*) > 1;
SELECT fecha_evento, COUNT(*) AS n_validos,
       COUNT(velocidad_kmh) AS n_velocidades
FROM movilidad_g01.reportes_validos GROUP BY fecha_evento ORDER BY fecha_evento;
SELECT * FROM movilidad_g01.resumen_diario ORDER BY fecha, tramo_id;
