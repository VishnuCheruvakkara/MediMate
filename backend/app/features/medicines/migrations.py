from sqlalchemy import Engine, inspect, text


def ensure_development_columns(engine: Engine) -> None:
    """Add new medicine fields to existing local SQLite databases.

    Production deployments should use versioned Alembic migrations. This keeps
    early local databases usable while the migration system is being added.
    """
    if engine.dialect.name != "sqlite":
        return
    inspector = inspect(engine)
    if "medicines" not in inspector.get_table_names():
        return
    existing = {column["name"] for column in inspector.get_columns("medicines")}
    additions = {
        "food_timing": "VARCHAR(30) NOT NULL DEFAULT 'as_directed'",
        "dose_pattern": "VARCHAR(40)",
        "schedule_mode": "VARCHAR(20) NOT NULL DEFAULT 'fixed_times'",
        "interval_hours": "INTEGER",
        "interval_start_time": "TIME",
    }
    with engine.begin() as connection:
        for name, definition in additions.items():
            if name not in existing:
                connection.execute(
                    text(f"ALTER TABLE medicines ADD COLUMN {name} {definition}")
                )

