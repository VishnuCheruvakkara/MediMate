from datetime import datetime, timezone
from uuid import UUID, uuid4

from sqlalchemy import Boolean, DateTime, Float, JSON, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class FeverEntry(Base):
    __tablename__ = "fever_entries"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    temperature_c: Mapped[float] = mapped_column(Float())
    measured_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    measurement_method: Mapped[str] = mapped_column(String(30), default="other")
    symptoms: Mapped[list[str]] = mapped_column(JSON, default=list)
    notes: Mapped[str | None] = mapped_column(String(1000), nullable=True)
    medicine_taken: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utc_now, onupdate=utc_now
    )

