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
