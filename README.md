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

Local backend with Neon PostgreSQL:

```bash
cd quick_slot_backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Put the Neon SQLAlchemy URL in `quick_slot_backend/.env`:

```bash
DATABASE_URL=postgresql://USER:PASSWORD@HOST/neondb?sslmode=require&channel_binding=require
ALLOWED_ORIGINS=*
```

Neon PostgreSQL:

1. Create a Neon project named `quickslot-booking-system`.
2. Use Postgres 17 or 18. Either is fine for this app.
3. Choose the closest region to your demo laptop/users. For India, Singapore is usually better than US East.
4. Do not enable Neon Auth for this hackathon unless asked. The requirement allows `X-User-Id`, so auth is intentionally light.
5. Copy the SQLAlchemy connection URL into `quick_slot_backend/.env` as `DATABASE_URL=...`, or paste it into Render as an environment variable.
6. Never commit the real `DATABASE_URL`. It includes the database password. If it was pasted into chat or pushed anywhere public, rotate/reset it in Neon.

For reviewers/judges, the backend expects a PostgreSQL `DATABASE_URL`. For this project, use Neon locally and in Render.

Render deployment:

1. Push this monorepo to GitHub.
2. In Render, create a new Web Service from the GitHub repo.
3. Set Root Directory: `quick_slot_backend`.
4. Build Command: `pip install -r requirements.txt`.
5. Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.
6. Add environment variable `DATABASE_URL` using the Neon SQLAlchemy URL.
7. Add `ALLOWED_ORIGINS=*` for demo simplicity.
8. Open `/health` after deploy. It should return `{ "status": "ok" }`.

## Flutter Setup

```bash
cd quick_slot
flutter pub get
flutter run
```

The Flutter API base URL is currently a code constant in `AppConfig`:

- Current physical phone setup: `http://10.41.13.83:8000`
- Android emulator alternative: `http://10.0.2.2:8000`
- iOS simulator alternative: `http://localhost:8000`
- Render alternative: `https://<your-render-service>.onrender.com`

Change `quick_slot/lib/src/config/app_config.dart` when switching between phone, emulator, or Render.

For a physical Android phone, `10.0.2.2` will not work. Your current laptop Wi-Fi IPv4 address is `10.41.13.83`, so the app uses:

```bash
http://10.41.13.83:8000
```

Keep the phone and laptop on the same Wi-Fi, and allow Python/Uvicorn through Windows Firewall.

## API Schema

- `GET /health` - health check for local/Render smoke testing
- `GET /` - small API preview
- `GET /venues` - list venues
- `GET /venues/{id}` - venue detail
- `GET /venues/{id}/slots?date=YYYY-MM-DD` - list venue slots with `available` or `booked`
- `POST /bookings` - body `{ "slot_id": 1, "user_name": "Aarav" }`, header `X-User-Id`
- `GET /users/{id}/bookings` - list bookings for one user
- `DELETE /bookings/{id}` - cancel booking, header `X-User-Id`

FastAPI also exposes:

- `/docs` - interactive Swagger API preview
- `/openapi.json` - OpenAPI schema

The slots endpoint accepts `date`; if it is omitted during manual browser testing, the backend defaults to today.

Status codes:

- `201` booking created
- `204` booking cancelled
- `404` venue/slot/booking missing
- `409` slot already taken
- `422` invalid input

## Concurrency Defense

The backend protects slots at the database layer. `bookings.slot_id` is unique, so only one active booking row can exist for a slot. When two devices post to `/bookings` at the same time, both requests try to insert. PostgreSQL serializes the unique index check: one insert commits, the other raises an integrity error. The API catches that error, rolls back, and returns `409 Conflict` with a clear message.

This is stronger than checking availability in Flutter or doing a separate "is slot free?" query before insert, because those approaches can race.

## Verification

Backend:

```bash
cd quick_slot_backend
pip install -r requirements.txt
pytest
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Flutter:

```bash
cd quick_slot
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

If `flutter` or `dart` hangs on this Windows machine, direct Dart analysis can still be checked with:

```bash
C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe analyze
```

If that prints `No issues found!` followed by a telemetry permission error under `AppData\Roaming\.dart-tool`, the code analysis passed and the local Dart telemetry file permissions need to be fixed separately.

Neon note: if local Uvicorn fails with `psycopg2.OperationalError` and Windows error `10013 Permission denied` while connecting to port `5432`, your machine/network is blocking outbound PostgreSQL. Unblock Python/PostgreSQL traffic in firewall/security software, or deploy the backend to Render with Neon via the `DATABASE_URL` environment variable.

## CI

GitHub Actions is configured in `.github/workflows/ci.yml`.

On every push or pull request to `main`, it runs:

- backend dependency install + `pytest`
- Flutter `pub get`
- Flutter `analyze`
- Flutter `test`
- Flutter debug APK build

## Architecture Note

Flutter keeps business logic out of widgets by using a small API client and Riverpod providers for venues, slots, selected user/date, and bookings. Widgets render loading/error/empty/data states from providers. The backend owns validation, persistence, seeding, and concurrency. The app refreshes slot and booking providers after create/cancel so both screens stay consistent.

## Git Workflow

Use one GitHub repo for the monorepo. During the actual hackathon, commit at least every 45 minutes:

```bash
git commit -m "initialize flutter and backend projects"
git commit -m "create postgres schema and seed data"
git commit -m "implement venue and slot endpoints"
git commit -m "implement booking endpoint with conflict handling"
git commit -m "add riverpod architecture and api layer"
git commit -m "build venue list and slot selection screens"
git commit -m "implement booking flow and confirmations"
git commit -m "add my bookings and cancellation support"
git commit -m "add loading empty and error states"
git commit -m "complete documentation and cleanup"
```

Do not rewrite history just to fake these commits. From this point onward, make small real commits for each improvement.

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
