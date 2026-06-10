# QuickSlot Booking System

QuickSlot is a local-demo sports slot booking system built for the hiring hackathon. The monorepo contains:

- `quick_slot/` - Flutter app using Riverpod, GoRouter, Dio, and Material 3
- `quick_slot_backend/` - FastAPI REST API using SQLAlchemy and PostgreSQL/SQLite

## Core Flow

1. Pick a hardcoded demo user.
2. Browse seeded venues.
3. Select a date and available hourly slot.
4. Confirm booking.
5. View/cancel bookings in My Bookings.

## Backend Setup

Local SQLite:

```bash
cd quick_slot_backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Neon PostgreSQL:

1. Create a Neon project named `quickslot-booking-system`.
2. Use Postgres 17 or 18. Either is fine for this app.
3. Choose the closest region to your demo laptop/users. For India, Singapore is usually better than US East.
4. Do not enable Neon Auth for this hackathon unless asked. The requirement allows `X-User-Id`, so auth is intentionally light.
5. Copy the SQLAlchemy connection URL into `quick_slot_backend/.env` as `DATABASE_URL=...`.
6. Rotate/reset any database URL that was pasted into chat or committed by mistake.

Render deployment:

1. Push this monorepo to GitHub.
2. In Render, create a new Web Service from the GitHub repo.
3. Set Root Directory: `quick_slot_backend`.
4. Build Command: `pip install -r requirements.txt`.
5. Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.
6. Add environment variable `DATABASE_URL` using the Neon SQLAlchemy URL.
7. Add `ALLOWED_ORIGINS=*` for demo simplicity.

## Flutter Setup

```bash
cd quick_slot
flutter pub get
copy .env.example .env
flutter run
```

Use these API base URLs:

- Android emulator: `API_BASE_URL=http://10.0.2.2:8000`
- iOS simulator: `API_BASE_URL=http://localhost:8000`
- Physical phone: `API_BASE_URL=http://<your-laptop-LAN-IP>:8000`
- Render: `API_BASE_URL=https://<your-render-service>.onrender.com`

## API Schema

- `GET /venues` - list venues
- `GET /venues/{id}/slots?date=YYYY-MM-DD` - list venue slots with `available` or `booked`
- `POST /bookings` - body `{ "slot_id": 1, "user_name": "Aarav" }`, header `X-User-Id`
- `GET /users/{id}/bookings` - list bookings for one user
- `DELETE /bookings/{id}` - cancel booking, header `X-User-Id`

Status codes:

- `201` booking created
- `204` booking cancelled
- `404` venue/slot/booking missing
- `409` slot already taken
- `422` invalid input

## Concurrency Defense

The backend protects slots at the database layer. `bookings.slot_id` is unique, so only one active booking row can exist for a slot. When two devices post to `/bookings` at the same time, both requests try to insert. PostgreSQL serializes the unique index check: one insert commits, the other raises an integrity error. The API catches that error, rolls back, and returns `409 Conflict` with a clear message.

This is stronger than checking availability in Flutter or doing a separate "is slot free?" query before insert, because those approaches can race.

## Architecture Note

Flutter keeps business logic out of widgets by using a small API client and Riverpod providers for venues, slots, selected user/date, and bookings. Widgets render loading/error/empty/data states from providers. The backend owns validation, persistence, seeding, and concurrency. The app refreshes slot and booking providers after create/cancel so both screens stay consistent.

## Git Workflow

Use one GitHub repo for the monorepo. Commit at least every 45 minutes:

```bash
git add quick_slot quick_slot_backend README.md
git commit -m "Build QuickSlot booking API"
git commit -m "Add Flutter venue and booking flow"
git commit -m "Document setup and concurrency approach"
git push origin main
```

If Git shows a dubious ownership warning on this machine:

```bash
git config --global --add safe.directory D:/assignment/AI_AS
```

## Scope Cuts

I cut full authentication, payments, admin venue management, and push notifications. They do not help the core judging path. The priority is a correct booking flow and a provable no-double-booking guarantee.

## With One More Day

I would add polling for live slot status updates, a widget test for the slot grid, backend tests for the `409 Conflict` path, and a small offline cache for My Bookings.

## AI Usage Note

AI was used to scaffold the implementation plan, API structure, README wording, and Flutter screen wiring. One issue caught manually: a quoted database/API secret must not be committed or reused after being pasted into chat, so secrets should be rotated and kept only in `.env`/Render environment variables.
