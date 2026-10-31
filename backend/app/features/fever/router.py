from uuid import UUID

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.features.fever import service
from app.features.fever.schemas import FeverEntryCreate, FeverEntryRead, FeverEntryUpdate

router = APIRouter(prefix="/fever-entries", tags=["fever tracker"])


@router.get("", response_model=list[FeverEntryRead])
def list_all(db: Session = Depends(get_db)) -> list[FeverEntryRead]:
    return service.list_entries(db)


@router.post("", response_model=FeverEntryRead, status_code=status.HTTP_201_CREATED)
def create(payload: FeverEntryCreate, db: Session = Depends(get_db)) -> FeverEntryRead:
    return service.create_entry(db, payload)


@router.get("/{entry_id}", response_model=FeverEntryRead)
def get_one(entry_id: UUID, db: Session = Depends(get_db)) -> FeverEntryRead:
    return service.get_entry(db, entry_id)


@router.patch("/{entry_id}", response_model=FeverEntryRead)
def update(
    entry_id: UUID,
    payload: FeverEntryUpdate,
    db: Session = Depends(get_db),
) -> FeverEntryRead:
    return service.update_entry(db, entry_id, payload)


@router.delete("/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(entry_id: UUID, db: Session = Depends(get_db)) -> Response:
    service.delete_entry(db, entry_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)

