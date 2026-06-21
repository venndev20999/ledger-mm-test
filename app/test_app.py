"""Minimal tests. These run without a database or Redis.

Run locally with:  python -m pytest -q   (install: pip install pytest flask)
Your CI must run these. Feel free to add more (integration tests against the
real services are a plus and a good thing to talk about in DECISIONS.md).
"""

import app as appmod


def test_healthz_is_always_ok():
    client = appmod.create_app().test_client()
    resp = client.get("/healthz")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "ok"


def test_build_payload_shape():
    payload = appmod.build_payload("host-1", 42, "2024-01-01T00:00:00+00:00")
    assert payload["host"] == "host-1"
    assert payload["request_count"] == 42
    assert payload["app"]  # APP_NAME is present


def test_readyz_returns_503_when_dependencies_are_down(monkeypatch):
    monkeypatch.setattr(
        appmod, "check_readiness",
        lambda: (False, {"redis": "error", "postgres": "error"}),
    )
    client = appmod.create_app().test_client()
    resp = client.get("/readyz")
    assert resp.status_code == 503
    assert resp.get_json()["status"] == "not_ready"
