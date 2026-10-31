from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.features.fever.models import FeverEntry
from app.features.fever.schemas import FeverEntryCreate, FeverEntryUpdate


def list_entries(db: Session) -> list[FeverEntry]:
    statement = select(FeverEntry).order_by(FeverEntry.measured_at.desc())
    return list(db.scalars(statement).all())


def get_entry(db: Session, entry_id: UUID) -> FeverEntry:
    entry = db.get(FeverEntry, entry_id)
    if entry is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Fever entry not found")
    return entry


def create_entry(db: Session, payload: FeverEntryCreate) -> FeverEntry:
    entry = FeverEntry(**payload.model_dump())
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


def update_entry(db: Session, entry_id: UUID, payload: FeverEntryUpdate) -> FeverEntry:
    entry = get_entry(db, entry_id)
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(entry, key, value)
    db.commit()
    db.refresh(entry)
    return entry


def delete_entry(db: Session, entry_id: UUID) -> None:
    entry = get_entry(db, entry_id)
    db.delete(entry)
    db.commit()

