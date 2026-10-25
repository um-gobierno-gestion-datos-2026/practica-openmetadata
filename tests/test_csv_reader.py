import importlib.util
import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('cargar',ROOT/'infra/carga/cargar.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class CsvReaderTest(unittest.TestCase):
 def test_sources_preserve_missing_and_duplicate(self):
  rows=[]
  for p in sorted((ROOT/'actividad/fuentes/reportes').glob('*.csv')):
   rows+=m.leer_csv(p.read_bytes(),m.REPORTES,p.name)
  self.assertEqual(len(rows),7)
  self.assertEqual(sum(x[0]=='R02' for x in rows),2)
  self.assertEqual(next(x for x in rows if x[0]=='R04')[3],None)
 def test_bad_header(self):
  with self.assertRaises(ValueError): m.leer_csv(b'id,nombre\nT01,Norte\n',m.TRAMOS,'x')
 def test_bad_date(self):
  data=(','.join(m.REPORTES)+'\nR1,ayer,T01,20,2026-10-20 06:00:00\n').encode()
  with self.assertRaises(ValueError):m.leer_csv(data,m.REPORTES,'x')
 def test_bad_width(self):
  with self.assertRaises(ValueError):m.leer_csv(b'tramo_id,nombre\nT01,Norte,extra\n',m.TRAMOS,'x')
if __name__=='__main__':unittest.main()
