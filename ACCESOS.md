# Accesos del laboratorio

| Servicio | Usuario | Contraseña | Puerto local |
|---|---|---|---|
| OpenMetadata | admin@open-metadata.org | admin | 8585 |
| MinIO Console | minioadmin | minioadmin_lab | 9001 |
| MinIO lector S3 | catalogo_storage | lector_storage_lab | API 9000 |
| Airflow | admin | admin | 8080 |
| PostgreSQL administrador | estudiante | estudiante_lab | 5432 |
| PostgreSQL lector | catalogo_lector | lector_lab | 5432 |

Base PostgreSQL: movilidad. Esquema: movilidad_g01.
Dentro de Docker: PostgreSQL en postgres-lab:5432 y API S3 en http://minio:9000.
Región S3: us-east-1. Bucket: movilidad. No se necesita cuenta AWS.
Conservar puertos privados en Codespaces. Claves de laboratorio con datos sintéticos.
