# MediMate

MediMate is an offline-first medicine reminder application built with Flutter
and FastAPI. It is designed to help users organize medicines, schedule doses,
receive local reminders, and track adherence without assuming that a reminder
means a dose was taken.

## Why I built MediMate

MediMate began from a personal experience. I was dealing with a fever and
found that keeping track of my temperature, symptoms, medicines, and dose times
was harder than it should be—especially when I was tired and unwell. I wanted
one simple place where I could record how I was feeling, remember what needed
to be taken, and review the timeline later.

That experience inspired me to build MediMate. The goal is to create a calm,
practical companion for medicine reminders and health tracking that continues
to work offline. It does not replace a doctor or decide which medicine someone
should take; it helps people accurately record information and follow the care
instructions they have already received.

> [!IMPORTANT]
> MediMate is a reminder and tracking tool, not a medical diagnosis or dosage
> recommendation service. Medicine and dosage information should come from a
> qualified healthcare professional.

## Project status

MediMate is in early development. The repository currently includes:

- A generated Flutter Android application ready to be expanded.
- A FastAPI backend with medicine and dose-schedule CRUD operations.
- A fever log API for temperature, symptoms, measurement method, and notes.
- SQLite configuration for local backend development.
- PostgreSQL support for production deployments.
- Local environment templates with secret-safe Git ignore rules.
- Backend validation and automated tests.

The dashboard, Drift persistence, notifications, dose history, authentication,
and mobile-to-API synchronization are planned but not yet complete.

## Planned features

- Add, edit, archive, and delete medicines.
- Configure multiple dose times and repeat intervals.
- Schedule Android notifications that work when the app is closed.
- Mark doses as taken, skipped, or missed.
- Review adherence through calendar and history views.
- Record temperature and symptoms in a chronological fever log.
- Continue working offline using a local Drift database.
- Synchronize local records with the FastAPI service when online.
- Support user accounts and multiple profiles in a later phase.

## Technology stack

| Area | Technology |
| --- | --- |
| Mobile application | Flutter and Dart |
| State management | Riverpod (planned) |
| Local database | Drift / SQLite (planned) |
| Navigation | `go_router` (planned) |
| Notifications | `flutter_local_notifications` (planned) |
| Backend API | FastAPI |
| API persistence | SQLAlchemy |
| Development database | SQLite |
| Production database | PostgreSQL |
| API testing | Pytest |

## Repository structure

```text
MediMate/
├── android/                 # Android platform project
├── backend/
│   ├── app/
│   │   ├── core/            # Configuration and database setup
│   │   └── features/
│   │       └── medicines/   # Models, schemas, service, and API router
│   └── tests/               # Backend tests
├── lib/
│   ├── core/config/         # Public Flutter build configuration
│   └── main.dart            # Flutter entry point
├── test/                    # Flutter tests
├── .env.flutter.example     # Safe Flutter configuration template
└── pubspec.yaml
```

## Prerequisites

- Flutter stable with Dart
- Android SDK and either an Android phone or emulator
- Python 3.12 or newer
- Git
- PostgreSQL only when testing the production database configuration

## Getting started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/MediMate.git
cd MediMate
```

Replace `YOUR_USERNAME` with your GitHub username after creating the repository.

### 2. Configure and run the backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -e '.[dev]'
cp .env.example .env
uvicorn app.api:app --reload
```

The API will be available at `http://127.0.0.1:8000`. Useful development URLs:

- OpenAPI interface: `http://127.0.0.1:8000/docs`
- Health check: `http://127.0.0.1:8000/health`

Run the backend tests with:

```bash
cd backend
source .venv/bin/activate
pytest
```

### 3. Configure Flutter

From the repository root, create the ignored local configuration:

```bash
cp .env.flutter.example .env.flutter.json
```

The default `API_BASE_URL` is `http://127.0.0.1:8000` for the Chrome preview.
For an Android emulator, change it to `http://10.0.2.2:8000` so the emulator
can reach a backend running on the Ubuntu host.

For a physical Android phone, use the computer's LAN address in the ignored
`.env.flutter.json` file, for example:

```json
{
  "API_BASE_URL": "http://192.168.1.20:8000",
  "APP_ENVIRONMENT": "development"
}
```

Start FastAPI so it is reachable on the local network:

```bash
cd backend
source .venv/bin/activate
uvicorn app.api:app --host 0.0.0.0 --reload
```

Only use this development server on a trusted local network.

### 4. Run Flutter

```bash
flutter pub get
flutter run --dart-define-from-file=.env.flutter.json
```

If Flutter is not yet available on your shell `PATH`, use its full location on
this Ubuntu setup:

```bash
/home/unknown/development/flutter/bin/flutter pub get
/home/unknown/development/flutter/bin/flutter run -d chrome --dart-define-from-file=.env.flutter.json
```

## Run the frontend and backend together

Both services must remain running, so open two terminals.

In **Terminal 1**, start FastAPI:

```bash
cd /home/unknown/Projects/MediMate/backend
source .venv/bin/activate
uvicorn app.api:app --reload
```

The backend API documentation is available at `http://127.0.0.1:8000/docs`.

In **Terminal 2**, start Flutter in Chrome:

```bash
cd /home/unknown/Projects/MediMate
/home/unknown/development/flutter/bin/flutter pub get
/home/unknown/development/flutter/bin/flutter run -d chrome --dart-define-from-file=.env.flutter.json
```

Press `r` in the Flutter terminal for hot reload or `q` to stop it. Stop the
backend with `Ctrl+C`.

## Configuration and secrets

Local configuration files are intentionally excluded from Git:

- `backend/.env`
- `.env.flutter.json`
- Android signing keys and `key.properties`
- Firebase `google-services.json`
- PEM, service-account, and keystore files

Commit only the sanitized example files. Production database passwords and
backend secrets should be injected through the deployment provider's secret
manager.

Values compiled into Flutter are not private. Never put database credentials,
signing secrets, or private third-party API keys in Flutter configuration.

## Architecture direction

The Flutter application will remain offline-first. Drift will serve as the
on-device source of data while offline, and a synchronization layer will
exchange changes with FastAPI when connectivity is available. Stable UUIDs and
timestamps are used by the backend to support this direction.

The backend groups code by feature and separates API routes, validation
schemas, persistence models, and business operations. Database migrations and
authentication will be introduced before production deployment.

## Contributing

Contributions and constructive feedback are welcome while the project evolves.
Before opening a pull request:

1. Create a focused branch from the default branch.
2. Keep credentials and local environment files out of commits.
3. Run `flutter analyze`, `flutter test`, and the backend `pytest` suite.
4. Explain the behavior changed and include tests when practical.

## License

A license has not been selected yet. Add a `LICENSE` file before inviting broad
reuse or external contributions.
