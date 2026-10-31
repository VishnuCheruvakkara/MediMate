from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.features.medicines.models import DoseSchedule, Medicine
from app.features.medicines.schemas import MedicineCreate, MedicineUpdate


def list_medicines(db: Session) -> list[Medicine]:
    statement = (
        select(Medicine)
        .options(selectinload(Medicine.schedules))
        .order_by(Medicine.name)
    )
    return list(db.scalars(statement).all())


def get_medicine(db: Session, medicine_id: UUID) -> Medicine:
    statement = (
        select(Medicine)
        .where(Medicine.id == medicine_id)
        .options(selectinload(Medicine.schedules))
    )
    medicine = db.scalar(statement)
    if medicine is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Medicine not found")
    return medicine


def create_medicine(db: Session, payload: MedicineCreate) -> Medicine:
    values = payload.model_dump(exclude={"schedules"})
    medicine = Medicine(**values)
    medicine.schedules = [DoseSchedule(**item.model_dump()) for item in payload.schedules]
    db.add(medicine)
    db.commit()
    return get_medicine(db, medicine.id)


def update_medicine(db: Session, medicine_id: UUID, payload: MedicineUpdate) -> Medicine:
    medicine = get_medicine(db, medicine_id)
    values = payload.model_dump(exclude_unset=True, exclude={"schedules"})
    for key, value in values.items():
        setattr(medicine, key, value)
    if payload.schedules is not None:
        medicine.schedules = [
            DoseSchedule(**item.model_dump()) for item in payload.schedules
        ]
    db.commit()
    return get_medicine(db, medicine.id)


def delete_medicine(db: Session, medicine_id: UUID) -> None:
    medicine = get_medicine(db, medicine_id)
    db.delete(medicine)
    db.commit()

