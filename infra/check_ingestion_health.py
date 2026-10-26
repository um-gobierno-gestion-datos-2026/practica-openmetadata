"""Comprueba la API y los componentes de Airflow 3, sin importar Airflow."""

import json
import sys
import urllib.request

HEALTH_URL = "http://localhost:8080/api/v2/monitor/health"


def check_health(url=HEALTH_URL):
    with urllib.request.urlopen(url, timeout=5) as response:
        payload = json.load(response)
    if not isinstance(payload, dict):
        raise ValueError("La respuesta de salud no es un objeto JSON")

    failures = []
    for component in ("metadatabase", "scheduler"):
        value = payload.get(component)
        status = value.get("status") if isinstance(value, dict) else None
        if status != "healthy":
            failures.append(f"{component}: {status or 'sin estado'}")

    # Algunas instalaciones no ejecutan estos componentes y devuelven null.
    for component in ("dag_processor", "triggerer"):
        value = payload.get(component)
        if value is None:
            continue
        if not isinstance(value, dict):
            failures.append(f"{component}: respuesta invalida")
        elif value.get("status") not in (None, "healthy"):
            failures.append(f"{component}: {value['status']}")
    return failures


def main():
    try:
        failures = check_health(sys.argv[1] if len(sys.argv) > 1 else HEALTH_URL)
    except (OSError, ValueError, TypeError) as exc:
        print(f"Airflow no disponible: {exc}", file=sys.stderr)
        return 1
    if failures:
        print("Airflow no saludable: " + "; ".join(failures), file=sys.stderr)
        return 1
    print("Airflow: API, base de metadatos y scheduler disponibles")
    return 0


if __name__ == "__main__":
    sys.exit(main())
