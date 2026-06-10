import os
import sys
from datetime import date
from pathlib import Path

os.environ["DATABASE_URL"] = "sqlite:///./test_quickslot.db"
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient

from app.main import app


def test_core_booking_flow_blocks_double_booking():
    with TestClient(app) as client:
        health = client.get("/health")
        assert health.status_code == 200
        assert health.json()["status"] == "ok"

        venues = client.get("/venues")
        assert venues.status_code == 200
        assert len(venues.json()) >= 3

        venue_id = venues.json()[0]["id"]
        slots = client.get(f"/venues/{venue_id}/slots", params={"date": date.today().isoformat()})
        assert slots.status_code == 200
        assert len(slots.json()) == 16

        slot_id = next(slot["id"] for slot in slots.json() if slot["status"] == "available")
        payload = {"slot_id": slot_id, "user_name": "Biswajit"}

        first = client.post("/bookings", json=payload, headers={"X-User-Id": "u1"})
        assert first.status_code == 201
        assert first.json()["slot_id"] == slot_id

        second = client.post("/bookings", json=payload, headers={"X-User-Id": "u2"})
        assert second.status_code == 409


def test_cancel_booking_requires_owner():
    with TestClient(app) as client:
        venue_id = client.get("/venues").json()[0]["id"]
        slots = client.get(f"/venues/{venue_id}/slots", params={"date": date.today().isoformat()}).json()
        slot_id = next(slot["id"] for slot in slots if slot["status"] == "available")

        booking = client.post(
            "/bookings",
            json={"slot_id": slot_id, "user_name": "Aarav"},
            headers={"X-User-Id": "u1"},
        )
        assert booking.status_code == 201
        booking_id = booking.json()["id"]

        forbidden = client.delete(f"/bookings/{booking_id}", headers={"X-User-Id": "u2"})
        assert forbidden.status_code == 403

        cancelled = client.delete(f"/bookings/{booking_id}", headers={"X-User-Id": "u1"})
        assert cancelled.status_code == 204
