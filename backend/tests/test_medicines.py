import pytest
from fastapi import HTTPException
from pydantic import ValidationError

from app.features.medicines.schemas import MedicineCreate, MedicineUpdate
from app.features.medicines.service import (
    create_medicine,
    delete_medicine,
    get_medicine,
    list_medicines,
    update_medicine,
)


def test_medicine_crud(db):
    created = create_medicine(
        db,
        MedicineCreate.model_validate(
            {
                "name": "Paracetamol",
                "dosage": "As prescribed",
                "instructions": "Follow clinician instructions",
                "food_timing": "after_food",
                "dose_pattern": "1-1-1",
                "schedules": [{"time_of_day": "09:00:00", "interval_days": 1}],
            }
        ),
    )
    assert created.name == "Paracetamol"
    assert len(created.schedules) == 1
    assert created.food_timing == "after_food"
    assert created.dose_pattern == "1-1-1"

    assert len(list_medicines(db)) == 1

    updated = update_medicine(db, created.id, MedicineUpdate(is_active=False))
    assert updated.is_active is False

    delete_medicine(db, created.id)
    with pytest.raises(HTTPException) as error:
        get_medicine(db, created.id)
    assert getattr(error.value, "status_code", None) == 404


def test_rejects_invalid_schedule():
    with pytest.raises(ValidationError):
        MedicineCreate.model_validate(
            {
                "name": "Example",
                "dosage": "As prescribed",
                "schedules": [{"time_of_day": "09:00:00", "interval_days": 0}],
            }
        )


def test_accepts_hourly_interval_schedule():
    payload = MedicineCreate.model_validate(
        {
            "name": "Example",
            "dosage": "As prescribed",
            "schedule_mode": "interval",
            "interval_hours": 4,
            "interval_start_time": "08:00:00",
            "schedules": [],
        }
    )
    assert payload.interval_hours == 4


def test_rejects_interval_without_start_time():
    with pytest.raises(ValidationError):
        MedicineCreate.model_validate(
            {
                "name": "Example",
                "dosage": "As prescribed",
                "schedule_mode": "interval",
                "interval_hours": 4,
            }
        )

