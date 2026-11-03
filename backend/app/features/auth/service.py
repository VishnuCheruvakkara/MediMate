from secrets import token_urlsafe
from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.features.auth.models import User, hash_password, verify_password
from app.features.auth.schemas import UserLogin, UserRead, UserSignup


def create_user(db: Session, payload: UserSignup) -> UserRead:
    email_clean = payload.email.strip().lower()
    existing = db.scalar(select(User).where(User.email == email_clean))
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An account with this email already exists",
        )

    hashed, salt = hash_password(payload.password)
    user = User(
        name=payload.name.strip(),
        email=email_clean,
        hashed_password=hashed,
        salt=salt,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = token_urlsafe(32)
    return UserRead(id=user.id, name=user.name, email=user.email, token=token)


def authenticate_user(db: Session, payload: UserLogin) -> UserRead:
    email_clean = payload.email.strip().lower()
    user = db.scalar(select(User).where(User.email == email_clean))
    if not user or not verify_password(payload.password, user.hashed_password, user.salt):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    token = token_urlsafe(32)
    return UserRead(id=user.id, name=user.name, email=user.email, token=token)

