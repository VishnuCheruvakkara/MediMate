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
                "schedules": [{"time_of_day": "09:00:00", "interval_days": 1}],
            }
        ),
    )
    assert created.name == "Paracetamol"
    assert len(created.schedules) == 1

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

