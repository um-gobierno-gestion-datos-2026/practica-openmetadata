"""Carga transaccional desde los objetos publicados en MinIO. No publica metadatos."""
import csv
import io
import os
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

TRAMOS = ['tramo_id', 'nombre']
REPORTES = ['reporte_id', 'fecha_evento', 'tramo_id', 'velocidad_kmh', 'fecha_carga']

def leer_csv(data, expected, name):
    reader = csv.DictReader(io.StringIO(data.decode('utf-8-sig'), newline=''))
    if reader.fieldnames != expected:
        raise ValueError(f'{name}: cabezal invalido. Se espera {expected}')
    result=[]
    for n,row in enumerate(reader,2):
        if None in row or any(v is None for v in row.values()):
            raise ValueError(f'{name}, fila {n}: cantidad de campos invalida')
        values=[None if row[k]=='' else row[k] for k in expected]
        if expected == REPORTES:
            if values[1]: date.fromisoformat(values[1])
            if values[3]:
                speed=Decimal(values[3])
                if not speed.is_finite(): raise ValueError(f'{name}, fila {n}: velocidad no finita')
            if values[4]: datetime.fromisoformat(values[4])
        result.append(values)
    return result

def main():
    import boto3
    import psycopg
    from botocore.config import Config
    s3=boto3.client('s3',endpoint_url=os.environ['S3_ENDPOINT'],
        aws_access_key_id=os.environ['S3_ACCESS_KEY'],aws_secret_access_key=os.environ['S3_SECRET_KEY'],
        region_name='us-east-1',config=Config(s3={'addressing_style':'path'}))
    bucket=os.environ['S3_BUCKET']
    def read(key): return s3.get_object(Bucket=bucket,Key=key)['Body'].read()
    tramos=leer_csv(read('individual/tramos.csv'),TRAMOS,'individual/tramos.csv')
    keys=sorted(obj['Key'] for page in s3.get_paginator('list_objects_v2').paginate(Bucket=bucket,Prefix='reportes/')
                for obj in page.get('Contents',[]) if obj['Key'].endswith('.csv'))
    if not keys: raise ValueError('No hay CSV publicados bajo reportes/. Primero publicar la carpeta.')
    reportes=[]
    for key in keys: reportes.extend(leer_csv(read(key),REPORTES,key))
    # Se leen y validan todos los objetos antes de modificar las tablas.
    with psycopg.connect('') as conn:
        with conn.cursor() as cur:
            for table in ('resumen_diario','reportes_validos','reportes_crudos','tramos'):
                cur.execute('DELETE FROM movilidad_g01.'+table)
            cur.executemany('INSERT INTO movilidad_g01.tramos VALUES (%s,%s)',tramos)
            cur.executemany('INSERT INTO movilidad_g01.reportes_crudos VALUES (%s,%s,%s,%s,%s)',reportes)
            cur.execute(Path('/lab-sql/00_transformar.sql').read_text())
    print(f'Carga confirmada: {len(tramos)} tramos y {len(reportes)} filas de {len(keys)} CSV de reportes.')
    print('Origen: s3://'+bucket+'. Se restauro el error intencional del resumen.')

if __name__=='__main__': main()
