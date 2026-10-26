"""Prueba de integración S3 a PostgreSQL. Modifica SOLO los servicios de CI."""
from pathlib import Path
import subprocess
root=Path(__file__).resolve().parents[1]
dc=['docker','compose','-f',str(root/'compose.yaml')]
base=dc+['exec','-T','postgres-lab','psql','-X','-v','ON_ERROR_STOP=1','-U','estudiante','-d','movilidad','-At']
def sql(q):return subprocess.check_output(base,input=q,text=True).strip()
def violations():
 q=(root/'actividad/sql/03_test_conservacion.sql').read_text().strip().rstrip(';')
 return sql('SELECT count(*) FROM ('+q+') AS fallos;')
assert sql('SELECT count(*) FROM movilidad_g01.reportes_crudos;')=='0'
initial_objects=subprocess.check_output(dc+['run','--rm','archivos','listar'],text=True)
assert 'openmetadata.json' in initial_objects, 'minio-init debe preparar el manifiesto'
assert '.csv' not in initial_objects, 'Los CSV deben publicarse durante la actividad'
for action in ['archivo','carpeta']:
 subprocess.run(dc+['run','--rm','archivos',action],check=True)
oid=sql("SELECT 'movilidad_g01.resumen_diario'::regclass::oid;")
for _ in range(2):
 subprocess.run(dc+['run','--rm','--build','carga'],check=True)
 assert sql('SELECT count(*) FROM movilidad_g01.reportes_crudos;')=='7'
 assert sql('SELECT count(*) FROM movilidad_g01.reportes_validos;')=='5'
 assert violations()=='1'
assert sql("SELECT 'movilidad_g01.resumen_diario'::regclass::oid;")==oid
sql((root/'actividad/docente/05_corregir_resumen.sql').read_text())
assert violations()=='0'
assert sql("SELECT n_reportes || '|' || n_velocidades || '|' || velocidad_media_kmh::int FROM movilidad_g01.resumen_diario WHERE tramo_id='T02';")=='2|1|26'
assert sql("SELECT has_table_privilege('catalogo_lector','movilidad_g01.resumen_diario','INSERT');")=='f'
print('Manifiesto preparado, fuentes S3, recarga sin acumulacion, identidad de tablas, correccion y permisos: OK.')
