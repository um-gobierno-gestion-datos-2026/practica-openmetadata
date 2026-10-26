"""Prueba el chequeo de Airflow con un servidor HTTP local, sin Docker."""

import json
import subprocess
import sys
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HEALTH_PATH = "/api/v2/monitor/health"


class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != HEALTH_PATH:
            self.send_error(404)
            return
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(self.server.health_payload).encode())

    def log_message(self, *args):
        pass


class HealthCheckTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), HealthHandler)
        cls.worker = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.worker.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.worker.join()

    def probe(self, payload, path=HEALTH_PATH):
        self.server.health_payload = payload
        url = f"http://127.0.0.1:{self.server.server_port}{path}"
        return subprocess.run(
            [sys.executable, str(ROOT / "infra/check_ingestion_health.py"), url],
            capture_output=True, text=True, timeout=10,
        )

    def test_healthy_components_and_optional_nulls(self):
        result = self.probe({
            "metadatabase": {"status": "healthy"},
            "scheduler": {"status": "healthy"},
            "dag_processor": {"status": "healthy"},
            "triggerer": {"status": None},
        })
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_http_200_with_failed_components_is_unhealthy(self):
        for component in ("metadatabase", "scheduler", "dag_processor", "triggerer"):
            with self.subTest(component=component):
                payload = {name: {"status": "healthy"} for name in
                           ("metadatabase", "scheduler", "dag_processor", "triggerer")}
                payload[component]["status"] = "unhealthy"
                result = self.probe(payload)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(component, result.stderr)

    def test_missing_scheduler_is_unhealthy(self):
        result = self.probe({"metadatabase": {"status": "healthy"}})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("scheduler", result.stderr)

    def test_old_endpoint_404_is_unhealthy(self):
        result = self.probe({}, "/health")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("404", result.stderr)

    def test_invalid_payload_is_unhealthy(self):
        result = self.probe([])
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
