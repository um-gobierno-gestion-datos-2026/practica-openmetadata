-- Segunda prueba SQL opcional. ROWS, umbral 0, operador <= si existe.
SELECT fecha, tramo_id, COUNT(*) AS ocurrencias
FROM movilidad_g01.resumen_diario
GROUP BY fecha, tramo_id
HAVING COUNT(*) > 1;
