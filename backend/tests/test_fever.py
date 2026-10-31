from datetime import datetime, timezone

import pytest
from fastapi import HTTPException
from pydantic import ValidationError

from app.features.fever.schemas import FeverEntryCreate, FeverEntryUpdate
from app.features.fever.service import (
    create_entry,
    delete_entry,
    get_entry,
    list_entries,
    update_entry,
)


def test_fever_entry_crud(db):
    created = create_entry(
        db,
        FeverEntryCreate(
            temperature_c=38.2,
            measured_at=datetime(2026, 10, 31, 19, 30, tzinfo=timezone.utc),
            measurement_method="oral",
            symptoms=["headache", "headache", " fatigue "],
            notes="Resting and drinking fluids",
        ),
    )
    assert created.temperature_c == 38.2
    assert created.symptoms == ["headache", "fatigue"]
    assert len(list_entries(db)) == 1

    updated = update_entry(db, created.id, FeverEntryUpdate(medicine_taken=True))
    assert updated.medicine_taken is True

    delete_entry(db, created.id)
    with pytest.raises(HTTPException) as error:
        get_entry(db, created.id)
    assert error.value.status_code == 404


def test_fever_entry_requires_timezone():
    with pytest.raises(ValidationError):
        FeverEntryCreate(
            temperature_c=38,
            measured_at=datetime(2026, 10, 31, 19, 30),
        )

