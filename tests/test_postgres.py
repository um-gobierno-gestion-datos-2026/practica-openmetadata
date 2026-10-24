"""Prueba de integración contra PostgreSQL del compose. Requiere Docker."""
from pathlib import Path
import subprocess
root=Path(__file__).resolve().parents[1]
base=['docker','compose','-f',str(root/'compose.yaml'),'exec','-T','postgres-lab','psql','-X','-v','ON_ERROR_STOP=1','-U','estudiante','-d','movilidad','-At']
def sql(query):
 return subprocess.check_output(base,input=query,text=True).strip()
def file(name):
 return (root/name).read_text()
def violations():
 query=file('actividad/sql/03_test_conservacion.sql').strip().rstrip(';')
 return sql('SELECT count(*) FROM ('+query+') AS fallos;')
assert sql("SELECT count(*) FROM information_schema.tables WHERE table_schema='movilidad_g01';")=='4'
assert sql('SELECT count(*) FROM movilidad_g01.reportes_crudos;')=='7'
assert violations()=='1', 'El error intencional debe detectarse'
assert sql("SELECT n_reportes || '|' || n_velocidades || '|' || velocidad_media_kmh::int FROM movilidad_g01.resumen_diario WHERE tramo_id='T02';")=='1|1|26'
sql(file('actividad/docente/05_corregir_resumen.sql'))
assert violations()=='0', 'La corrección debe satisfacer el criterio'
assert sql("SELECT n_reportes || '|' || n_velocidades || '|' || velocidad_media_kmh::int FROM movilidad_g01.resumen_diario WHERE tramo_id='T02';")=='2|1|26'
assert sql("SELECT has_table_privilege('catalogo_lector','movilidad_g01.resumen_diario','SELECT');")=='t'
assert sql("SELECT has_table_privilege('catalogo_lector','movilidad_g01.resumen_diario','INSERT');")=='f'
print('PostgreSQL: carga, discrepancia, corrección y permisos verificados.')
