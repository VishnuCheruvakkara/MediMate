from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.features.auth import service
from app.features.auth.schemas import UserLogin, UserRead, UserSignup

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", response_model=UserRead, status_code=status.HTTP_201_CREATED)
def signup(payload: UserSignup, db: Session = Depends(get_db)) -> UserRead:
    return service.create_user(db, payload)


@router.post("/login", response_model=UserRead)
def login(payload: UserLogin, db: Session = Depends(get_db)) -> UserRead:
    return service.authenticate_user(db, payload)

