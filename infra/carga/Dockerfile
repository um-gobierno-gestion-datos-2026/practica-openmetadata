FROM python:3.11-slim-bookworm
WORKDIR /app
COPY infra/carga/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY infra/carga /app
ENTRYPOINT ["python", "/app/cargar.py"]
