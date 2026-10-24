# Solución docente

## Resultados
La fuente tiene 7 filas y 6 reporte_id distintos. Para el 19/10 hay 6 filas;
al eliminar una repetición idéntica quedan 5 reportes, y al excluir R03 por no
poder asignarlo a un tramo quedan 4. Para el 20/10 queda R06. reportes_validos
contiene 5 filas en total. No exigir 4 filas a toda la tabla de válidos.

| Fecha | Tramo | n_reportes | n_velocidades | Media km/h |
|---|---|---:|---:|---:|
| 2026-10-19 | T01 | 2 | 2 | 30 |
| 2026-10-19 | T02 | 2 | 1 | 26 |
| 2026-10-20 | T01 | 1 | 1 | 22 |

El resumen inicial informa 1 reporte en T02 para el 19/10. El filtro WHERE
velocidad_kmh IS NOT NULL elimina R04, aunque cumple el criterio vigente. La
media sigue siendo 26 antes y después de corregir, porque AVG omite NULL.
La ausencia de cambio en la media no demuestra que el conteo sea correcto.

## Pruebas
- reportes_validos.reporte_id no nulo: pasa.
- reportes_validos.reporte_id único: pasa con la muestra y su supuesto de ID global.
- Conservación por fecha y tramo: falla antes, devuelve T02 esperado 2 observado 1;
  pasa después, devuelve cero filas. Es una regla general sobre todos los grupos.
- Granularidad de resumen_diario por (fecha,tramo_id): pasa. Es independiente de
  la prueba de conservación; esta última no garantiza por sí sola ausencia de
  filas duplicadas con el mismo valor del conteo.
- Nulos de velocidad en fuente: 1/7; en válidos: 1/5; en válidos del 19/10: 1/4.
  El denominador debe figurar en cualquier conclusión sobre completitud.

## Definiciones esperadas
Reporte: observación de la aplicación ficticia identificada por reporte_id; no
equivale a vehículo. Reporte válido para resumen por tramo: reporte con ID y
fecha, asignable al catálogo de tramos; se cuenta una vez por ID. La velocidad
puede faltar. Velocidad media: promedio de valores informados de reportes
válidos para fecha y tramo; NULL si no hay ninguno. Adjuntar n_velocidades para
interpretarla. Granularidad: una fila por fecha_evento y tramo reconocido.

## Linaje
reportes_crudos -> reportes_validos; tramos -> reportes_validos;
reportes_validos -> resumen_diario. Registrar SQL y finalidad de cada enlace.
El conteo depende de las filas supervivientes, del identificador, la fecha y el
tramo; la media depende de velocidad_kmh y de los criterios que seleccionan filas.
Si se representan solo flechas entre columnas de valores, documentar por separado
la influencia del JOIN y los filtros sobre la pertenencia de los registros.

## Gobernanza
El Owner decide el criterio y sus cambios; el Steward mantiene definiciones y
coordina la incidencia; el PM prioriza y acepta el uso del producto según el
alcance docente; ingeniería implementa y demuestra resultados; el analista
comprueba interpretación. El científico de datos revisa si el histórico permite
un futuro análisis predictivo y explica los efectos de cambiar la población.
El consumidor plantea su necesidad. Una persona puede cumplir varias funciones.
La propiedad Owner de OpenMetadata no implementa por sí sola esta RACI.

| Actividad | Owner | Steward | PM | Ingeniería | Analista |
|---|:---:|:---:|:---:|:---:|:---:|
| Resolver el significado del conteo | A | R | C | C | C |
| Documentar la definición acordada | C | A/R | I | C | C |
| Corregir y verificar el SQL | I | C | I | A/R | C |
| Evaluar y aceptar el producto para el uso acordado | C | C | A | C | R |

El científico de datos es C si se consulta el efecto sobre un uso futuro del
histórico e I sobre la resolución. No necesita intervenir en todas las filas.
Se aceptan variantes justificadas dentro de la autoridad declarada en el caso.

## Cambio solicitado
Exigir velocidad dejaría T02 del 19/10 con 1 reporte en lugar de 2. Puede definirse
otro indicador, reportes_con_velocidad, sin sustituir el significado vigente.
Si se cambia el indicador: requiere decisión del Owner, versión documentada,
revisión de pruebas, comunicación y análisis de comparabilidad histórica. Un
modelo futuro podría aprender cambios de cobertura, en lugar de variaciones
reales de movilidad. Esta muestra no permite cuantificar ese efecto en general.

## Verificación realizada
Se verificaron con SQLite la discrepancia intencional, los conteos y medias
corregidos, grupos faltantes y adicionales, y duplicación de la clave compuesta.
Los SQL están escritos para PostgreSQL con operaciones compatibles; el entorno
no incluyó un servidor PostgreSQL ni una instancia de OpenMetadata para ensayo.
