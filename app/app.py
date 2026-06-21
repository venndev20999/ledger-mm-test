"""
Reference application for the DevOps take-home.

A small HTTP API that depends on Postgres and Redis. You should NOT need to
change this code to complete the assignment (though you may if you have a good
reason — explain it in DECISIONS.md). Your job is everything *around* this app:
packaging, deployment, infrastructure, and CI.

Endpoints:
  GET /healthz  -> liveness. Always 200 if the process is up. No external deps.
  GET /readyz   -> readiness. 200 only if Postgres AND Redis are reachable, else 503.
  GET /         -> increments a Redis counter, reads the time from Postgres,
                   returns JSON including the pod/container hostname.

Configuration (all via environment variables):
  PORT          (default 8000)
  APP_NAME      (default "ledger-api")
  DATABASE_URL  (default postgresql://postgres:postgres@localhost:5432/postgres)
  REDIS_URL     (default redis://localhost:6379/0)
"""

import os
import socket

from flask import Flask, jsonify

APP_NAME = os.environ.get("APP_NAME", "ledger-api")


def _redis_client():
    import redis
    return redis.from_url(os.environ.get("REDIS_URL", "redis://localhost:6379/0"))


def _db_conn():
    import psycopg2
    return psycopg2.connect(
        os.environ.get("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/postgres")
    )


def build_payload(hostname, counter, db_time):
    return {
        "app": APP_NAME,
        "host": hostname,
        "request_count": counter,
        "db_time": db_time,
    }


def check_readiness():
    """Return (ok: bool, detail: dict) after probing Redis and Postgres."""
    detail = {}
    ok = True
    try:
        _redis_client().ping()
        detail["redis"] = "ok"
    except Exception as exc:  # noqa: BLE001 - report, don't crash readiness
        detail["redis"] = f"error: {exc.__class__.__name__}"
        ok = False
    try:
        conn = _db_conn()
        conn.close()
        detail["postgres"] = "ok"
    except Exception as exc:  # noqa: BLE001
        detail["postgres"] = f"error: {exc.__class__.__name__}"
        ok = False
    return ok, detail


def create_app():
    app = Flask(__name__)

    @app.get("/healthz")
    def healthz():
        return jsonify(status="ok"), 200

    @app.get("/readyz")
    def readyz():
        ok, detail = check_readiness()
        return jsonify(status="ready" if ok else "not_ready", checks=detail), (200 if ok else 503)

    @app.get("/")
    def index():
        r = _redis_client()
        counter = r.incr(f"{APP_NAME}:requests")
        conn = _db_conn()
        cur = conn.cursor()
        cur.execute("SELECT now()")
        db_time = cur.fetchone()[0].isoformat()
        cur.close()
        conn.close()
        return jsonify(build_payload(socket.gethostname(), counter, db_time)), 200

    return app


app = create_app()


if __name__ == "__main__":
    # Development server only. A production image should run a real WSGI server.
    port = int(os.environ.get("PORT", "8000"))
    app.run(host="0.0.0.0", port=port)
