CREATE ROLE catalogo_lector LOGIN PASSWORD 'lector_lab';
GRANT CONNECT ON DATABASE movilidad TO catalogo_lector;
GRANT USAGE ON SCHEMA movilidad_g01 TO catalogo_lector;
GRANT SELECT ON ALL TABLES IN SCHEMA movilidad_g01 TO catalogo_lector;
ALTER DEFAULT PRIVILEGES FOR ROLE estudiante IN SCHEMA movilidad_g01
GRANT SELECT ON TABLES TO catalogo_lector;
