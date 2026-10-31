from uuid import UUID

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.features.medicines import service
from app.features.medicines.schemas import MedicineCreate, MedicineRead, MedicineUpdate

router = APIRouter(prefix="/medicines", tags=["medicines"])


@router.get("", response_model=list[MedicineRead])
def list_all(db: Session = Depends(get_db)) -> list[MedicineRead]:
    return service.list_medicines(db)


@router.post("", response_model=MedicineRead, status_code=status.HTTP_201_CREATED)
def create(payload: MedicineCreate, db: Session = Depends(get_db)) -> MedicineRead:
    return service.create_medicine(db, payload)


@router.get("/{medicine_id}", response_model=MedicineRead)
def get_one(medicine_id: UUID, db: Session = Depends(get_db)) -> MedicineRead:
    return service.get_medicine(db, medicine_id)


@router.patch("/{medicine_id}", response_model=MedicineRead)
def update(
    medicine_id: UUID,
    payload: MedicineUpdate,
    db: Session = Depends(get_db),
) -> MedicineRead:
    return service.update_medicine(db, medicine_id, payload)


@router.delete("/{medicine_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(medicine_id: UUID, db: Session = Depends(get_db)) -> Response:
    service.delete_medicine(db, medicine_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)

