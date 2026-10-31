# MediMate API

FastAPI service for cloud medicine and schedule storage. The Flutter app should
continue to use Drift locally and synchronize with this API when online.

## Run locally

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -e '.[dev]'
cp .env.example .env  # only when .env does not already exist
uvicorn app.api:app --reload
```

Open `http://127.0.0.1:8000/docs` for the interactive API documentation.

## Test

```bash
pytest
```

SQLite is the development default. For PostgreSQL, install `.[postgres]` and set:

```bash
MEDIMATE_DATABASE_URL=postgresql+psycopg://user:password@localhost/medimate
```

`backend/.env` is ignored by Git. Commit only `.env.example`, with placeholder
values. In production, inject `MEDIMATE_DATABASE_URL` through the hosting
provider's secret manager instead of uploading an environment file.


